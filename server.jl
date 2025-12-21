using HTTP

HTTP.listen("0.0.0.0", 80) do stream  # ポート80に変更
    line = readline(stream)
    if occursin("/health", line)
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
