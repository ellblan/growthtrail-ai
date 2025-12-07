# mvp.jl（Ubuntu/Linux最適）
using Flux, Random, JSON3

# 超軽量モデル（Ubuntu CPU即動く）
model = Chain(
    Dense(100 => 32, relu),
    Dense(32 => 3, sigmoid)  # [習慣, 技術, ビジネス] 0-1スコア
)

function text_to_vec(text::String)
    # Ubuntu高速ハッシュ→ベクトル（Tokenizer.jl不要）
    h = hash(text, UInt(1234567))
    sin.(0.01f0 * (h .+ (1:100)))  # 決定論的ベクトル
end

# サンプルテスト
test_texts = [
    "毎日コード書く習慣が身についた",
    "Flux.jlでMVP作った", 
    "営業資料作成中"
]

for text in test_texts
    vec = text_to_vec(text)
    scores = model(vec)
    println("$text → 習慣:$(round(scores[1], digits=2)), 技術:$(round(scores[2], digits=2)), ビジネス:$(round(scores[3], digits=2))")
end

println("✅ Ubuntu Flux MVP完成！")
