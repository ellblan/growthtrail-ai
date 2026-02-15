using Pkg
Pkg.activate(@__DIR__)

using HTTP
using JSON

# ─────────────────────────────────────────────
# CORS（const で 1 回だけ生成）
# ─────────────────────────────────────────────
const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "Content-Type, Authorization",
    "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
    "Access-Control-Max-Age" => "86400"
]

const CORS_PREFLIGHT_RESPONSE = HTTP.Response(200, CORS_HEADERS, "")

function handle_options(req::HTTP.Request)
    return CORS_PREFLIGHT_RESPONSE
end

# ─────────────────────────────────────────────
# 静的ファイルキャッシュ（起動時に全てメモリ展開）
# ─────────────────────────────────────────────
const STATIC_CACHE = Dict{String, Tuple{String, Vector{UInt8}}}()

function cache_static_files()
    dist_dir = joinpath(@__DIR__, "frontend", "dist")
    if !isdir(dist_dir)
        @warn "frontend/dist not found — static cache empty"
        return
    end

    for (root, dirs, files) in walkdir(dist_dir)
        for file in files
            full = joinpath(root, file)
            rel  = "/" * relpath(full, dist_dir)
            ct   = endswith(file, ".js")   ? "application/javascript" :
                   endswith(file, ".css")  ? "text/css" :
                   endswith(file, ".svg")  ? "image/svg+xml" :
                   endswith(file, ".png")  ? "image/png" :
                   endswith(file, ".html") ? "text/html" :
                   endswith(file, ".ico")  ? "image/x-icon" :
                   endswith(file, ".json") ? "application/json" :
                   "application/octet-stream"
            STATIC_CACHE[rel] = (ct, read(full))
        end
    end
    @info "Static cache loaded" files=length(STATIC_CACHE)
end

cache_static_files()

# index.html をキャッシュから取得（毎回ディスク読み不要）
const INDEX_HTML = let
    entry = get(STATIC_CACHE, "/index.html", nothing)
    if entry !== nothing
        HTTP.Response(200, ["Content-Type" => "text/html"], entry[2])
    else
        HTTP.Response(500, ["Content-Type" => "text/plain"], "index.html not found")
    end
end

# ─────────────────────────────────────────────
# 特性 → ビジネススキル マッピング辞書のロード
# ─────────────────────────────────────────────
const MAPPING_PATH = joinpath(@__DIR__, "personality_skills_mapping.json")

function load_trait_mapping()
    raw = JSON.parsefile(MAPPING_PATH)
    mapping = Dict{String, Dict{String, Any}}()
    for entry in raw["mappings"]
        trait = entry["trait"]
        info = Dict{String, Any}("skill" => entry["skill"])
        if haskey(entry, "caveat")
            info["caveat"] = entry["caveat"]
        end
        mapping[trait] = info
    end
    return mapping
end

const TRAIT_MAPPING = load_trait_mapping()

# ─────────────────────────────────────────────
# Claude API 呼び出し
# ─────────────────────────────────────────────
function call_claude_api(prompt::String)
    api_key = get(ENV, "ANTHROPIC_API_KEY", "")
    if isempty(api_key)
        return nothing
    end

    request_body = JSON.json(Dict(
        "model" => "claude-sonnet-4-5-20250929",
        "max_tokens" => 1024,
        "messages" => [
            Dict("role" => "user", "content" => prompt)
        ]
    ))

    headers = [
        "Content-Type" => "application/json",
        "x-api-key" => api_key,
        "anthropic-version" => "2023-06-01"
    ]

    try
        resp = HTTP.post(
            "https://api.anthropic.com/v1/messages",
            headers,
            request_body;
            connect_timeout=10,
            readtimeout=30
        )
        data = JSON.parse(String(resp.body))
        content_blocks = get(data, "content", [])
        if !isempty(content_blocks)
            return get(content_blocks[1], "text", "")
        end
        return ""
    catch e
        @warn "Claude API call failed" exception=e
        return nothing
    end
end

function build_explanation_prompt(converted::Vector{Dict{String,Any}})
    lines = String[]
    push!(lines, "あなたはGrowthTrail AIのキャリアアドバイザーです。")
    push!(lines, "以下の特性からビジネススキルへの変換結果について、それぞれ1〜2文で")
    push!(lines, "「なぜその特性がそのビジネススキルに繋がるのか」を説明してください。")
    push!(lines, "GrowthTrailの理念（見えない価値を可視化する）を踏まえ、ポジティブな視点で書いてください。")
    push!(lines, "")
    push!(lines, "JSON配列で返してください。形式: [{\"trait\": \"...\", \"reason\": \"...\"}]")
    push!(lines, "JSONのみを返し、他のテキストは含めないでください。")
    push!(lines, "")
    for item in converted
        skill_label = item["skill"]
        if haskey(item, "caveat")
            skill_label *= "（" * item["caveat"] * "）"
        end
        push!(lines, "- 特性「$(item["trait"])」→ スキル「$(skill_label)」")
    end
    return join(lines, "\n")
end

function parse_claude_reasons(raw_text::String, converted::Vector{Dict{String,Any}})
    reasons = Dict{String, String}()
    try
        parsed = JSON.parse(raw_text)
        if isa(parsed, Vector)
            for item in parsed
                if isa(item, Dict) && haskey(item, "trait") && haskey(item, "reason")
                    reasons[item["trait"]] = item["reason"]
                end
            end
        end
    catch
    end
    return reasons
end

# ─────────────────────────────────────────────
# POST /traits/convert ハンドラ
# ─────────────────────────────────────────────
function convert_traits(req::HTTP.Request)
    local data
    try
        data = JSON.parse(String(req.body))
    catch
        return HTTP.Response(400, CORS_HEADERS,
            JSON.json(Dict("error" => "Invalid JSON in request body")))
    end

    traits = get(data, "traits", nothing)
    if traits === nothing || !isa(traits, Vector)
        return HTTP.Response(400, CORS_HEADERS,
            JSON.json(Dict("error" => "\"traits\" must be a JSON array of strings")))
    end

    if isempty(traits)
        return HTTP.Response(400, CORS_HEADERS,
            JSON.json(Dict("error" => "\"traits\" array must not be empty")))
    end

    converted = Dict{String,Any}[]
    not_found = String[]
    for trait in traits
        if !isa(trait, AbstractString)
            continue
        end
        if haskey(TRAIT_MAPPING, trait)
            info = TRAIT_MAPPING[trait]
            entry = Dict{String,Any}("trait" => trait, "skill" => info["skill"])
            if haskey(info, "caveat")
                entry["caveat"] = info["caveat"]
            end
            push!(converted, entry)
        else
            push!(not_found, trait)
        end
    end

    if isempty(converted)
        return HTTP.Response(404, CORS_HEADERS,
            JSON.json(Dict("error" => "No matching traits found", "not_found" => not_found)))
    end

    # Claude API で理由を生成
    reasons = Dict{String, String}()
    prompt = build_explanation_prompt(converted)
    raw_response = call_claude_api(prompt)
    if raw_response !== nothing && !isempty(raw_response)
        reasons = parse_claude_reasons(raw_response, converted)
    end

    skills = []
    for item in converted
        skill_entry = Dict{String,Any}(
            "trait"  => item["trait"],
            "skill"  => item["skill"],
            "reason" => get(reasons, item["trait"],
                "この特性はビジネスにおいて価値のあるスキルとして活かすことができます。")
        )
        if haskey(item, "caveat")
            skill_entry["caveat"] = item["caveat"]
        end
        push!(skills, skill_entry)
    end

    response = Dict{String,Any}("skills" => skills)
    if !isempty(not_found)
        response["not_found"] = not_found
    end

    return HTTP.Response(200, CORS_HEADERS, JSON.json(response))
end

# ─────────────────────────────────────────────
# 既存エンドポイント
# ─────────────────────────────────────────────
function extract_features(text::String)
    return [0.5, 0.3, 0.8]
end

function analyze(req::HTTP.Request)
    body = String(req.body)
    data = JSON.parse(body)
    text = data["text"]

    features = extract_features(text)

    response_body = JSON.json(Dict(
        "labels" => Dict(
            "positivity" => features[1],
            "abstractness" => features[2],
            "energy" => features[3]
        )
    ))

    return HTTP.Response(200, CORS_HEADERS, response_body)
end

# ─────────────────────────────────────────────
# エラーレスポンス
# ─────────────────────────────────────────────
function json_error(status::Int, message::String)
    body = JSON.json(Dict("error" => message))
    return HTTP.Response(status, CORS_HEADERS, body)
end

# 既知の API ルートとその許可メソッド
const API_ROUTES = Dict(
    "/analyze"        => "POST",
    "/traits/convert" => "POST"
)

# ─────────────────────────────────────────────
# ウォームアップ（JIT コンパイルを起動時に完了）
# ─────────────────────────────────────────────
function warmup()
    @info "Running warmup..."

    # JSON のシリアライズ / デシリアライズをウォームアップ
    JSON.json(Dict("warmup" => true))
    JSON.parse("{\"warmup\":true}")

    # extract_features のコンパイル
    extract_features("warmup")

    # Dict 操作のコンパイル
    haskey(TRAIT_MAPPING, "慎重")
    get(TRAIT_MAPPING, "慎重", nothing)

    @info "Warmup complete"
end

warmup()

# ─────────────────────────────────────────────
# ルーティング
# ─────────────────────────────────────────────
HTTP.serve("0.0.0.0", 8080) do req::HTTP.Request

    # --- 静的ファイル配信（メモリキャッシュ） ---
    if startswith(req.target, "/assets/")
        entry = get(STATIC_CACHE, req.target, nothing)
        if entry !== nothing
            ct, data = entry
            return HTTP.Response(200, ["Content-Type" => ct], data)
        end
    end

    # --- CORS プリフライト ---
    if req.method == "OPTIONS"
        return handle_options(req)

    # --- フロントエンド (SPA) ---
    elseif req.target == "/" && req.method == "GET"
        return INDEX_HTML

    elseif req.target == "/health" && req.method == "GET"
        return INDEX_HTML

    # --- API エンドポイント ---
    elseif req.target == "/analyze" && req.method == "POST"
        return analyze(req)

    elseif req.target == "/traits/convert" && req.method == "POST"
        return convert_traits(req)

    # --- メソッド不一致 (405) ---
    elseif haskey(API_ROUTES, req.target)
        allowed = API_ROUTES[req.target]
        return HTTP.Response(405,
            [CORS_HEADERS; "Allow" => allowed],
            JSON.json(Dict(
                "error"   => "Method not allowed",
                "allowed" => allowed,
                "path"    => req.target
            ))
        )

    # --- 未知のパス (404) ---
    else
        return json_error(404, "Not found: $(req.target)")
    end
end
