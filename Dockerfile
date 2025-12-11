FROM julia:1.11

WORKDIR /app

# まず依存定義だけコピー
COPY Project.toml Manifest.toml ./

# プロジェクト環境に従ってパッケージをインストール
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

# 残りのソースをコピー
COPY . .

EXPOSE 10000

# プロジェクト環境を有効にしてサーバ起動
CMD ["julia", "--project=.", "server.jl"]
