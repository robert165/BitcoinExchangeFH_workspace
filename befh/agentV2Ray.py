import requests

headers = {'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) '

           'AppleWebKit/537.36 (KHTML, like Gecko) '

           'Chrome/56.0.2924.87 Safari/537.36'}

proxies = {'http': 'socks5://127.0.0.1:1090','https':'socks5://127.0.0.1:1090'}

url = 'https://www.facebook.com'

response = requests.get(url, proxies=proxies)

print(response.content)