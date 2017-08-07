# consul-dns-ui
> use consul purely as a dns server

## Build

```bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
CONSUL_ADDRESS=<consul_address> npm run build
```

## Example

```bash
docker build -t xuqingfeng/consul-dns-ui --build-arg CONSUL_ADDRESS=127.0.0.1:8000 .

docker-compose up -d

# register service
curl -i -X PUT -d '{"ID": "test", "Name": "test", "Address": "1.2.3.4", "Port": 3000}' http://<consul_address>/v1/agent/service/register

# list services
curl http://<consul_address>/v1/agent/services

# deregister service
curl -X PUT http://<consul_address>/v1/agent/service/deregister/test

dig @<consul_ip> -p <consul_dns_port> test.service.consul
```