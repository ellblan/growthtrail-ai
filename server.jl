using HTTP

HTTP.listen("0.0.0.0", 10000) do stream::HTTP.Stream
    while !eof(stream)
        req = HTTP.request(stream)
        path = HTTP.URI(req.target).path
        
        if path == "/health"
            HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
        else
            HTTP.write(stream, HTTP.Response(404, "Not Found"))
        end
    end
    HTTP.close(stream)
end
