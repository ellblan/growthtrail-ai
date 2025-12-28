FROM julia:1.11
WORKDIR /app
COPY . .
RUN julia -e "using Pkg; Pkg.Registry.update(); Pkg.add([\"HTTP\",\"JSON3\",\"Flux\",\"WordTokenizers']); println(\"ALL PACKAGES INSTALLED\"); Pkg.precompile();"
ENV PORT=10000
EXPOSE 10000
CMD ["julia", "app.jl"]