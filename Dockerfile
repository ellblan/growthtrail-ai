FROM julia:1.11
WORKDIR /app
COPY . .
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); println("Pkg.instantiate() COMPLETED")'
EXPOSE \$PORT
CMD ["julia", "--project=.", "server.jl"]
