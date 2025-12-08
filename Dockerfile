FROM julia:1.11
WORKDIR /app
COPY . .
RUN julia -e 'using Pkg; Pkg.add(["HTTP","JSON3","Flux"]); Pkg.precompile()'
EXPOSE 10000
CMD ["julia", "--project=.", "server.jl"]
