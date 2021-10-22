FROM node:10.18.1-stretch-slim as builder

WORKDIR /app

RUN apt-get update \
    && apt-get install -y jq \
    && apt-get clean

COPY . /app

RUN yarn policies set-version \
    && yarn \
    && yarn build

FROM bitnami/node:10-prod

ENV NODE_ENV="production"

COPY --from=builder /app /app

WORKDIR /app

EXPOSE 3000

CMD ["yarn", "server"]
