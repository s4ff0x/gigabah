FROM debian:bookworm-slim

# RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
#     apt-get update && \
#     apt-get install -y libc6 openssl && \
#     rm -rf /var/lib/apt/lists/*

COPY .dist/linux-server/linux-dedicated.x86_64 /usr/local/bin/linux-dedicated.x86_64

EXPOSE 25445/udp
EXPOSE 25445/tcp
CMD [ "linux-dedicated.x86_64" ]