using Flux
using WordTokenizers  # pip install 相当

function text_to_embedding(text::String)
    # 簡易トークン化 + 固定長ベクトル（model.jl対応）
    tokens = tokenize.(text) |> first |> split
    emb = rand(Float32, 128, 1)  # 後でBERT等に置き換え
    return emb
end

# テスト
input_text = "営業資料作成"
dummy_emb = text_to_embedding(input_text)
println("Text embedding ready: ", size(dummy_emb))
