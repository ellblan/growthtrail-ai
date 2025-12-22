using HTTP

HTTP.listen("0.0.0.0", 10000) do http::HTTP.Stream
    @show http.message.method
    @show http.message.target
    
    # 公式HTTP.Stream形式で判定
    if http.message.method == "GET" && startswith(http.message.target, "/health")
        HTTP.setstatus(http, 200)
        HTTP.startwrite(http)
        write(http, "GrowthTrail AI Live! ✓")
    else
        HTTP.setstatus(http, 404)
        HTTP.startwrite(http)
        write(http, "Not Found")
    end
end
