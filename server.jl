# server.jl（純粋スタンドアロン版）
using HTTP, JSON3, Flux, Random, Dates

println("✓ Pure Julia startup - no Pkg involved")

Random.seed!(1234)

GROWTH_MODEL = Chain(
    Dense(3, 8, relu),
    Dense(8, 3),
    softmax
)

MODEL_INFO = Dict(
    "name" => "growthtrail_mlp_v1",
    "version" => "0.2.0"
)

println("✓ Model loaded v0.2.0")

function safe_json_read(body::String)
    try
        JSON3.read(body)
    catch
        nothing
    end
end

function predict_growth(inputs)
    x = reshape(Float32.(inputs), :, 1)
    vec(GROWTH_MODEL(x))
end

function handle_predict(req)
    data = safe_json_read(String(req.body))
    data === nothing && return HTTP.Response(400, """{"error":"Invalid JSON"}""")
    
    haskey(data, "習慣") || haskey(data, "技術") || haskey(data, "ビジネス") || 
        return HTTP.Response(400, """{"error":"Missing keys"}""")
    
    input_vec = Float32[data["習慣"], data["技術"], data["ビジネス"]]
    preds = predict_growth(input_vec)
    
    result = Dict(
        "習慣成長" => round(preds[1], digits=2),
        "技術成長" => round(preds[2], digits=2),
        "ビジネス成長" => round(preds[3], digits=2)
    )
    
    resp = Dict("result" => result, "version" => "0.2.0")
    HTTP.Response(200, JSON3.write(resp))
end

handle_health(_req) = HTTP.Response(200, """{"status":"GrowthTrail AI v0.2.0","timestamp":"$(now())"}""")

route(req::HTTP.Request) = begin
    if req.target == "/predict" && req.method == "POST"
        handle_predict(req)
    elseif req.target == "/health" && req.method == "GET"
        handle_health(req)
    else
        HTTP.Response(404, "Not found")
    end
end

PORT = parse(Int, get(ENV, "PORT", "10000"))
println("Starting GrowthTrail AI v0.2.0 on 0.0.0.0:$PORT")
HTTP.serve(route, "0.0.0.0", PORT)
