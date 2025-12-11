FROM julia:1.11

# アプリ一式をコピー（Project.toml/Manifest.toml/server.jl など）
WORKDIR /app
COPY . .

# プロジェクト環境に従ってパッケージをインストール
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

EXPOSE 10000

# プロジェクト環境を有効にしてサーバ起動
CMD ["julia", "--project=.", "server.jl"]
