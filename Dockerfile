FROM julia:1.11
WORKDIR /app

# ☆ここが重要：ソース一式をコピー
COPY . .

# これで /app/Project.toml が存在する
RUN julia -e 'using Pkg; Pkg.instantiate(); Pkg.precompile();'

ENV PORT=10000
EXPOSE 10000

CMD ["julia", "app.jl"]
