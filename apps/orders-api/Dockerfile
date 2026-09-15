# ---------- Build stage ----------
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./
COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o orders-api .

# ---------- Runtime stage ----------
FROM alpine:3.20

RUN addgroup -g 10001 -S appgroup && \
    adduser -u 10001 -S appuser -G appgroup

WORKDIR /app

COPY --from=builder --chown=10001:10001 \
    /app/orders-api /app/orders-api

USER 10001:10001

EXPOSE 8080

ENTRYPOINT ["/app/orders-api"]
