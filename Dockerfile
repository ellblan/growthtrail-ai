FROM julia:1.11 AS builder
WORKDIR /app
COPY Project.toml Manifest.toml ./
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

FROM julia:1.11-slim
WORKDIR /app
COPY --from=builder /root/.julia /root/.julia
COPY server.jl .
EXPOSE 10000
CMD ["julia", "--project=.", "server.jl"]