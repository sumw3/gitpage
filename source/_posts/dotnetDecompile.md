title: '.Net 反编译修改程序'
date: 2017-05-26 13:46:21
tags: 
  - .net
  - ILSpy
  - Reflexil
categories:
  - OpenProjects
---

# 背景

本来有个小工具，可以直接连接数据库通过一些简单的条件筛选来查看数据。但是最近由于数据库 IP 地址变更，而那个小工具中数据库 IP 是直接写在代码中，源代码又没有，于是就没法使用了。

虽然说重新写一个可能也不是太费事，但是界面布局调整什么的还是挺麻烦，于是考虑是不是可以通过反编译来直接修改元程序中的 IP 地址呢？

<!-- more -->

# 工具

### 1. [ILSpy](http://ilspy.net/)

> ILSpy 是一个开源免费的 .NET 程序浏览与反编译程序(decompiler)，该软件开发是在2011年，在知名反编译软件 .NET **reflector** 宣布停止免费版后，提供给使用者不同的解决方案。
>
> **软体特色**
>
> - 浏览、转存程序的资源。
> - 反编译程序为 C# 程序语言。
> - 显示程序 XML 设定文件。
> - 快速的寻找类别(types)、方法(methods)、属性(properties)资料。
> - 可通过外挂插件(pulgins)增强功能。

[中文版下载地址](http://www.fishlee.net/soft/ilspy_chs/)

### 2. [Reflexil](http://reflexil.net/)

> Reflector 能用来对各类程序集进行深度检查的工具，他们同时也都能对 .NET 的 IL code 进行反汇编。
>但是这两个工具都无法修改对应程序集的结构或 IL code。
>在 Jb EVAIN 实现的强大 Mono.Cecil 帮助下，Reflexil 达到了这个目标。
>作为一个专门用来处理 IL code 的插件，Reflexil 实现了一个完整的指令编辑器，并允许直接注入 C#/VB.NET 代码。

# 修改方法

### 1. 下载 ILSpy 和 Reflexil

分别通过官网下载后，将 Reflexil 解压至 ILSpy 目录中。
![](https://ws1.sinaimg.cn/large/68f944b2ly1ffyrflhzu6j20gx0glgnv.jpg)

打开 ILSpy 后会看到 Reflexil 已经集成进去。
![](https://ws1.sinaimg.cn/large/68f944b2ly1ffyrig1jw5j20kg0f3jrv.jpg)

### 2. 打开需要修改的程序，找到修改位置

通过 ILSpy 打开需要修改的程序。
![](https://ws1.sinaimg.cn/large/68f944b2ly1ffys1gczdpj20kg0f30tj.jpg)

在左侧边栏中，找到要目标程序，展开后查找相关方法，明确需要修改的地方。
![](https://ws1.sinaimg.cn/large/68f944b2ly1ffys1tdg42j20pc0ieack.jpg)

### 3. 修改 IP 变量，保存修改后程序

侧边栏中选定对应方法，点击工具栏齿轮，打开 Reflexil 面板，找到对应的变量后右键菜单选择修改。
![](https://ws1.sinaimg.cn/large/68f944b2ly1ffytg10ttij20pc0ieaby.jpg)

在修改框中更新 IP 值后点击 ```Update```。
![](https://ws1.sinaimg.cn/large/68f944b2ly1ffythk0tegj20ew04i3yc.jpg)

修改完成后，在侧边栏选定本次修改的程序后右键菜单，将程序另存为 ```*.Patched.exe``` ，该程序即为修改后的执行程序。
![](https://ws1.sinaimg.cn/large/68f944b2ly1ffytkqsoekj20p50ia773.jpg)

# 结束
通过这两个工具的使用，可以简单修改一些硬编码程序，或者从可执行程序中提取相应资源。使用起来也是很方便简单，非常好用。

> **参考**
>
> - [关于 .Net 逆向的那些工具：反编译篇](http://www.aneasystone.com/archives/2015/06/net-reverse-decompiling.html)
> - [Reflexi 简明教程](http://qiankanglai.me/2016/03/05/reflexil/)