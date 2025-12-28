using HTTP

HTTP.listen("0.0.0.0", 10000) do http::HTTP.Stream
    @show http.message.method
    @show http.message.target
    
    if http.message.method == "GET" && startswith(http.message.target, "/health")
        HTTP.setstatus!(http, 200)  # ← ! 追加
        HTTP.startwrite(http, HTTP.Response(200, ["Content-Type" => "text/plain"], "GrowthTrail AI Live! ✓"))
    elseif startswith(http.message.target, "/")
        HTTP.setstatus!(http, 200)
        HTTP.startwrite(http, HTTP.Response(200, ["Content-Type" => "text/plain"], "GrowthTrail AI Ready! 🚀"))
    else
        HTTP.setstatus!(http, 404)
        HTTP.startwrite(http, HTTP.Response(404, ["Content-Type" => "text/plain"], "Not Found"))
    end
end
