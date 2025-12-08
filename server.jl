using Flux, Random, JSON3, HTTP

# Fluxモデル
model = Chain(Dense(100 => 32, relu), Dense(32 => 3, sigmoid))

function text_to_vec(text::String)
    h = hash(text, UInt(1234567))
    sin.(0.01f0 * (h .+ (1:100)))
end

function predict(text::String)
    vec = text_to_vec(text)
    scores = model(vec)
    Dict("習慣" => round(scores[1], digits=2),
         "技術" => round(scores[2], digits=2), 
         "ビジネス" => round(scores[3], digits=2))
end

# HTTPハンドラー関数（マクロ不要）
function handle_predict(req::HTTP.Request)
    body = JSON.parse(String(req.body))
    result = predict(body["text"])
    return HTTP.Response(200, [("Content-Type", "application/json")], JSON3.write(result))
end

function handle_notfound(req::HTTP.Request)
    return HTTP.Response(404, [("Content-Type", "text/plain")], "Not Found")
end

# サーバー起動（最新API）
HTTP.listen("0.0.0.0", parse(Int, get(ENV, "PORT", "8000"))) do req::HTTP.Request
    if req.method == "POST" && endswith(req.target, "/predict")
        return handle_predict(req)
    else
        return handle_notfound(req)
    end
end

println("🚀 GrowthTrail AI Server running on port ", get(ENV, "PORT", "8000"))
