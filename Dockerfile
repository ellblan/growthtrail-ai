FROM julia:1.11
WORKDIR /app
COPY Project.toml Manifest.toml ./
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'
COPY server.jl .
EXPOSE 10000
CMD ["julia", "--project=.", "server.jl"]
