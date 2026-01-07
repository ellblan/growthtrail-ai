using JSON
using Flux
using BSON: @save

# 1. 学習データを読み込む
data = JSON.parsefile("training_data.json")

# 2. 特徴量（X）とラベル（Y）を作る
X = [Float32[length(d["text"])] for d in data]
Y = [Float32[d["positivity"], d["energy"], d["stress"]] for d in data]

# 3. モデル定義
model = Chain(
    Dense(1, 8, relu),
    Dense(8, 3),
    σ
)

# 4. 損失関数
loss(model, x, y) = Flux.Losses.mse(model(x), y)

# 5. Optimizer
opt = Flux.setup(Adam(), model)

# 6. 学習ループ
for epoch in 1:500
    for (x, y) in zip(X, Y)
        gs = gradient(model -> loss(model, x, y), model)
        Flux.update!(opt, model, gs)
    end
end

# 7. モデル保存
@save "model.bson" model
println("Model saved to model.bson")
