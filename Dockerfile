FROM julia:1.11

WORKDIR /app

# 依存ファイルのみ先にコピー（キャッシュ最適化）
COPY Project.toml Manifest.toml ./
RUN julia -e '\
  using Pkg; \
  println("📦 Installing dependencies..."); \
  Pkg.instantiate(); \
  println("✅ Dependencies ready!"); \
  Pkg.precompile(); \
  println("⚡ Precompiled!") \
'

# アプリケーションソース
COPY . .

# Render用設定
ENV PORT=10000
EXPOSE 10000
CMD ["julia", "app.jl"]