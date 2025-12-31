FROM julia:1.10
WORKDIR /app
COPY . .
RUN julia -e 'using Pkg; Pkg.add("HTTP")'
CMD ["julia", "app.jl"]