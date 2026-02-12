FROM julia:1.10-bullseye

ENV JULIA_PROJECT=/app
WORKDIR /app

# ── Node.js 20.x LTS ──────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# ── Backend ────────────────────────────────────
COPY backend/Project.toml backend/Manifest.toml* ./
COPY backend/server.jl backend/model.bson backend/personality_skills_mapping.json ./

# Julia 依存解決（Registry 完全オフライン対応）
# pkg.julialang.org が 404 を返す場合でもビルドを止めないよう
# GitHub リポジトリから直接インストールする
RUN julia -e '\
    using Pkg; \
    ENV["JULIA_PKG_SERVER"] = ""; \
    Pkg.add(url="https://github.com/JuliaWeb/HTTP.jl.git"); \
    Pkg.add(url="https://github.com/JuliaIO/JSON.jl.git"); \
    Pkg.add(url="https://github.com/FluxML/Flux.jl.git"); \
    Pkg.precompile()'

# ── Frontend ───────────────────────────────────
COPY frontend ./frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build
# build 完了後、dist/ は /app/frontend/dist/ に存在
# server.jl は joinpath(@__DIR__, "frontend/dist/") で参照するため移動不要

WORKDIR /app

EXPOSE 8080

CMD ["julia", "server.jl"]
