using HTTP, JSON3, Flux

# 最小Fluxモデル（ローカルで動作確認）
model = Flux.Chain(
    Flux.Dense(3, 16, relu),
    Flux.Dense(16, 1)
) |> Flux.cpu  # GPUなし

# 学習済み重み（仮、数値のみ）
Flux.loadparams!(model, [0.1f0, 0.2f0...])  # 最小重み

HTTP.Handlers.@register route "10000" (
    "/health" => (req) -> HTTP.Response(200, JSON3.write({"status" => "healthy"})),
    "/predict" => (req) -> begin
        body = JSON3.read(req.body)
        input = [body.習慣, body.技術, body.ビジネス]
        pred = model(input)[1] |> Float32
        HTTP.Response(200, JSON3.write(Dict("成長予測スコア" => pred)))
    end
)
