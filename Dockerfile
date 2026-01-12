FROM julia:1.10-bullseye

ENV JULIA_PROJECT=/app
WORKDIR /app

RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

COPY backend/Project.toml .
COPY backend/Manifest.toml .
COPY backend/server.jl .
COPY backend/model.bson .

RUN julia -e 'using Pkg; Pkg.instantiate()'

COPY frontend ./frontend
WORKDIR /app/frontend

RUN npm install
RUN npm run build   # dist/ が生成される

WORKDIR /app
COPY --from=0 /app/frontend/dist ./dist

EXPOSE 8081

CMD ["julia", "server.jl"]
