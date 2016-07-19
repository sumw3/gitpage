title: Raneto：用Markdown写作、Nodejs搭建的Wiki
date: 2014-07-11 14:30:02
tags:
  - raneto
  - wiki
  - markdown
  - nodejs
categories:
  - OpenProjects
---

>最近对**Markdown**很感兴趣，刚在Github上搭建了这个站点，用来记录平时的一些技巧心得。但是还有一些属于经常用到的，可以不断套用的东西，用现在这个站来记录的话，查找起来比较麻烦。因此，想找一款能直接**Markdown**记录，用树形结构组织，支持全文检索的Wiki软件。Github上搜了一圈，对比了几个Repo，最终选择[**Raneto**](1)。

## Raneto

### 简单介绍

#### Markdown powered Knowledgebase for Nodejs
>Raneto is an open source Knowledgebase platform that uses static Markdown files to power your Knowledgebase.

- 基于**Nodejs**以及**Express**构建，支持**GFM**的**Markdown**文件，利用**Lunr**进行全文检索。
- 基于文件目录的URL结构，无需数据库
- 基于**Bootstrap**的响应式模板，方便多终端访问

### 安装

由于是**Nodejs**应用，安装非常方便。*当然，前提是机器上已有__Nodejs__*

1. 下载托管在**Github**上的**Raneto**代码，这里提供最新的[*Release*版本下载](3)。
2. 解压，在文件夹内用命令行执行`npm install`安装依赖包。
3. 命令行执行`npm start`启动应用。
4. 访问`http://localhost:3000`即可。
<!--more-->

### 内容管理

默认的内容文件夹为`content`，里面默认已经有了**Raneto**的说明手册，很好的例子。  
修改文件名或者文件夹名称可以改变对应的URL，只要浏览器刷新整个结构貌似就会重建，这点非常强大，修改文件内容也是一样，刷新就显示。  
当然，通过修改`config.js`可以自定义`content`文件夹位置和静态图片位置。
```json
	// The base URL of your images folder (can use %image_url% in Markdown files)
	image_url: '/images',

	// Specify the path of your content folder where all your '.md' files are located
	content_dir: './content/',
```
### 其他扩展及问题

目前最理想的使用方法是在**VPS**上结合**Dropbox**来同步`content`和`image`文件夹，这样的话就可以从任意终端来更新访问了，感觉会非常方便。

当然，目前**Raneto**最大的问题是中文支持，其实不应该算**Raneto**的问题，而应该是[**lunrjs**](4)的问题。目前没有中文、日文检索的支持。

查看了**lunrjs**的[*Issues*](https://github.com/olivernn/lunr.js/issues)，发现[*ming300*](https://github.com/ming300)同学针对这个问题已经提过[*Pull Request*](https://github.com/olivernn/lunr.js/pull/96)，有需要可以参考一下。
> **lunrjs**也有语言支持的插件[**lunr-languages**](https://github.com/MihaiValentin/lunr-languages)，但是也很遗憾，还没有中文的支持，下次研究一下，看看能不能搞一个提交上去。

既然检索不了中文，那我就用定义一些`Keyword`来方便检索吧。



[1]: http://raneto.com/
[2]: https://github.com/gilbitron/Raneto
[3]: https://github.com/gilbitron/Raneto/releases
[4]: http://lunrjs.com/