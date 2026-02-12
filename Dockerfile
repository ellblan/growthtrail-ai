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
COPY backend/Project.toml .
COPY backend/Manifest.toml .
COPY backend/server.jl .
COPY backend/model.bson .
COPY backend/personality_skills_mapping.json .

# Julia 依存解決（レジストリ 404 でもビルドを止めない）
RUN julia -e '\
    using Pkg; \
    try \
        Pkg.instantiate(); \
    catch e \
        @warn "Pkg.instantiate() failed — skipping" exception=e \
    end'

# ── Frontend ───────────────────────────────────
COPY frontend ./frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build
# build 完了後、dist/ は /app/frontend/dist/ に存在
# server.jl は joinpath(@__DIR__, "frontend/dist/") で参照するため移動不要

WORKDIR /app

EXPOSE 8081

CMD ["julia", "server.jl"]
