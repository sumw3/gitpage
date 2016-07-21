title: '用 Travis CI 自动部署 Hexo'
date: 2016-07-21 13:21:38
tags: 
  - hexo
  - Travis CI
categories:
  - OpenProjects
---

## 开始之前

在开始之前，请先申请 Travis CI 帐号，把你的 GitHub repo 新增到 Travis CI 上，如果还没建立 `.travis.yml` 的话，请先制作一个新的 `.travis.yml` 。

## Deploy Key

首先你必须用 `ssh-keygen` 制作一个 SSH Key ，供 GitHub 当作 Deploy key 使用。

```
$ ssh-keygen -t rsa -C "your_email@example.com"
```

在制作 SSH key 时，请把 passphrase 留空，因为在 Travis 上输入密码很麻烦，我目前还找不到比较简便的方式，如果各位知道的话欢迎提供给我。
当 SSH key 制作完成后，复制 Public key 到GitHub上的 Deploy key 字段，如下：

![](https://zespia.tw/blog/2015/01/21/continuous-deployment-to-github-with-travis/deploy_key.png)

<!--more-->

## 加密 Private Key

首先，安装 Travis 的命令列工具：

```
$ gem install travis
```

在安装完毕后，透过命令列工具登入到 Travis ：

```
$ travis login --auto
```

如此一来，我们就能透过 Travis 提供的命令列工具加密刚刚所制作的 Private key ，并把它上传到 Travis 上供日后使用。

假设 Private key 的档案名称为 `ssh_key`，Travis 会加密并产生 `ssh_key.enc` ，并自动在 `.travis.yml` 的 `before_install` 字段中，自动插入解密指令。

```
$ travis encrypt-file ssh_key --add
```

正常来说 Travis 会自动解析目前的 repo 并把 Private key 上传到相对应的 repo ，但有时可能会秀逗，这时你必须在指令后加上 `-r` 选项来指定 repo 名称，例如：

```
$ travis encrypt-file ssh_key --add -r hexojs/site
```

## 设定 `.travis.yml`

把刚刚制作的 `ssh_key.enc` 移至 `.travis/ssh_key.enc` ，并在 `.travis ` 文件夹中建立 `ssh_config` 档案，指定 Travis 上的 SSH 设定。

```
Host github.com
  User git
  StrictHostKeyChecking no
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
```

因为刚刚修改了 `ssh_key.enc` 的位址，所以我们要顺带修改刚刚 Travis 在 `.travis.yml` 帮我们插入的那条解密指令。请注意，不要照抄这段指令，每个人的环境变数都不一样。

```
- openssl aes-256-cbc -K $encrypted_06b8e90ac19b_key -iv $encrypted_06b8e90ac19b_iv -in .travis/ssh_key.enc -out ~/.ssh/id_rsa -d
```

这条指令会利用 openssl 解密 Private key ，并把解密后的档案存放在 `~/.ssh/id_rsa` ，接着指定这个档案的权限：

```
- chmod 600 ~/.ssh/id_rsa
```

然后，把 Private key 加入到系统中：

```
- eval $（ssh-agent）
- ssh-add ~/.ssh/id_rsa
```

记得刚刚我们制作的 `ssh_config` 档案吗？别忘了把他复制到 `~/.ssh` 文件夹：

```
- cp .travis/ssh_config ~/.ssh/config
```

为了让 git 操作能顺利进行，我们必须先设定 git 的使用者信息：

```
- git config --global user.name“Tommy Chen”
- git config --global user.email tommy351@gmail.com
```

最后的结果可能如下，如果你和我一样使用 Hexo 的话可以参考看看

```
language: node_js

node_js:
  - "0.10"

before_install:
  # Decrypt the private key
  - openssl aes-256-cbc -K $encrypted_06b8e90ac19b_key -iv $encrypted_06b8e90ac19b_iv -in .travis/ssh_key.enc -out ~/.ssh/id_rsa -d
  # Set the permission of the key
  - chmod 600 ~/.ssh/id_rsa
  # Start SSH agent
  - eval $(ssh-agent)
  # Add the private key to the system
  - ssh-add ~/.ssh/id_rsa
  # Copy SSH config
  - cp .travis/ssh_config ~/.ssh/config
  # Set Git config
  - git config --global user.name "Tommy Chen"
  - git config --global user.email tommy351@gmail.com
  # Install Hexo
  - npm install hexo@beta -g
  # Clone the repository
  - git clone https://github.com/hexojs/hexojs.github.io .deploy

script:
  - hexo generate
  - hexo deploy

branches:
  only:
    - master
```

------

> 引用：[用 Travis CI 自動部署網站到 GitHub](https://zespia.tw/blog/2015/01/21/continuous-deployment-to-github-with-travis/)


> 其他 [`.travis.yml`](https://github.com/51offer/51offer.github.com/blob/blog/.travis.yml) 参考 