# consul-dns-ui
> use consul purely as a dns server

<p align="center"><img src="https://raw.githubusercontent.com/xuqingfeng/consul-dns-ui/master/consul-dns-ui.png" alt="demo" width=700/></p>

## Build

```bash
# install dependencies
npm install

# build for production
CONSUL_ADDRESS=<consul_address> CONSUL_DOMAIN_SUFFIX=<consul_domain_suffix> npm run build
```

## Example

```bash
docker-compose up -d

open http://127.0.0.1:8000

dig @127.0.0.1 consul.service.consul
```