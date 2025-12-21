using Pkg
Pkg.add("HTTP")
Pkg.add("JSON3")
using HTTP, JSON3

HTTP.Handlers.@register route "10000" (
    "/health" => (req) -> HTTP.Response(200, "GrowthTrail AI Live! ✓"),
    "/predict" => (req) -> begin
        body = String(req.body)
        習慣 = parse(Float64, match(r"習慣[:=](\d+\.?\d*)", body)[1].captures[1])
        技術 = parse(Float64, match(r"技術[:=](\d+\.?\d*)", body)[1].captures[1])
        ビジネス = parse(Float64, match(r"ビジネス[:=](\d+\.?\d*)", body)[1].captures[1])
        score = 習慣*0.4 + 技術*0.4 + ビジネス*0.2
        HTTP.Response(200, "{\"成長予測スコア\":$(round(score, digits=2))}")
    end
)
