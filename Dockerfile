FROM julia:1.11

WORKDIR /app

# まず依存定義だけコピー
COPY Project.toml Manifest.toml ./

# 既存のコンパイルキャッシュを消してから Pkg を実行
RUN rm -rf /root/.julia/compiled && \
    julia --startup-file=no --project=. -e 'using Pkg; Pkg.instantiate()'

# 残りのソースをコピー
COPY . .

EXPOSE 10000

CMD ["julia", "--project=.", "server.jl"]
