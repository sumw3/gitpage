#!/bin/bash

echo "build at `date`"
git pull coding master
echo "git pull successfully"
hexo g --d
echo "built successfully"
rm -rf /var/www/hexo/*
cp -rf /root/gitpage/public/* /var/www/hexo/
echo "copy successfully"
