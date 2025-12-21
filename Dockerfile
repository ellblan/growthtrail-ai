FROM julia:1.11
WORKDIR /app
COPY server.jl .
RUN julia -e 'using Pkg; Pkg.add("HTTP"); sleep(3); Pkg.add("JSON3"); sleep(3); Pkg.add("Flux")'
EXPOSE 10000
CMD ["julia", "server.jl"]
