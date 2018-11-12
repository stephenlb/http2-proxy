import requests
import requests.packages.urllib3
requests.packages.urllib3.disable_warnings()

response = requests.get(
    'https://0.0.0.0:4443/time/0',
    verify='certs/server.cert'
)
print(response.content)
