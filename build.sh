#!/bin/bash

echo "build at `date`"
git pull
hexo g --d
echo "built successfully"