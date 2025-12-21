FROM julia:1.11
WORKDIR /app
COPY server.jl .
RUN julia -e 'using Pkg; Pkg.add("HTTP"); Pkg.add("JSON3")'
EXPOSE 10000
CMD ["julia", "server.jl"]
