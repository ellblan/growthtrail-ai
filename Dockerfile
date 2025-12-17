FROM julia:1.11 AS builder
WORKDIR /build
COPY server.jl .
RUN julia --project=. -e 'using Pkg; Pkg.add(["HTTP","JSON3","Flux"]); Pkg.instantiate()'

FROM julia:1.11-slim
WORKDIR /app
COPY --from=builder /root/.julia /root/.julia
COPY server.jl .
EXPOSE $PORT
CMD ["julia", "server.jl"]
