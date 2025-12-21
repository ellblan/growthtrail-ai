FROM julia:1.11
WORKDIR /app
COPY server.jl .
RUN julia -e 'using Pkg; Pkg.add(["HTTP","JSON3","Flux"])'
EXPOSE 10000
CMD ["julia", "server.jl"]
