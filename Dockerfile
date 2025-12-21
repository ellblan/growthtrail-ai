FROM julia:1.11
RUN julia -e 'using Pkg; Pkg.add("HTTP"); Pkg.add("JSON3"); Pkg.precompile()'
WORKDIR /app
COPY server.jl .
EXPOSE 10000
CMD ["julia", "server.jl"]
