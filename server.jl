HTTP.Handlers.@register route "10000" (
    "/health" => (req) -> HTTP.Response(200, "healthy OK"),
    "/predict" => (req) -> begin
        body = JSON3.read(req.body)
        score = body.習慣*0.4 + body.技術*0.4 + body.ビジネス*0.2
        HTTP.Response(200, "成長予測: $(round(score, digits=2))")
    end
)