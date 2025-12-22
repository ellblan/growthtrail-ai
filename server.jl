using HTTP

HTTP.listen("0.0.0.0", 10000) do stream
    line = readline(stream)
    
    # 文字列直接検索（100%確実）
    if contains(line, "GET") && contains(line, "/health")
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
