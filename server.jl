using HTTP

HTTP.listen("0.0.0.0", 10000) do stream::HTTP.Stream
    reqs = HTTP.read(stream)
    
    # 空配列チェック
    if isempty(reqs)
        HTTP.write(stream, HTTP.Response(200, "Empty request"))
        return
    end
    
    req = reqs[1]
    path = HTTP.URI(req.target).path
    
    if path == "/health"
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
