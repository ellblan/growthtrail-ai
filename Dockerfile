FROM julia:1.11
WORKDIR /app

# 全ファイルコピー
COPY . .

# プリコンパイル無効化（Renderメモリ不足対策）
ENV JULIA_CPU_TARGET="native"
RUN julia --project=. -e '
  using Pkg; 
  Pkg.instantiate();
  println("✓ ALL PACKAGES INSTALLED");
  exit(0);
'

EXPOSE $PORT
CMD ["julia", "--project=.", "server.jl"]
