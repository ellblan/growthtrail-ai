FROM julia:1.11
WORKDIR /app
COPY Project.toml .
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'
COPY . .
EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
