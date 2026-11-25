FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libsqlite3-dev zlib1g-dev git ca-certificates && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch 2.79.0 https://github.com/felt/tippecanoe.git /src && cd /src && make -j"$(nproc)" && make install && rm -rf /src
WORKDIR /data
