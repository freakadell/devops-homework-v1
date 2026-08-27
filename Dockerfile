# Stage 1: Preparation
FROM debian:12-slim AS builder

# Copy code into a temporary directory
COPY index.html /tmp/index.html

# Set permissions to Chainguard's nonroot user (65532)
RUN chown 65532:65532 /tmp/index.html

# Stage 2: Final image (Distroless)
FROM cgr.dev/chainguard/nginx:latest

# Copy only your web assets with correct Chainguard permissions
COPY --from=builder --chown=65532:65532 /tmp/index.html /usr/share/nginx/html/index.html

# Chainguard natively listens on 8080 and handles all internal directories/logs
EXPOSE 8080
