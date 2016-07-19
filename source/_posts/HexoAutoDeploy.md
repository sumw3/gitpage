title: '通过VPS自动发布HEXO'
date: 2014-12-31 13:00:00
tags:
  - vps
  - hexo
  - git
categories:
 - OpenProjects
---

之前已经在本地搭建了hexo的环境，但是还是需要每次都要在本地生成一下然后再提交到**github**或者**gitcafe**上。固定在一台电脑上写作的问题还不是太大，如果需要在不同电脑甚至不同设备上写的话就没有办法了。

之前刚好看到**Bandwagon Host**的特价VPS，原来都是用着别人分享的shadowsocks，以防万一，还是自己搞一个比较安全靠谱，顺便也一起搭了一个VPN，方便移动设备使用。

下面该VPS的详细配置，年付`$9.99`，相当便宜了。
[直达链接（我的小尾巴~）](https://bandwagonhost.com/aff.php?aff=1604&pid=22)
>**Basic VPS - Unmanaged - 5G PROMO V2**
>Unmanaged service HDD: 5 GB SSD RAM: 512 MB CPU: 1x Intel Xeon BW: 500 GB/mo Link speed: 1 Gigabit VPS technology: OpenVZ/KiwiVM Linux OS: 32-bit and 64-bit Centos, Debian, Ubuntu, Fedora Instant OS reload 1 Dedicated IPv4 address Full root access PPP and VPN support (tun/tap) Instant RDNS update from control panel No contract, anytime cancellation Strictly unmanaged, no support 99% uptime guarantee 30-day money back guarantee

既然有了VPS，那我就可以把hexo的生成和发布都扔到上面去，只要我有新的markdown文件，自动通知VPS让其执行对应的同步、生成和发布即可。
![脑图](http://pubshare.qiniudn.com/sumw3hexo%E8%87%AA%E5%8A%A8%E5%8F%91%E5%B8%83.png)

<!--more-->

###GIT@OSC通知VPS更新
前面两步都没什么问题，主要是第三步，怎么让VPS知道我们已经更新的markdown文件并执行后续操作。

对比几个国内的代码托管网站，最终我选择了*开源中国*的GIT（**GIT@OSC**），这也是我平常用得最多的代码托管网站。**GIT@OSC**提供了了一个非常好用的功能：*PUSH钩子*。
![PUSH钩子](http://pubshare.qiniudn.com/sumw3%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202014-12-31%20%E4%B8%8B%E5%8D%882.04.21.png)
只要在钩子地址中填入对应的服务器地址，每次**GIT@OSC**收到新的**PUSH**的时候都会自动发一个**POST**请求至该地址，内容为该次**PUSH**的具体信息及**PUSH钩子**中设置的密码。

因此，我们只需要在VPS上搭建一个简答的web服务器用来响应对应的请求获取通知即可。

###VPS获取通知执行批处理

####获取通知

##### 1. nginx配置

获取通知主要通过nginx搭建反向代理服务器，把请求转发给Python后，通过Python执行请求的响应和后续的批处理。

由于我VPS选用的是`Ubuntu`，所以安装nginx也非常简单，直接执行一下命令。
```bash
$ sudo apt-get install nginx 
```
修改`/etc/nginx/sites-available/default`文件，增加路由让其转发对应地址的请求至Python程序。
```xml
location /update {
        proxy_pass http://127.0.0.1:1111;
    }
```
重启nginx：
```bash
$ sudo /etc/init.d/nginx restart
```

##### 2. Python配置

代码如下：
```python
#!/usr/bin/env python3
#-*- coding:utf-8 -*-
# start a python service and watch the nginx request dog

from http.server import HTTPServer,CGIHTTPRequestHandler
from threading import Thread,RLock
import subprocess
import logging
import sys
import os.path


_PWD=os.path.abspath(os.path.dirname(__file__))
def execute_cmd(args,cwd=None,timeout=30):
    if isinstance(args,str): args = [args]
    try:
        with subprocess.Popen(args,stdout=subprocess.PIPE,cwd=cwd) as proc:
            try:
                output,unused_err = proc.communicate(timeout=timeout)
            except:
                proc.kill()
                raise
            retcode = proc.poll()
            if retcode:
                raise subprocess.CalledProcessError(retcode, proc.args, output=output)
            return output.decode('utf-8','ignore') if output else ''
    except Exception as ex:
        logging.error('EXECUTE_CMD_ERROR: %s',' '.join(str(x) for x in args))
        raise ex

class HttpHandler(CGIHTTPRequestHandler):
    _lock = RLock()
    _counter = 0
    _building = False

    def build(self):
        with HttpHandler._lock:
            if HttpHandler._counter == 0 or HttpHandler._building:
                return
        HttpHandler._counter = 0
        HttpHandler._building = True
        logging.info("BUILDING NOW...")
        try:
            resp = execute_cmd(os.path.join(_PWD,'build.sh'),cwd=_PWD,timeout=600)
            logging.info(resp)
        finally:
            HttpHandler._building = False
            self.build()

    def do_GET(self):
        self.do_POST()
    def do_POST(self):
        self.send_response(200,'OK')
        self.end_headers()
        self.wfile.write(b'OK')
        self.wfile.flush()
        with HttpHandler._lock:
            HttpHandler._counter += 1
        Thread(target=self.build).start()

if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',level=logging.INFO)

    port = int(sys.argv[1]) if len(sys.argv) > 1 else 1111
    logging.info('starting the server at 127.0.0.1:%s',port)
    httpd = HTTPServer(('127.0.0.1',port),HttpHandler)
    httpd.serve_forever()
```

将Python文件`hook.py`和对应的批处理文件`build.sh`都放置在hexo的目录下，启动Python监听：
```bash
$ nohup python3 hook.py >> /tmp/hook.log 2>&1 &
```

####批处理Shell
```bash
#!/bin/bash

echo "build at `date`"
. ~/.nvm/nvm.sh
nvm use 0.10.35
git pull
hexo g --d
echo "built successfully"
```

当然，为了让Python能够正确执行脚本，还需要执行一下命令：
```bash
$ sudo chmod +x build.sh
```

----------

到此为止基本上都已经配置完毕，提交一个测试文件试一下，查看一下各自日志以及**github**的日志，没有问题，都成功了。

以后终于可以直接提交markdown，而不用再去生成发布，哪怕是新电脑，没有环境问题，只要有浏览器有网络，一切都那么地简单。