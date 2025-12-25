using Flux
using JSON3  # API用

# スキル分類モデル（仮: テキスト埋め込み128→スキル10クラス）
model = Chain(
    Dense(128, 64, relu),
    Dense(64, 32, relu),
    Dense(32, 10),  # スキル数に応じて調整
    softmax
)

# ダミー推論テスト
dummy_input = rand(Float32, 128, 1)  # テキスト埋め込み想定
prediction = model(dummy_input)
skills = argmax(prediction, dims=1)  # Topスキル抽出

println("Model loaded ✓")
println("Dummy prediction: ", skills)
