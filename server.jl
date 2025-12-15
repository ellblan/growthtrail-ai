using HTTP
using JSON3
using Flux
using Random
using Dates

function safe_json_read(body::String)
    try
        return JSON3.read(body)
    catch e
        @warn "Invalid JSON input" exception=(e, catch_backtrace())
        return nothing
    end
end

# ==============================
# モデル定義と初期化
# ==============================
Random.seed!(1234)

GROWTH_MODEL = Chain(
    Dense(3, 8, relu),
    Dense(8, 3),
    softmax
)

const MODEL_INFO = Dict(
    "name" => "growthtrail_mlp_v1",
    "version" => "0.2.0",
    "created_at" => string(now())
)

# ==============================
# ユーティリティ関数
# ==============================
function predict_growth(inputs::AbstractVector{<:Real})
    x = reshape(Float32.(inputs), :, 1)
    y = GROWTH_MODEL(x)
    return vec(y)
end

function handle_predict(req::HTTP.Request)
    data = safe_json_read(String(req.body))
    if data === nothing
        return HTTP.Response(400, JSON3.write(Dict("error"=>"Invalid JSON")))
    end

    if !haskey(data, "習慣") || !haskey(data, "技術") || !haskey(data, "ビジネス")
        return HTTP.Response(400, JSON3.write(Dict("error"=>"Missing input keys: 習慣, 技術, ビジネス")))
    end

    input_vec = Float32[data["習慣"], data["技術"], data["ビジネス"]]
    preds = predict_growth(input_vec)

    result = Dict(
        "習慣成長" => round(Float64(preds[1]); digits=2),
        "技術成長" => round(Float64(preds[2]); digits=2),
        "ビジネス成長" => round(Float64(preds[3]); digits=2)
    )

    resp = Dict(
        "meta" => Dict(
            "model" => MODEL_INFO["name"],
            "version" => MODEL_INFO["version"],
            "timestamp" => string(now())
        ),
        "result" => result
    )

    return HTTP.Response(200, JSON3.write(resp))
end

# ==============================
# /health エンドポイント
# ==============================
function handle_health(_req::HTTP.Request)
    uptime_sec = 0.0
    resp = Dict(
        "status" => "ok",
        "version" => MODEL_INFO["version"],
        "model" => MODEL_INFO["name"],
        "timestamp" => string(now()),
        "uptime_sec" => uptime_sec
    )
    return HTTP.Response(200, JSON3.write(resp))
end

# ==============================
# ルーティング
# ==============================
function route(req::HTTP.Request)
    if req.target == "/predict" && req.method == "POST"
        return handle_predict(req)
    elseif req.target == "/health" && req.method == "GET"
        return handle_health(req)
    else
        return HTTP.Response(404, "Not found")
    end
end

# ==============================
# サーバ起動
# ==============================
println("Starting GrowthTrail AI server v$(MODEL_INFO["version"])...")
HTTP.serve(route, "0.0.0.0", 8080)
