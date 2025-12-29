using HTTP

# Renderが即認識する最短サーバー
HTTP.listen("0.0.0.0", 10000) do req::HTTP.Request
    if startswith(req.target, "/health")
        return HTTP.Response(200, ["Content-Type" => "text/plain"], "OK")
    end
    return HTTP.Response(200, ["Content-Type" => "text/plain"], "GrowthTrail Ready!")
end

println("Server started on 0.0.0.0:10000")