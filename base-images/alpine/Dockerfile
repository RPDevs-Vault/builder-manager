FROM alpine:latest

# Install base certificates and timezone data
RUN apk update && \
    apk add --no-cache ca-certificates tzdata curl && \
    update-ca-certificates

# Create a non-root user for security
RUN addgroup -g 1000 rpdevs && \
    adduser -u 1000 -G rpdevs -s /bin/sh -D rpdevs

# Set default timezone
ENV TZ=UTC

USER rpdevs
WORKDIR /home/rpdevs
