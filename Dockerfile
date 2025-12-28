FROM julia:1.11
WORKDIR /app
COPY . .
RUN julia -e "using Pkg; Pkg.Registry.update(); Pkg.activate(\".\"); Pkg.add([\"HTTP\",\"JSON3\",\"Flux\",\"WordTokenizers\"]); Pkg.precompile();" \
    && echo \"PORT=10000 tcp://0.0.0.0:10000\" > /tmp/port.info
ENV PORT=10000
EXPOSE 10000
CMD ["julia", "--project=.", "app.jl"]
