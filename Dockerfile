FROM julia:1.10-slim
WORKDIR /app
COPY Project.toml app.jl .
CMD ["julia", "app.jl"]