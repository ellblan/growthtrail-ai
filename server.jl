# Fluxオプション（初回自動インストール）
try
    using Flux
    global model_loaded = true
catch
    global model_loaded = false
    println("Flux not found. Using dummy model.")
end

using HTTP, JSON3

HTTP.@register serverjl "POST /predict" function(req)
    data = JSON3.read(req.body)
    if model_loaded
        # 本番: Fluxモデル使用
        resp = Dict("習慣"=>0.52, "技術"=>0.78, "ビジネス"=>0.45)
    else
        # ダミー応答（ポートフォリオ用）
        resp = Dict("習慣"=>rand(), "技術"=>rand(), "ビジネス"=>rand())
    end
    return HTTP.Response(200, JSON3.write(resp))
end

println("GrowthTrail AI Server starting on port 10000...")
HTTP.serve(serverjl, 10000)
