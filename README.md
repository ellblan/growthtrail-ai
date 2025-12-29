**Julia+Flux → Render失敗記録**

✅ モデル/HTTP.jl動作確認  
❌ HTTP.listen() → main終了 → Docker停止 

原因:「足掻いても現状だとRenderの起動・ヘルスチェックの条件をJulia側で満たせていないこと」

**使用予算:$2.37 → トラブルシュートスキル習得**

# GrowthTrail AI

Julia + Flux.jl で、習慣・技術・ビジネスの成長度をスコアリングするシンプルな機械学習API。
※現在MVPとして開発中

## プロジェクト概要

GrowthTrail AI は、Julia と Flux.jl を用いて、自己評価やテキスト入力などから「習慣」「技術」「ビジネス」の3軸の成長スコアを推定するAPIです。 
学習用の軽量モデルをバックエンドとして、JSON形式の入力を受け取り、成長指標をJSONで返します。

## モデル概要（Flux.jl）

- 入力: 「習慣」「技術」「ビジネス」の自己評価スコア（0.0〜1.0 の数値×3）
- モデル: Flux.jl の全結合ニューラルネットワーク（Dense(3 → 8, relu) → Dense(8 → 3) → softmax）
- 出力: 3つの成長スコア（習慣成長・技術成長・ビジネス成長）の確率分布（合計1.0前後）

## 技術スタック

- Julia 1.11
- Flux.jl（機械学習モデル）
- HTTP.jl（REST APIサーバ）
- JSON3.jl（JSONエンコード/デコード）
- Ubuntu/Linux

## Live API（本番環境）

**POST** ``

- Renderで失敗の為、次に向けて再構想中

## API エンドポイント

本番環境にデプロイされた GrowthTrail AI のエンドポイント:
- ベース URL: 

### /predict

POST /predict
入力(JSON):

```bash
curl -X POST https://growthtrail-ai.onrender.com/predict \
  -H "Content-Type: application/json" \
  -d '{"習慣":0.49,"技術":0.41,"ビジネス":0.4}'
```

出力例(JSON):

```bash
{"ビジネス":0.48,"習慣":0.40,"技術":0.43}
```

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

```bash
{
"習慣成長": 0.52,
"技術成長": 0.30,
"ビジネス成長": 0.18
}
```

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

