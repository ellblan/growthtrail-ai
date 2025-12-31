FROM julia:1.10
WORKDIR /app
COPY . .
CMD ["julia", "app.jl"]