using HTTP

# Render PORT対応（デフォルト10000）
port = parse(Int, get(ENV, "PORT", "10000"))
println("Starting GrowthTrail on port $port")

HTTP.listen("0.0.0.0", port) do req::HTTP.Request
    HTTP.Response(200, "GrowthTrail Live! ✓")