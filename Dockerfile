ARG POSTGRES_VERSION

FROM golang:1.23-alpine AS build

ENV GOPATH="/go/src"

WORKDIR /build

COPY . .

RUN GOOS=linux go build -ldflags="-s -w" -o main .

FROM postgres:${POSTGRES_VERSION}-alpine

RUN apk add --no-cache tzdata
ENV MODE=production

WORKDIR /app

COPY README.md .
COPY --from=build /build/main ./controller

RUN chown -R postgres:postgres /app && \
    mkdir -p /var/lib/postgresql/backup/data && \
    mkdir -p /var/lib/postgresql/backup/shared && \
    mkdir -p /var/lib/postgresql/databases && \
    chown -R postgres:postgres /var/lib/postgresql/backup && \
    chown -R postgres:postgres /var/lib/postgresql/databases

COPY docker-entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["./controller", "start"]
