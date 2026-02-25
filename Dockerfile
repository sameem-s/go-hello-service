# Stage 1: Build
# BUILDPLATFORM = platform of the build host (GitHub runner = linux/amd64)
# TARGETOS / TARGETARCH = platform we are building FOR (set by --platform flag)
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -ldflags="-s -w" -o server .

# Stage 2: Runtime (minimal image)
FROM alpine:3.19
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/server .
USER appuser
EXPOSE 3000
CMD ["./server"]
