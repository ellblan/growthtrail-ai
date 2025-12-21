using HTTP

HTTP.listen("0.0.0.0", 10000) do stream::HTTP.Stream
    # リクエスト読み込み
    line = readline(stream)
    
    # /healthなら成功応答
    if occursin("/health", line)
        HTTP.write(stream, HTTP.Response(200, "GrowthTrail AI Live! ✓"))
    else
        HTTP.write(stream, HTTP.Response(404, "Not Found"))
    end
end
