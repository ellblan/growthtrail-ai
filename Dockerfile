FROM julia:1.11

# 作業フォルダを/appに設定
WORKDIR /app

# 全部のソースをコピー（app.jl, model.jl, preprocess.jlなど）
COPY . .

# 依存パッケージをセットアップ（Fluxなどが含まれる）
RUN julia -e 'using Pkg; Pkg.instantiate()'

# Render用ポート
ENV PORT=10000
EXPOSE 10000

# Flux統合版を実行！
CMD ["julia", "app.jl"]
