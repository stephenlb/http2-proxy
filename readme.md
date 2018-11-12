# PubNub HTTP/2 Proxy

Run a proxy that uses HTTP/2 connections with proxy to PubNub API Calls.

### Single instance version of PubNub.

```shell
docker build -t pubnub-http2 .
docker run -p 4443:4443 pubnub-http2  ## Test
docker run -p 443:4443 pubnub-http2   ## Prod
```

Notice that HTTP/2.0 will show up in the logs.
And HTTP/1.1 will show up for 1.1 requests.

![HTTP/2 Default Transport](https://i.imgur.com/Y20dm7M.png)

### Chrome/Browser Test

You need to add an exception for a self-signed certificate.

 1. Go to: https://0.0.0.0:4443/time/0
 2. Add certificate.
 3. Go to: https://www.pubnub.com/docs/console?channel=pubnub-twitter&origin=0.0.0.0:4443&sub=sub-c-78806dd4-42a6-11e4-aed8-02ee2ddab7fe
 4. You should see HTTP/2 Traffic and JSON messages from Tweets.

### CURL Test

Test PubNub With HTTP/2.

```shell
curl https://0.0.0.0:4443/time/0 -v -k --http2 ## Verbose w/ Headers
curl https://0.0.0.0:4443/time/0    -k --http2 ## Output Response Only
```

Test PubNub With HTTP/1.1 Backward Compatible.

```shell
curl https://0.0.0.0:4443/time/0 -v -k --http1.1 ## Verbose w/ Headers
curl https://0.0.0.0:4443/time/0    -k --http1.1 ## Output Response Only
```

### SDK Testing 

Download the SDK and set the `origin` parameter as `0.0.0.0:4443`.
Here is an example with Python:

```python
import requests
import requests.packages.urllib3
requests.packages.urllib3.disable_warnings()

response = requests.get(
    'https://0.0.0.0:4443/time/0',
    verify='certs/server.cert'
)
print(response.content)
```

```shell
python python-test-request.py
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

### Self Signed Certificate

```shell
openssl req -new -out server.cert -x509 -days 3650 -keyout server.key -nodes -subj '/CN=0.0.0.0/O=PubNub/C=US/subjectAltName=DNS:localhost'
```

### IP Tables for Server Host.

```shell
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
```
