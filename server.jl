using HTTP

server = HTTP.listen("0.0.0.0", 10000) do req::HTTP.Request
    println("Request: ", req.method, " ", req.target)
    
    if req.method == "GET" && startswith(req.target, "/health")
        return HTTP.Response(200, ["Content-Type" => "text/plain"], "OK")
    elseif startswith(req.target, "/")
        return HTTP.Response(200, ["Content-Type" => "text/plain"], "GrowthTrail AI Ready! 🚀")
    else
        return HTTP.Response(404, ["Content-Type" => "text/plain"], "Not Found")
    end
end

println("🚀 GrowthTrail server listening on 0.0.0.0:10000")
wait(server) 
