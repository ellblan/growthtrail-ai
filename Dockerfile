FROM julia:1.11
WORKDIR /app
COPY . .
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'
EXPOSE 10000
CMD ["julia", "--project=.", "server.jl"]
