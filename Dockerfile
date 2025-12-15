FROM julia:1.11
WORKDIR /app
COPY . .
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'
EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
