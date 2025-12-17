FROM julia:1.11
WORKDIR /app
COPY . .
EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
