FROM julia:1.10-bullseye

ENV JULIA_PROJECT=/app

WORKDIR /app

COPY Project.toml .
COPY Manifest.toml .

RUN julia -e 'using Pkg; Pkg.instantiate()'

COPY server.jl .
COPY model.bson .

EXPOSE 8081

CMD ["julia", "server.jl"]
