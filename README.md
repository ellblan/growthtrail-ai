# GrowthTrail AI
GrowthTrail AI は、**Julia + Flux.jl** をメインに用いて
「習慣」「技術」「ビジネス」の成長度をスコアリングする
軽量な機械学習 API ＋ Web フロントエンドのフルスタックプロジェクトです。

目的は **「個々の深層意識から来る思考、行動、癖、言動を分析、ビジネススキルへ転換・昇華していく」** 事になります。
最終的なゴールは、
**「企業・団体に対して、個々の可能性を提示し、既存の採用フローに“深層意識の成長予測”を組み込んだ新しいマッチング可視化を提供する」** 
ことを目指しています。

現在は **Lightsail + GitHub Actions** を用いた本番環境デプロイに向けて開発中です。

## 📁 プロジェクト構成

✅ growthtrail-ai/
✅ backend/   ← Julia + Flux.jl  の API サーバ
✅ frontend/  ← Next.js  / React の Web UI

- **backend**  
  - Julia 1.11  
  - Flux.jl（ML モデル）  
  - HTTP.jl（REST API）  
  - JSON3.jl（JSON パーサ）  

- **frontend**  
  - Next.js
  - React  
  - TypeScript
  - Tailwind CSS（予定）
  - API と連携して成長スコアを可視化  

---

## API 概要（backend）

### モデル概要（Flux.jl）

- **入力**  
  - 「習慣」「技術」「ビジネス」  
  - 0.0〜1.0 の数値 × 3

- **モデル構造**  
  - Dense(3 → 8, relu)  
  - Dense(8 → 3)  
  - softmax

- **出力**  
  - 3つの成長スコア（確率分布）

---

## API エンドポイント

### GET `/health`
稼働確認用

レスポンス例:
json
{"status": "ok"}

## POST

自己評価スコアから成長度を推定する
※今後モデル改良に伴い変化予定

入力例
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"習慣":0.49,"技術":0.41,"ビジネス":0.40}'
```

出力例
```bash
{
  "習慣成長": 0.52,
  "技術成長": 0.30,
  "ビジネス成長": 0.18
}
```

## ローカル開発（テキスト入力デモ）
```bash
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"習慣":0.49,"技術":0.41,"ビジネス":0.40}'
```

## 開発の歴史

GrowthTrail AI は最初 Render でデプロイを試みたが、
Julia の構造的な相性問題により複数の段階で失敗。

これは自分の成長の記録として残しておきます。

- Julia + Flux → Render 失敗記録
  - Phase 0: Fluxモデル → "Application exited early" ❌
  - Phase 1: Starter 512MB + /health → 502 Timeout ❌
  - Phase 2: Standard 2GB → exited early ❌
  - Phase 3: 超ミニマル server.jl  → exited early ❌
  - Phase 4: handler + wait(server) → デプロイ中 ❌

原因:  
Render のコンテナ構造と Julia のプロセスモデルが根本的に相性が悪い。

得られた学び
・PID1 監視の仕組みを理解
・HTTP.jl  の Task 構造を深く理解
・Render の構造的限界を把握
・$2.37 の予算で DevOps スキルを獲得

## 今後の予定

・Lightsail での本番デプロイ
・GitHub Actions による自動デプロイ
・モデルの改良（特徴量追加）
・フロントエンドの UI 改善
・Docker 化（任意）
