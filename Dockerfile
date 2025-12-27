FROM julia:1.11

WORKDIR /app

# 必須：依存ファイルを先にコピー
COPY Project.toml Manifest.toml* ./
RUN julia -e '\
  using Pkg; \
  Pkg.instantiate(); \
  Pkg.precompile(); \
  println("✓ Dependencies installed") \
'

# ソースコード
COPY . .

ENV PORT=10000
EXPOSE 10000
CMD ["julia", "app.jl"]
EOF
