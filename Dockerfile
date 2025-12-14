FROM julia:1.11

WORKDIR /app

# アプリ一式をコピー
COPY . .

EXPOSE 10000

# 起動時に環境を整えてからサーバを立ち上げる
CMD ["julia", "--project=.", "-e", "using Pkg; Pkg.instantiate(); include(\"server.jl\")"]

EXPOSE 10000