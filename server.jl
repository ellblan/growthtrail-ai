using HTTP

HTTP.listen("0.0.0.0", 10000) do stream::HTTP.Stream
    req = HTTP.read(stream)
    
    if req.target == "/health"
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    elseif req.target == "/predict"
        body = String(req.body)
        習慣 = parse(Float64, match(r"習慣[:=](\d+\.?\d*)", body).captures[1])
        技術 = parse(Float64, match(r"技術[:=](\d+\.?\d*)", body).captures[1])
        ビジネス = parse(Float64, match(r"ビジネス[:=](\d+\.?\d*)", body).captures[1])
        score = 習慣*0.4 + 技術*0.4 + ビジネス*0.2
        HTTP.write(stream, HTTP.Response(200, "{\"成長予測スコア\":$(round(score, digits=2))}"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
    
    HTTP.close(stream)
end
