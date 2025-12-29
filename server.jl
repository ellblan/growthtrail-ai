cat > server.jl << 'EOF'
using HTTP

function handler(req)
    req.target == "/health" && return HTTP.Response(200, "OK")
    HTTP.Response(404)
end

server = HTTP.listen("0.0.0.0", 10000, handler)
println("Server live!")
wait(server)
EOF

git add server.jl && git commit -m "Step2: HTTP.listen(port, handler)形式" && git push
