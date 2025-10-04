# Multi-stage build for Godot 4.5 game server

# Stage 1: Export the game
FROM ubuntu:22.04 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Godot 4.5 standard binary for exporting
WORKDIR /godot
RUN wget https://github.com/godotengine/godot-builds/releases/download/4.5-stable/Godot_v4.5-stable_linux.x86_64.zip && \
    unzip Godot_v4.5-stable_linux.x86_64.zip && \
    rm Godot_v4.5-stable_linux.x86_64.zip && \
    mv Godot_v4.5-stable_linux.x86_64 godot && \
    chmod +x godot

# Install Godot 4.5 export templates (matching engine version)
RUN wget https://github.com/godotengine/godot-builds/releases/download/4.5-stable/Godot_v4.5-stable_export_templates.tpz && \
    mkdir -p /root/.local/share/godot/export_templates/4.5.stable && \
    unzip Godot_v4.5-stable_export_templates.tpz && \
    mv templates/* /root/.local/share/godot/export_templates/4.5.stable/ && \
    rm -rf templates Godot_v4.5-stable_export_templates.tpz

# Copy game source
WORKDIR /game
COPY . .

# Create export directory
RUN mkdir -p .dist/linux-server

# Export the game using your existing "Linux Server" preset
RUN /godot/godot --headless --verbose --export-release "Linux Server" .dist/linux-server/linux-dedicated.x86_64

# Verify the export was successful
RUN echo "Verifying export..." && \
    ls -lah .dist/linux-server/ && \
    test -f .dist/linux-server/linux-dedicated.x86_64 && \
    echo "Export successful!" || \
    (echo "ERROR: Export failed - executable not found!" && exit 1)

# Stage 2: Runtime container
FROM ubuntu:22.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libgl1 \
    libglu1-mesa \
    libasound2 \
    libpulse0 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -m -u 1000 gameserver && \
    mkdir -p /game && \
    chown -R gameserver:gameserver /game

WORKDIR /game

# Copy exported game from builder stage
COPY --from=builder --chown=gameserver:gameserver /game/.dist/linux-server/linux-dedicated.x86_64 ./game_server

# Make executable
RUN chmod +x game_server

# Switch to non-root user
USER gameserver

# Railway will provide PORT environment variable (default to 8080)
ENV PORT=8080

# Expose the default port (Railway maps the actual runtime port)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pidof game_server || exit 1

# Run the game server with verbose output for debugging
CMD ["sh", "-c", "echo 'Starting server on port $PORT...' && ./game_server --headless --verbose"]

