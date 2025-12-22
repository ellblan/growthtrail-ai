using HTTP

HTTP.listen("0.0.0.0", 10000) do stream  # Renderが自動検知
    line = readline(stream)
    
    # パス判定
    if occursin("/health", line)
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
