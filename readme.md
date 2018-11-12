# PubNub HTTP/2 Proxy

Run a proxy that uses HTTP/2 connections with proxy to PubNub API Calls.

### Single instance version of PubNub.

```shell
docker build -t pubnub-http2 .
docker run -p 8080:8080 pubnub-http2  ## Test
docker run -p 80:8080 pubnub-http2    ## Prod
```

### Test Local Container

Open Chrome with this url to test connection to your docker container:
http://pubnub.github.io/pubnub-tools/console/console.html?channel=apple&origin=0.0.0.0:8080&sub=demo&pub=demo

### Local SSH Access to Container.

```shell
docker ps                          ## get IMAGE_ID
docker exec -it IMAGE_ID /bin/bash ## ssh
```

### Export/Import Docker Container

To get this container running on EC2, we can import/export a tarball.

```shell
## Save/Export
docker save pubnub-http2 > pubnub-http2.tar
gzip -9 pubnub-http2.tar

## Import/Load
docker load < pubnub-http2.tar.gz
```

### IP Tables for Server Host.

```shell
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
```
