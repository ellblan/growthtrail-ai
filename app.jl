using Sockets

port = parse(Int, get(ENV, "PORT", "10000"))
println("GrowthTrail minimal server on port $port")

server = listen(IPv4(0, 0), port)

while true
    sock = accept(server)
    @async begin
        write(sock, "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nGrowthTrail Live! ✓\r\n")
        close(sock)
    end
end