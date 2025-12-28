FROM julia:1.11
WORKDIR /app
COPY . .
RUN julia -e "
  using Pkg;
  Pkg.Registry.update();
  Pkg.add('HTTP');
  Pkg.add('JSON3');
  Pkg.add('Flux');
  println('✅ ALL PACKAGES INSTALLED');
"
ENV PORT=10000
EXPOSE 10000
CMD ["julia", "app.jl"]
EOF