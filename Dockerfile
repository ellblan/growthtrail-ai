# ビルド段階（依存インストール）
FROM julia:1.11 as builder
WORKDIR /app
COPY . .
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); println("✓ Pkg.instantiate() COMPLETED")'

# 実行段階（軽量）
FROM julia:1.11
WORKDIR /app
COPY --from=builder /usr/local/julia /usr/local/julia
COPY --from=builder /app /app
EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
