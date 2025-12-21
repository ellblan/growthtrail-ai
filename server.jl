# プリインストール前提の最簡易版
HTTP.Handlers.@register route "10000" (
    "/health" => (req) -> HTTP.Response(200, "GrowthTrail AI Live!"),
    "/predict" => (req) -> begin
        body = String(req.body)
        score = parse(Float64, match(r"習慣[:=](\d+)", body)[1]) * 0.4 + 5.0
        HTTP.Response(200, "成長予測: $(round(score, digits=1))")
    end
)
