# Build
FROM elixir:1.17.2-alpine as builder

ENV MIX_ENV="prod"

RUN apk add --update --no-cache bash git openssh openssl
RUN apk add --update --no-cache --virtual .gyp g++ make

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

COPY mix.exs mix.lock ./
COPY config config
COPY lib lib

RUN mix do deps.get --only ${MIX_ENV}, deps.compile
ENV PATH="/root/.mix/escripts:${PATH}"

RUN mix compile
RUN mix release

# Run
FROM alpine:3.19

RUN apk add --update --no-cache bash openssl libstdc++

ENV MIX_ENV="prod"

EXPOSE 5000

WORKDIR /app
COPY --from=builder /app/_build/${MIX_ENV}/rel/rolex ./

CMD ["sh", "-c", "/app/bin/rolex start"]
