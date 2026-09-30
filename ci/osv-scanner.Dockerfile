FROM ghcr.io/google/osv-scanner:v2.6.0 AS scanner

FROM alpine:3.24
RUN apk add --no-cache ca-certificates git
COPY --from=scanner /osv-scanner /usr/local/bin/osv-scanner
USER 1000:1000
WORKDIR /home/jenkins/agent
