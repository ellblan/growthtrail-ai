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
# 2) server.jl の実行に必要な HTTP + JSON のみインストール
#    Flux は train.jl 用のため Docker ランタイムでは不要
RUN git clone --depth 1 https://github.com/JuliaRegistries/General.git \
        /root/.julia/registries/General && \
    julia -e '\
        using Pkg; \
        Pkg.add(["HTTP", "JSON"]); \
        Pkg.precompile()'

# ── Frontend ───────────────────────────────────
COPY frontend ./frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

WORKDIR /app

EXPOSE 8080

CMD ["julia", "server.jl"]
