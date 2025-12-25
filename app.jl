using HTTP, JSON3, Flux

include("model.jl")
include("preprocess.jl")

SKILL_MAP = ["提案力", "資料作成", "顧客理解", "交渉力", "分析力", 
             "リーダーシップ", "コミュニケーション", "計画力", "実行力", "創造力"]

function handler(req)
    # ヘッダーからContent-Type確認（正しい方法）
    content_type = ""
    for (k, v) in req.headers
        if lowercase(k) == "content-type"
            content_type = lowercase(v)
            break
        end
    end
    
    if req.method == "POST" && startswith(req.target, "/predict") && 
       occursin("application/json", content_type)
        
        body = JSON3.read(String(req.body))
        text = get(body, :text, "テスト")
        
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
    else
        return HTTP.Response(200, text/html, """
        <h1>GrowthTrail AI 🚀</h1>
        <p>POST /predict にJSONを送ってください</p>
        <pre>curl -X POST http://127.0.0.1:8000/predict -H "Content-Type: application/json" -d '{"text": "営業資料作成"}'</pre>
        """)
    end
end

HTTP.serve(handler, "127.0.0.1", 8000)
println("🚀 GrowthTrail AI + Flux /predict ready!")
