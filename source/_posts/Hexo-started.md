title: '开始使用Hexo'
date: 2014-07-08 10:23:38
tags: 
  - hexo
  - github
  - nodejs
  - markdown
categories:
  - OpenProjects
---

原来网站是**wordpress**的，用的也是免费空间[**000webhost**][1]。服务的稳定性还算不错，已经用了几年了，除了偶尔抽风down机之外，作为免费的空间来说还是很不错的。如果有同学要稳定的免费空间，推荐[**000webhost**][1]。
>关于**000webhost**，注册可能会麻烦一点，需要挂**VPN**或者使用代理，具体方法可自行Google。

###初识Hexo

一开始只是想用**Markdown**来写博客，但是**wordpress**本身对**Markdown**还不能支持，试了几个插件，效果都不是那么理想，在线编辑也都不支持预览，这对于一个**Markdown**新手来说，很不放心。

最近逛**v2ex**的时候也经常看到**Github**上搭建的静态博客。作为一个业余码农，博客更多的是记录一些平常碰到的技术问题和自己的一些学习心得，所以一个能够专注于文字和代码的**Markdown**加上**Github**这个无限免费的平台，非常有吸引力。

在**Github**上发布博客的工具也不少，目前最流行**jekyll**和**octopress**，但都是基于Ruby的，而**Hexo**是基于**nodejs**，
且生成速度更快，所以毫不犹豫的选择了**Hexo**。
<!--more-->
###在Windows和Mac上安装Hexo

原来机器上就已经有**nodejs**、**git**环境了，所以安装**Hexo**就非常简单，一句代码就搞定了。  
`npm install hexo -g`


然后就按照[**官网设置手册**](http://hexo.io/docs/)一步步设置就行，非常简单，并且网上资料也很多，随便一个问题都能Google到答案。

###配置Hexo

初识情况下**Hexo**就能非常完美的运行了，当然，作为中文用户来说，首先设置一下语言选项：  
`language: zh-CN`  
日期格式原来英文的，不太适应，也顺便改了一下：  
`date_format: YYYY-MM-D`  
剩下的就默认，最后安装了下面两个插件：  
```
"hexo-generator-feed": "^0.1.2",  
"hexo-generator-sitemap": "~0.1.4"
```

主题的话，官方也提供了很多，<https://github.com/hexojs/hexo/wiki/Themes>，选择一个合适的，然后稍做修改即可。

我把整个文件夹`Github Page`也作为一个`Repo`同步了，这样的话不管是**Windows**上面还是**Mac**上面都可以同步修改了，比较方便。
>当然利用各种云盘同步也不错，我懒得装客户端了，就直接**Git**了。

###问题点

目前觉得最麻烦的还是每次发布必须在电脑上执行一下`hexo d`，用其他电脑想发布新内容的话会比较麻烦，更不用说移动设备了。

下一步准备弄个**VPS**，把**Hexo**部署在上面，然后用同步盘同步到**VPS**后定时执行`hexo g`、`hexo d`应该就可以了吧。

目前就这么多内容，下次想到什么再补充吧。

[1]: http://www.000webhost.com