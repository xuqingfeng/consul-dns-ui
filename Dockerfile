# require docker >= 17.05
# builder
FROM node:6

WORKDIR /app

COPY package.json /app/
RUN npm config set registry https://registry.npm.taobao.org && \
    npm install

COPY . /app/

ARG CONSUL_ADDRESS=consul:8500
ARG CONSUL_DOMAIN_SUFFIX=consul
ENV CONSUL_ADDRESS=${CONSUL_ADDRESS} CONSUL_DOMAIN_SUFFIX=${CONSUL_DOMAIN_SUFFIX}
RUN npm run build

# server
FROM nginx:alpine

COPY default.conf /etc/nginx/conf.d/

COPY --from=0 /app/ /var/www/html/