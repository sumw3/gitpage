title: 'OpenVZ 开启 BBR 方法'
date: 2017-04-15 15:59:30
tags: 
  - vps
  - shadowsocks
categories:
  - OpenProjects
---

## 开始之前

BBR，是一个TCP加速优化工具，类似于锐速，可用于优化 TCP 连接。

> GitHub 地址为：https://github.com/google/bbr

仔细看了看，GitHub 主页上有明确的说明“This is not an official Google product.” 说明这其实不是 Google 的官方项目，但是是在 Google 的 GitHub 上，比较奇怪。

要想启用 BBR 需要切换内核，所以必须要 KVM 或者 XEN 架构的 VPS。这点和锐速一致，所以 OpenVZ 的朋友是用不了的。由于需要跟换内核，属于危险操作，请不要用于生产环境，可能会造成无法开机，切记！
至于加速效果，有人反馈比锐速好，有人反馈比锐速弱。我测试后感觉效果还是不错的，但是用起来比破解版锐速放心一些吧，它是内置到最新的内核里边了。

虽说 OpenVZ 在正常情况下是无法使用 BBR 的，但是通过其他一些手段还是能够达到目的。

## 教程

### 1. VPS 的 Panel 里打开 TUN/TAP 功能

### 2. 创建一个 tap0
```
ip tuntap add tap0 mode tap
ip addr add 10.0.0.1/24 dev tap0
ip link set tap0 up
```

### 3. 打通 tap0 和 host 之间的网络
```
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o venet0 -j MASQUERADE
```

### 4. 在 443 端口开启 BBR
```
iptables -t nat -A PREROUTING -i venet0 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.2
```

### 5. 安装 haproxy ，并禁止开机自启
```
apt-get install haproxy
update-rc.d haproxy disable
```

### 6. 配置 haproxy
新建一个 `/root/haproxy/haproxy.cfg`
>假设你原来的 server 监听的是 12580 端口， BBR 的端口开在 443

```
global
user haproxy
group haproxy
defaults
mode tcp
timeout connect 5s
timeout client 60s
timeout server 60s

listen shadowsocks
bind 10.0.0.2:443
server server1 10.0.0.1:12580
```

### 7. 下载 Linux Kernel Library ，解压
从以下地址下载 LKL，并解压至 `/root/haproxy`。
>https://drive.google.com/file/d/0ByqeeKN198fcdDVLMmVKakl5VE0/view?usp=sharing

```
tar -xzvf liblkl-hijack.so.tgz
```

### 8. 开启 haproxy 为 BBR 过桥
以下命令必须一行打完

```
LD_PRELOAD=/root/haproxy/liblkl-hijack.so LKL_HIJACK_NET_QDISC="root|fq" LKL_HIJACK_SYSCTL="net.ipv4.tcp_congestion_control=bbr;net.ipv4.tcp_wmem=4096 65536 67108864" LKL_HIJACK_NET_IFTYPE=tap LKL_HIJACK_NET_IFPARAMS=tap0 LKL_HIJACK_NET_IP=10.0.0.2 LKL_HIJACK_NET_NETMASK_LEN=24 LKL_HIJACK_NET_GATEWAY=10.0.0.1 LKL_HIJACK_OFFLOAD="0x8883" haproxy -f /root/haproxy/haproxy.cfg
```

## 大功告成
现在可以用客户端连上试试看了 

12580 是原来 server 的端口 

443 是开启 BBR 以后的端口

## 设置开机脚本

### 1. 安装 supervisor

```
apt-get install supervisor
```

### 2. 添加配置文件，用于开机自启
在目录 `/etc/supervisor/conf.d` 中增加配置文件 `haproxy-lkl.conf`

```
[program:haproxy-lkl] 
command=/root/haproxy/haproxy-lkl-start.sh
autostart=true 
autorestart=true 
redirect_stderr=true 
stdout_logfile=/root/haproxy/haproxy-lkl_stdout.log 
stdout_logfile_maxbytes=1MB 
stderr_logfile=/root/haproxy/haproxy-lkl_stderr.log 
stderr_logfile_maxbytes=1MB
```

### 3. 为haproxy 配 Linux Kernel Library 的启动脚本

在目录 `/root/haproxy` 中增加启动脚本 `haproxy-lkl-start.sh`

```
#!/bin/sh 

ip tuntap add tap0 mode tap 
ip addr add 10.0.0.1/24 dev tap0 
ip link set tap0 up 

iptables -P FORWARD ACCEPT 

iptables -t nat -D PREROUTING -i venet0 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.2 
iptables -t nat -A PREROUTING -i venet0 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.2 

iptables -t nat -D PREROUTING -i venet0 -p udp --dport 443 -j REDIRECT --to-port 12580 
iptables -t nat -A PREROUTING -i venet0 -p udp --dport 443 -j REDIRECT --to-port 12580 

export LD_PRELOAD=/root/haproxy/liblkl-hijack.so 
export LKL_HIJACK_NET_QDISC="root|fq" 
export LKL_HIJACK_SYSCTL="net.ipv4.tcp_congestion_control=bbr;net.ipv4.tcp_wmem=4096 65536 67108864" 
export LKL_HIJACK_NET_IFTYPE=tap 
export LKL_HIJACK_NET_IFPARAMS=tap0 
export LKL_HIJACK_NET_IP=10.0.0.2 
export LKL_HIJACK_NET_NETMASK_LEN=24 
export LKL_HIJACK_NET_GATEWAY=10.0.0.1 
export LKL_HIJACK_OFFLOAD="0x8883" 
export LKL_HIJACK_DEBUG=1 

haproxy -f /root/haproxy/haproxy.cfg
```

### 4. 重启验证

> 参考来源：https://www.v2ex.com/t/353778