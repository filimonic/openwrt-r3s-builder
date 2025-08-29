ARG OPENWRT_VERSION=24.10.2
ARG OPENWRT_PLATFORM=rockchip-armv8
ARG PROFILE="friendlyarm_nanopi-r5c"
ARG PACKAGES="base-files ca-bundle -dnsmasq dnsmasq-full dropbear e2fsprogs firewall4 fstools kmod-gpio-button-hotplug kmod-nft-offload libc libgcc libustream-mbedtls logd mkf2fs mtd netifd nftables odhcp6c odhcpd-ipv6only opkg partx-utils ppp ppp-mod-pppoe procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd kmod-r8169 -kmod-rtw88-8822ce -rtl8822ce-firmware -wpad-basic-mbedtls -iwinfo luci luci-app-acme acme-acmesh-dnsapi luci-proto-wireguard luci-app-attendedsysupgrade nano dnscrypt-proxy2 kmod-bonding luci-app-bcp38 luci-app-bcp38 nut parted losetup resize2fs blkid dockerd docker luci-app-dockerman openssh-sftp-server"
ARG DISABLED_SERVICES=""
ARG ROOTFS_PARTSIZE=4096

ARG IMAGE_NAME=ghcr.io/openwrt/imagebuilder:${OPENWRT_PLATFORM}-v${OPENWRT_VERSION}

FROM $IMAGE_NAME AS builder
ARG PROFILE ROOTFS_PARTSIZE PACKAGES DISABLED_SERVICES OPENWRT_PLATFORM OPENWRT_VERSION 
ENV PROFILE=${PROFILE} ROOTFS_PARTSIZE=${ROOTFS_PARTSIZE} PACKAGES=${PACKAGES} DISABLED_SERVICES=${DISABLED_SERVICES} OPENWRT_PLATFORM=${OPENWRT_PLATFORM} OPENWRT_VERSION=${OPENWRT_VERSION}
WORKDIR /builder
RUN [ "make", "image", "PROFILE:=${PROFILE}", "ROOTFS_PARTSIZE:=${ROOTFS_PARTSIZE}", "PACKAGES:=${PACKAGES}", "DISABLED_SERVICES:=${DISABLED_SERVICES}" ]
RUN mkdir ./output
RUN find ./build_dir/ -name "openwrt-${OPENWRT_VERSION}-${OPENWRT_PLATFORM}-${PROFILE}-*.img.gz" -type f -exec cp {} ./output \;

FROM alpine
WORKDIR /output
COPY --from=builder /builder/output/* ./
VOLUME [ "/out" ]
RUN mkdir -p /out
CMD ["/bin/cp", "-R", "-f", ".", "/out"]