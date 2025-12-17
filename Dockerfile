FROM julia:1.11
WORKDIR /app

COPY . .

ENV JULIA_CPU_TARGET="native"

# プリコンパイル無効＋確実インストール
RUN julia --project=. -e "using Pkg; Pkg.instantiate(); println(\"✓ ALL PACKAGES INSTALLED\")"

EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
