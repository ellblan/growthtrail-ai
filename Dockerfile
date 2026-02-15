FROM julia:1.10-bullseye

ENV JULIA_PROJECT=/app
WORKDIR /app

# ── システム依存 ─────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates git && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# ── Backend ────────────────────────────────────
COPY backend/server.jl backend/model.bson backend/personality_skills_mapping.json ./

# Julia 依存解決
# 1) Registry を shallow clone（full clone は ~700MB でハングする）
# 2) HTTP, JSON: API サーバー用
# 3) Flux, BSON: モデルロード + CPU 推論用（CUDA 不要）
RUN git clone --depth 1 https://github.com/JuliaRegistries/General.git \
        /root/.julia/registries/General && \
    julia -e '\
        using Pkg; \
        Pkg.add(["HTTP", "JSON", "Flux", "BSON"]); \
        Pkg.precompile()' && \
    julia -e '\
        using HTTP; using JSON; using Flux; using BSON; \
        println("✓ using warmup OK")'

# ── Frontend ───────────────────────────────────
COPY frontend ./frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

WORKDIR /app

EXPOSE 8080

# Julia GC を 2GB 環境に最適化
# Flux ロード後の安定メモリ: ~700-800MB
# --heap-size-hint: GC がこのサイズ付近でアグレッシブに回収
ENV JULIA_NUM_THREADS=1

CMD ["julia", "--heap-size-hint=800M", "server.jl"]
