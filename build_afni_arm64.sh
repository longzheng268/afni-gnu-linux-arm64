#!/bin/bash

# AFNI ARM64 一键编译部署脚本 (Debian 12 / Apple Silicon VM 优化版)
set -e

echo "开始安装系统依赖..."
sudo apt-get update
sudo apt-get install -y \
    libx11-dev libxm4 libxt-dev libxft-dev libxdevice-dev \
    libglw1-motif-dev libmesa-gl-dev libglu1-mesa-dev \
    libpng-dev libjpeg-dev libexpat1-dev libssl-dev \
    libxi-dev libxmu-dev libxpm-dev \
    build-essential gcc git make r-base-dev python3-dev \
    libgsl-dev netpbm libnetpbm10-dev \
    m4 libglib2.0-dev

# 1. 关键：解决 ARM64 下 glibconfig.h 找不到的问题
export CPATH=$CPATH:/usr/include/glib-2.0:/usr/lib/aarch64-linux-gnu/glib-2.0/include
echo "已设置 CPATH 以适配 ARM64 GLIB 路径"

# 2. 进入源码目录
cd src

echo "开始编译 SUMA 组件..."
# 针对 SUMA 的特殊编译命令
make suma

echo "编译主程序并部署到 ~/abin..."
# 确保目标文件夹存在
mkdir -p ~/abin

# 3. 搬运生成的二进制文件
find SUMA -maxdepth 1 -type f -executable -exec cp {} ~/abin/ \;
cp linux_openmp_64/* ~/abin/ 2>/dev/null || true
chmod +x ~/abin/*

# 4. 初始化 AFNI 环境配置
~/abin/suma -update_env
echo "export SUMA_NoFancyStuff=YES" >> ~/.sumarc
echo "export AFNI_no_fanciness=YES" >> ~/.afnirc

# 5. 安装核心 R 包 (采用系统二进制包，避免编译失败)
echo "正在安装 R 统计组件..."
sudo apt-get install -y r-cran-tidyverse r-cran-rmarkdown r-cran-ggplot2 r-cran-snow r-cran-nlme r-cran-data.table

echo "========================================"
echo "编译与环境配置完成！"
echo "请执行: source ~/.bashrc"
echo "然后输入 'suma' 验证图形界面"
echo "========================================"
