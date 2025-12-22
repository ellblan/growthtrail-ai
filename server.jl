using HTTP

HTTP.listen("0.0.0.0", 10000) do stream
    line = readline(stream)
    
    # GET/HEAD + スペース対応
    if occursin(r"(GET|HEAD)\s+/health", line)
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
