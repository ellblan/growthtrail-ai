using HTTP, JSON3, Flux
include("mvp.jl")

HTTP.listen("127.0.0.1", 8000) do req::HTTP.Request
    if req.method == "POST" && endswith(req.target, "/predict") && HTTP.hasheader(req, "Content-Type", "application/json")
        body = JSON3.read(String(req.body))
        text = get(body, :text, "テスト")
        vec = text_to_vec(text)
        scores = model(vec)
        resp = Dict(:text=>text, :skills=>Dict("習慣"=>round(scores[1],digits=2),"技術"=>round(scores[2],digits=2),"ビジネス"=>round(scores[3],digits=2)))
        HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(resp))
    else
        HTTP.Response(200, "GrowthTrail AI 🚀\nPOST http://127.0.0.1:8000/predict {\"text\":\"テスト\"}")
    end
end
