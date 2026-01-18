# =========================
# Builder stage
# =========================
FROM golang:1.25.1-alpine AS builder

# Install git for go modules that use it
RUN apk add --no-cache git

# Work inside /src
WORKDIR /src

# Copy go module files first for better caching
COPY app/go.mod app/go.sum ./
RUN go mod download || true

# Copy the rest of the application source
COPY app/ ./

# Build the binary (main is in cmd/api)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o muchtodo ./cmd/api

# =========================
# Runtime stage
# =========================
FROM alpine:3.20

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy binary from builder
COPY --from=builder /src/muchtodo /app/muchtodo

# Copy binary from builder
COPY --from=builder /src/muchtodo /app/muchtodo
# Copy environment file (so viper/.env loader can see it)
COPY --from=builder /src/.env /app/.env

# Install curl for healthcheck
RUN apk add --no-cache curl

# Expose app port
EXPOSE 3000

# Container healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://127.0.0.1:3000/health || exit 1

USER appuser

CMD ["./muchtodo"]