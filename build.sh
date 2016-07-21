#!/bin/bash

echo "build at `date`"
git pull coding master
echo "git pull successfully"
hexo g --d
echo "built successfully"