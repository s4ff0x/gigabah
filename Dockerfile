FROM barichello/godot-ci:4.5 AS builder

WORKDIR /GIGABAH
COPY . /GIGABAH

RUN mkdir -p .dist/linux-server
RUN godot --headless --export-release "Linux Server"


FROM debian:bookworm-slim

COPY --from=builder /GIGABAH/.dist/linux-server/linux-dedicated.x86_64 /app/linux-dedicated.x86_64
WORKDIR /app

EXPOSE 25445/udp
EXPOSE 25445/tcp

RUN chmod +x ./linux-dedicated.x86_64

CMD ["./linux-dedicated.x86_64", "--headless", "--server"]
