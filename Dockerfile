FROM golang:1.16-alpine3.14 AS builder

ARG JSONNET_VERSION=0.17.0

RUN apk upgrade --no-cache --update && \
    apk add --no-cache --update ca-certificates git build-base wget tar

WORKDIR /app/src

RUN mkdir -p /app/src && \
    wget https://github.com/google/go-jsonnet/archive/refs/tags/v${JSONNET_VERSION}.tar.gz -O /app/src/jsonnet.tar.gz
RUN tar xvzf jsonnet.tar.gz -C /app/src --strip-components=1 && \
    rm /app/src/jsonnet.tar.gz

RUN go build -v ./cmd/jsonnet

RUN cp -aiv jsonnet /app && rm -fR /app/src

FROM alpine:3.14 AS runner

COPY --from=builder /app/jsonnet /opt/jsonnet/jsonnet
RUN chmod a+x /opt/jsonnet/jsonnet

COPY grafonnet /opt/grafonnet/

RUN addgroup jsonnet && \
    adduser -D -G jsonnet --no-create-home -s /bin/sh jsonnet

USER jsonnet

WORKDIR /opt/jsonnet/

ENV JSONNET_PATH="/opt/grafonnet"

CMD ["--help"]

ENTRYPOINT ["/opt/jsonnet/jsonnet"]
