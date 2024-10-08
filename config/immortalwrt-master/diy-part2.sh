#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------

echo >> feeds.conf.default
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
./scripts/feeds update istore
./scripts/feeds install -d y -p istore luci-app-store



#!/bin/bash

# 切换到 openwrt 目录
cd openwrt/
# 删除 feeds 中的 golang 包
echo "正在删除 feeds 中的 golang 包..."
rm -rf feeds/packages/lang/golang

# 克隆 golang 包的指定分支
echo "正在克隆 golang 包..."
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# 删除 feeds 中的 v2ray-geodata 包（适用于 openwrt-22.03 和 master 分支）
echo "正在删除 feeds 中的 v2ray-geodata 包..."
rm -rf feeds/packages/net/v2ray-geodata

# 克隆 mosdns 和 v2ray-geodata 的仓库
echo "正在克隆 mosdns 和 v2ray-geodata 仓库..."
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 在 .config 中添加 mosdns 配置
echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-mosdns-zh-cn=y" >> .config

# 编译 mosdns 包
echo "正在编译 mosdns 包..."
make package/mosdns/luci-app-mosdns/compile V=s

# 修改 tailscale Makefile，删除与 /etc/init.d/tailscale 和 /etc/config/tailscale 相关的行
echo "正在修改 tailscale 的 Makefile..."
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile

# 克隆 luci-app-tailscale 仓库
echo "正在克隆 luci-app-tailscale 仓库..."
git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale

# 在 .config 中添加 tailscale 配置
echo "CONFIG_PACKAGE_luci-app-tailscale=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-tailscale-zh-cn=y" >> .config

# 编译 luci-app-tailscale 包
echo "正在编译 luci-app-tailscale 包..."
make package/luci-app-tailscale/compile V=s
