# GrowthTrail AI

Julia + Flux.jl で、習慣・技術・ビジネスの成長度をスコアリングするシンプルな機械学習API。
※現在MVPとして開発中

## プロジェクト概要

GrowthTrail AI は、Julia と Flux.jl を用いて、自己評価やテキスト入力などから「習慣」「技術」「ビジネス」の3軸の成長スコアを推定するAPIです。 
学習用の軽量モデルをバックエンドとして、JSON形式の入力を受け取り、成長指標をJSONで返します。

## 技術スタック

- Julia 1.11
- Flux.jl（機械学習モデル）
- HTTP.jl（REST APIサーバ）
- JSON3.jl（JSONエンコード/デコード）
- Ubuntu/Linux
- Render.com（本番デプロイ）

## Live API（本番環境）

**POST** `https://growthtrail-ai.onrender.com/predict`

- Request / Response は JSON 形式 
- Day3 時点で、Flux.jl + HTTP.jl + Render.com の無料デプロイまで完了しています。

## エンドポイント一覧

- GET `/health` : 稼働確認用のヘルスチェック（`{"status":"ok"}` を返す）
- POST `/predict` : 習慣・技術・ビジネスの自己評価スコアから成長度を推定する

## curl での利用例（本番）

```bash
curl -X POST https://growthtrail-ai.onrender.com/predict \
  -H "Content-Type: application/json" \
  -d '{"習慣":0.49,"技術":0.41,"ビジネス":0.4}'
```

## 想定されるレスポンス例（イメージ）:

{
"習慣成長": 0.52,
"技術成長": 0.30,
"ビジネス成長": 0.18
}

## ローカル開発用デモ（テキスト入力）

```bash
curl -X POST http://localhost:8000/predict
-H "Content-Type: application/json"
-d '{"text":"毎日コード書く習慣が身についた"}'
```

## 結果例（イメージ）:

- 習慣: 0.52 
- 技術: 0.52 
- ビジネス: 0.51
