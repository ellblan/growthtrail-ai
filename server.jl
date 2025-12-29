using HTTP

# 1. サーバーオブジェクト取得
server = HTTP.listen("0.0.0.0", 10000)

# 2. ハンドラ登録（コールバックじゃない）
HTTP.@register server "GET /health" HTTP.Response(200, "OK")
HTTP.@register server "GET /"       HTTP.Response(200, "Ready")

println("Server live!")
wait(server)  # Serverオブジェクトを待機
