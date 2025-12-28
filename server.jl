using HTTP

HTTP.listen("0.0.0.0", 10000) do req
    @show req.method
    @show req.target
    
    if req.method == "GET" && startswith(req.target, "/health")
        return HTTP.Response(200, ["Content-Type" => "text/plain"], "GrowthTrail AI Live! ✓")
    elseif startswith(req.target, "/")
        return HTTP.Response(200, ["Content-Type" => "text/plain"], "GrowthTrail AI Ready! 🚀")
    else
        return HTTP.Response(404, ["Content-Type" => "text/plain"], "Not Found")
    end
end
EOF

git add server.jl
git commit -m "Fix HTTP handler: use req instead of Stream"
git push origin main