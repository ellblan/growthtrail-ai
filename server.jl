using HTTP

HTTP.listen("0.0.0.0", 10000) do stream
    line = readline(stream)
    
    # /health判定強化
    if occursin(r"GET\s+/health", line) || occursin(r"HEAD\s+/health", line)
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
