using HTTP

# モデルロード（別スレッド）
@async begin
    # Fluxモデルロード処理（ここに元のコード）
    println("Model loaded ✓")
end

HTTP.listen("0.0.0.0", 10000) do req
    if req.method == "GET" && startswith(req.target, "/health")
        return HTTP.Response(200, "OK")
    elseif startswith(req.target, "/")
        return HTTP.Response(200, "GrowthTrail AI Ready! 🚀")
    else
        return HTTP.Response(404)
    end
end