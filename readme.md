# Test HTTP/2 using an Nginx Proxy

Do you want to test HTTP/2 without deploying any code?
This is how to test HTTP/2.0 connections from your computer.
This proxy will connect HTTP/2.0 then proxy that connection
to your production or staging web server.

This is how to run an HTTP/2 proxy that uses HTTP/2 connections to your server.
This will guide you on how to do it!
By default the `nginx.conf` is setup to proxy to PubNub APIs.
You can change this settings to point to your upstream servers.

The dockerfile comes ready with HTTP/2 Nginx.
To change the upstream value, open `nginx.conf` and set the `server`
to point to your domain.
Re-run the build step for any changes you make to `nginx.conf`.
The domain is currently set to `pubsub.pubnub.com` by default.
The examples in this readme will use PubNub URLs for testing purposes.

### Change your Upstream

Easily update the upstream to target your servers.
Open `nginx.conf` and edit the line below.

```nginx
## -----------------------------------------------------------------------
## Upstreams
## -----------------------------------------------------------------------
upstream pubnub_servers {
    ## Change pubsub.pubnub.com to your-server.com
    ## server your-server.com:80 max_fails=3;
    server pubsub.pubnub.com:80 max_fails=3; ## <------- Change this line
    keepalive 512;
}
```

### Build and Run Docker

Build and run the dockerfile.
This will launch an HTTPS server with HTTP/2.0 enabled.
The access and error logs will print to STDOUT.

```shell
docker build -t http2 .
docker run -p 4443:4443 http2
```

Notice that HTTP/2.0 will show up in the logs if an HTTP/2 client is used.
And HTTP/1.1 will show up for 1.1 client requests.

![how to run an HTTP/2 proxy](https://i.imgur.com/Y20dm7M.png)

### CURL Test

Test a url with HTTP/2.
This example uses a PubNub URL.

> `pubnubcoin.com` resolves to `0.0.0.0` for testing purposes.

```shell
curl https://pubnubcoin.com:4443/time/0 -v -k --http2 ## Verbose w/ Headers
curl https://pubnubcoin.com:4443/time/0    -k --http2 ## Output Response Only
```

Test PubNub With HTTP/1.1 Backward Compatible.

```shell
curl https://pubnubcoin.com:4443/time/0 -v -k --http1.1 ## Verbose w/ Headers
curl https://pubnubcoin.com:4443/time/0    -k --http1.1 ## Output Response Only
```

### Browser Test

You need to add an exception for a self-signed certificate.

 1. Go to: https://pubnubcoin.com:4443/time/0
 2. Add exception to self-signed certificate.
 3. Go to: https://www.pubnub.com/docs/console?channel=pubnub-twitter&origin=pubnubcoin.com:4443&sub=sub-c-78806dd4-42a6-11e4-aed8-02ee2ddab7fe
 4. You should see HTTP/2 Traffic and JSON messages from Live Tweets.

### HTTPS Testing via Python

Install any needed package dependencies.
For example `pip install requests` may be needed.

```python
import requests
import requests.packages.urllib3
requests.packages.urllib3.disable_warnings()

response = requests.get(
    'https://pubnubcoin.com:4443/time/0',
    verify='certs/server.cert'
)
print(response.content)
```

```shell
python python-test-request.py
```

### SDK Test Example

Download your SDK and set the `origin` host parameter as `pubnubcoin.com:4443`.
This will test HTTP(S)/1.1 againts HTTP(S)/2 endpoint.

```javascript
const PubNub = require('pubnub')

let pubnub = new PubNub({
    ssl          : true,                  // <----------- secure
    origin       : 'pubnubcoin.com:4443', // <----------- origin
    publishKey   : 'demo',
    subscribeKey : 'demo'
})

pubnub.addListener({
    status: statusEvent => {
        if (statusEvent.category === "PNConnectedCategory") {
            publishSampleMessage()
        }
    },
    message: msg => {
        console.log(msg.message.title)
        console.log(msg.message.description)
    }
})      

console.log("Subscribing..")
pubnub.subscribe({ channels: ['hello_world']  })

function publishSampleMessage() {
    let publishConfig = {
        channel : "hello_world",
        message : {
            title: "greeting",
            description: "hello world!"
        }
    }
    pubnub.publish( publishConfig, ( status, response ) =>
        console.log(response)
    )
}
```

### Export/Import Docker Container

To get this container running on EC2, we can import/export a tarball.

```shell
## Save/Export
docker save http2 > http2.tar
gzip -9 http2.tar

## Import/Load
docker load < http2.tar.gz
```

### Self Signed Certificate

A Starfield SHA-2 Certificate is included in this repository
assigned to `pubnubcoin.com`.
This allows you to test PubNub HTTP2 without
Certificate Authority errors.

To generate a self signed certificate, you can use the following openssl command:

```shell
openssl req -new -out server.cert -x509 -days 3650 -keyout server.key -nodes -subj '/CN=0.0.0.0/O=PubNub/C=US/subjectAltName=DNS:localhost'
```

### IP Tables for Server Host

For using 443, you'll need to add an iptables rule.
Allow inbound from 443 routed over 4443.
You may use `sudo docker run -p 443:4443 http2` however this is bad practice!

```shell
iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 4443
```
