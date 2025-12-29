**Julia+Flux → Render失敗記録**

- Phase 0: Fluxモデル → "Application exited early" ❌
- Phase 1: Starter 512MB + /health → 502 Timeout ❌  
- Phase 2: Standard 2GB → exited early ❌
- Phase 3: 超ミニマルserver.jl → exited early ❌
- Phase 4: handler + wait(server) → **デプロイ中** ❌

原因:「Render + Julia構造的不適合」→様々試したがRenderをある程度理解でき、別の環境下で開発行うほうがいいと理解できた為。

✅ PID1監視診断 → DevOps証明
✅ HTTP.jl Task構造完全理解  
✅ Render構造的限界特定

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

