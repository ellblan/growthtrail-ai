using HTTP, JSON3

HTTP.@register serverjl "POST /predict" function(req)
    data = JSON3.read(req.body)
    # ポートフォリオ用ダミー応答（Fluxなし）
    resp = Dict("習慣"=>round(rand()*0.1+0.4; digits=2), 
                "技術"=>round(rand()*0.1+0.4; digits=2), 
                "ビジネス"=>round(rand()*0.1+0.4; digits=2))
    return HTTP.Response(200, JSON3.write(resp))
end

print("GrowthTrail AI Server starting on port 10000...")
HTTP.serve(serverjl, 10000)
