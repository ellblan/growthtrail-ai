FROM julia:1.11
WORKDIR /app
COPY . .
RUN cp -a .julia/packages /root/.julia/packages
EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
