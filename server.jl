using HTTP

HTTP.listen("0.0.0.0", 10000) do stream::HTTP.Stream
    reqs = HTTP.read(stream)
    req = reqs[1]
    
    if HTTP.URI(req.target).path == "/health"
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
