FROM julia:1.11
WORKDIR /app
COPY server.jl .
RUN julia -e 'using Pkg; Pkg.add(["HTTP","JSON3","Flux"]); Pkg.precompile()'
EXPOSE 10000
CMD ["julia", "server.jl"]
