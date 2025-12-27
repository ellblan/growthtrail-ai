# ベースイメージ
FROM julia:1.11

# 作業ディレクトリを指定
WORKDIR /app

# プロジェクト全体をコピー
COPY . .

# 依存関係をProject.toml/Manifest.tomlから確実にインストール
RUN julia -e 'using Pkg; Pkg.instantiate(); Pkg.precompile();'

# Render向けポート設定
ENV PORT=10000
EXPOSE 10000

# app.jlを起動 (Flux統合サーバ)
CMD ["julia", "app.jl"]
