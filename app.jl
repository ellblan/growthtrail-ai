using HTTP, JSON3, Flux

include("model.jl")
include("preprocess.jl")

SKILL_MAP = ["提案力", "資料作成", "顧客理解", "交渉力", "分析力", 
             "リーダーシップ", "コミュニケーション", "計画力", "実行力", "創造力"]

function handler(req)
    if req.method == "GET" && startswith(req.target, "/predict?text=")
        try
            query = HTTP.URI(req.target).query
            text = split(query, "text=")[2]
            
            emb = text_to_embedding(text)
            scores = model(emb)
            top_idx = argmax(scores, dims=1)[1]
            top_skill = SKILL_MAP[top_idx.I[1]]
            
            resp = Dict(
                :text => text,
                :top_skill => top_skill,
                :confidence => round(Float32(scores[top_idx.I[1]]), digits=2),
                :scores => [round(Float32(x), digits=2) for x in scores]
            )
            return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(resp))
        catch e
            return HTTP.Response(400, ["Content-Type" => "application/json"], JSON3.write(Dict("error" => "Invalid query")))
        end
    else
        return HTTP.Response(200, "GrowthTrail AI 🚀\nGET /predict?text=営業資料作成")
    end
end

HTTP.serve(handler, "0.0.0.0", 10000)
println("🚀 GrowthTrail AI + Flux GET /predict ready!")
