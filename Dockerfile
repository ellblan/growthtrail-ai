FROM julia:1.10-bullseye

ENV JULIA_PROJECT=/app
WORKDIR /app

RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

COPY Project.toml .
COPY Manifest.toml .
RUN julia -e 'using Pkg; Pkg.instantiate()'

COPY server.jl .
COPY model.bson .

COPY frontend ./frontend
WORKDIR /app/frontend

RUN npm install
RUN npm run build   # dist/ が生成される

WORKDIR /app

EXPOSE 8081

CMD ["julia", "server.jl"]
