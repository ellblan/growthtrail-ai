using HTTP, JSON3

HTTP.Handlers.@register route "10000" (
    "/health" => (req) -> HTTP.Response(200, JSON3.write({"status" => "healthy"})),
    "/predict" => (req) -> begin
        body = JSON3.read(req.body)
        # ルールベース成長予測（Flux復活まで）
        score = min(10.0, body.習慣*0.4 + body.技術*0.4 + body.ビジネス*0.2)
        HTTP.Response(200, JSON3.write(Dict("成長予測スコア" => round(score, digits=2))))
    end
)
