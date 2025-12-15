FROM julia:1.11
WORKDIR /app

# 1. 全ファイルコピー（Project.toml含む）
COPY . .

# 2. 環境変数設定（Render必須）
ENV JULIA_DEPOT_PATH=/app/.julia

# 3. プロジェクトアクティブ化＋即時インストール
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); println("✓ ALL PACKAGES INSTALLED")'

EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
