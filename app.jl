using HTTP, JSON3, Flux

include("model.jl")
include("preprocess.jl")

SKILL_MAP = ["提案力","資料作成","顧客理解","交渉力","分析力",
             "リーダーシップ","コミュニケーション","計画力","実行力","創造力"]

function handler(req)
    try
        if req.target == "/"
            println("✅ Healthcheck GET / accessed")
            return HTTP.Response(200, "GrowthTrail AI Ready! 🚀 (Flux integrated)")
        elseif startswith(req.target, "/predict?text=")
            query = HTTP.URI(req.target).query
            text = split(query, "text=")[end]
            emb = text_to_embedding(text)
            scores = model(emb)
            t = argmax(scores, dims=1)[1]
            resp = Dict(
                "text" => text,
                "top_skill" => SKILL_MAP[t.I[1]],
                "confidence" => round(Float32(scores[t.I[1]]), digits=2)
            )
            return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(resp))
        else
            return HTTP.Response(404, "Not Found")
        end
    catch e
        println("⚠️ Error: ", e)
        return HTTP.Response(500, "Error $(e)")
    end
end

port = parse(Int, get(ENV, "PORT", "10000"))
@async HTTP.serve(handler, "0.0.0.0", port)
println("🚀 GrowthTrail server running on port $port")
