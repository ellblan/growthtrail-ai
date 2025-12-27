FROM julia:1.11

WORKDIR /app

COPY Project.toml Manifest.toml ./
RUN julia -e 'using Pkg; Pkg.instantiate(); Pkg.precompile();'

COPY . .

ENV PORT=10000
EXPOSE 10000
CMD ["julia", "app.jl"]
