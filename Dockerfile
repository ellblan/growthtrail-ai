FROM julia:1.11

WORKDIR /app

# デバッグ：何がコピーされたか確認
RUN echo "=== Files in context ===" && ls -la

# 依存ファイル必須コピー
COPY Project.toml ./ || echo "❌ Project.toml MISSING"
COPY Manifest.toml ./ || echo "Manifest.toml optional"
RUN ls -la *.toml || echo "❌ NO TOML FILES"

# Pkgインストール（詳細ログ）
RUN julia -e '\
  using Pkg; \
  println("=== Starting Pkg.instantiate ==="); \
  Pkg.instantiate(); \
  Pkg.precompile(); \
  println("=== Packages installed ==="); \
  Pkg.status(); \
  println("✓ SUCCESS") \
'

COPY . .

ENV PORT=10000
EXPOSE 10000
CMD ["julia", "app.jl"]
EOF