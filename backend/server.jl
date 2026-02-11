using Pkg
Pkg.activate(@__DIR__)

using HTTP
using JSON

# ─────────────────────────────────────────────
# CORS
# ─────────────────────────────────────────────
function cors_headers()
    return [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Headers" => "Content-Type, Authorization",
        "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
        "Access-Control-Max-Age" => "86400"
    ]
end

function handle_options(req::HTTP.Request)
    return HTTP.Response(200, cors_headers(), "")
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
        # Messages API のレスポンスから text を抽出
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
        # パース失敗時は空の Dict を返す
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
        error_body = JSON.json(Dict("error" => "Invalid JSON in request body"))
        return HTTP.Response(400, cors_headers(), error_body)
    end

    traits = get(data, "traits", nothing)
    if traits === nothing || !isa(traits, Vector)
        error_body = JSON.json(Dict("error" => "\"traits\" must be a JSON array of strings"))
        return HTTP.Response(400, cors_headers(), error_body)
    end

    if isempty(traits)
        error_body = JSON.json(Dict("error" => "\"traits\" array must not be empty"))
        return HTTP.Response(400, cors_headers(), error_body)
    end

    # 特性 → スキル変換
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
        error_body = JSON.json(Dict(
            "error" => "No matching traits found",
            "not_found" => not_found
        ))
        return HTTP.Response(404, cors_headers(), error_body)
    end

    # Claude API で理由を生成
    reasons = Dict{String, String}()
    prompt = build_explanation_prompt(converted)
    raw_response = call_claude_api(prompt)
    if raw_response !== nothing && !isempty(raw_response)
        reasons = parse_claude_reasons(raw_response, converted)
    end

    # レスポンス構築
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

    return HTTP.Response(200, cors_headers(), JSON.json(response))
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

    return HTTP.Response(200, cors_headers(), response_body)
end

function health_html(req::HTTP.Request)
    html_path = joinpath(@__DIR__, "frontend/dist/index.html")

    if !isfile(html_path)
        return HTTP.Response(500, "index.html not found in frontend/dist/")
    end

    html = read(html_path, String)
    return HTTP.Response(200, ["Content-Type" => "text/html"], html)
end

function static_file(req::HTTP.Request)
    rel_path = req.target[2:end]
    file_path = joinpath(@__DIR__, "frontend/dist", rel_path)

    if !isfile(file_path)
        return nothing
    end

    content_type =
        endswith(file_path, ".js")  ? "application/javascript" :
        endswith(file_path, ".css") ? "text/css" :
        endswith(file_path, ".svg") ? "image/svg+xml" :
        endswith(file_path, ".png") ? "image/png" :
        "application/octet-stream"

    return HTTP.Response(200, ["Content-Type" => content_type], read(file_path))
end

# ─────────────────────────────────────────────
# ルーティング
# ─────────────────────────────────────────────
HTTP.serve("0.0.0.0", 8081) do req::HTTP.Request

    if startswith(req.target, "/assets/")
        res = static_file(req)
        if res !== nothing
            return res
        end
    end

    if req.method == "OPTIONS"
        return handle_options(req)

    elseif req.target == "/health" && req.method == "GET"
        return health_html(req)

    elseif req.target == "/analyze" && req.method == "POST"
        return analyze(req)

    elseif req.target == "/traits/convert" && req.method == "POST"
        return convert_traits(req)

    else
        return health_html(req)
    end
end
