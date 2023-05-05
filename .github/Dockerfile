FROM ubuntu:20.04
MAINTAINER https://github.com/NativeScript

# Prevent interactive prompt while installing tzdata dependency
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Install dependencies
RUN dpkg --add-architecture i386
ENV DEBIAN_FRONTEND=noninteractive

# The first section contains all the dependencies that are needed to run this
# repo's scripts and install-build-deps in the first place.
#
# The second section contains the dependencies that V8's install-build-deps
# script installs. Pre-install them here to save time. When upgrading to a new
# version of V8 and building a new Docker image, check what install-build-deps
# installs in order to update this list.
#
# The third section contains packages additionally needed for cross compiling on
# all architectures.
#
# These installations are all done in the same RUN command in order to conserve
# space on the Docker image and create only one layer.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    \
    apt-utils git lsb-core ninja-build npm python3 sudo unzip wget \
    \
    binutils binutils-aarch64-linux-gnu binutils-arm-linux-gnueabihf \
    binutils-mips64el-linux-gnuabi64 binutils-mipsel-linux-gnu \
    gir1.2-gudev-1.0 bison cdbs curl dbus-x11 devscripts dpkg-dev elfutils \
    fakeroot flex gperf lib32z1 libasound2 libasound2-dev libasound2:i386 \
    libatk-bridge2.0-0:i386 libatk1.0-0 libatk1.0-0:i386 libatomic1:i386 \
    libatspi2.0-0 libatspi2.0-0:i386 libatspi2.0-dev libbrlapi-dev libbz2-dev \
    libc6-dev libcairo2 libcairo2-dev libcap-dev libcap2 libcups2 libcups2-dev \
    libcurl4-gnutls-dev libdbus-1-3:i386 libdrm-amdgpu1:i386 libdrm-dev \
    libdrm-intel1:i386 libdrm-nouveau2:i386 libdrm-radeon1:i386 libdrm2 \
    libdrm2:i386 libedit2:i386 libelf-dev libelf1:i386 libevdev-dev libevdev2 \
    libexpat1 libexpat1:i386 libffi-dev libfontconfig1 libfreetype6 libgbm-dev \
    libgbm1 libgl1-mesa-dri:i386 libgl1:i386 libglapi-mesa:i386 libglib2.0-0 \
    libglib2.0-dev libglib2.0-0:i386 libglu1-mesa-dev libglvnd0:i386 \
    libglx-mesa0:i386 libglx0:i386 libgtk-3-0 libgtk-3-dev libgudev-1.0-0 \
    libgudev-1.0-dev libinput-bin libinput-dev libinput10 libkrb5-dev \
    libllvm12:i386 libmtdev-dev libmtdev1 libncurses5:i386 libnspr4-dev \
    libnss3-dev libnss3:i386 libpam0g-dev libpango-1.0-0 libpango-1.0-0:i386 \
    libpci-dev libpci3 libpci3:i386 libpciaccess0:i386 libpixman-1-0 \
    libpulse-dev libsctp-dev libsensors5:i386 libspeechd-dev libspeechd2 \
    libsqlite3-0 libsqlite3-dev libssl-dev libstdc++-9-dev libstdc++6:i386 \
    libtinfo6:i386 libudev-dev libudev1:i386 libva-dev libvulkan-dev \
    libvulkan1:i386 libwacom-bin libwacom-common libwacom-dev libwacom2 \
    libwayland-client0:i386 libwayland-egl1-mesa libwww-perl libx11-6 \
    libx11-xcb1 libx11-xcb1:i386 libxau6 libxcb-dri2-0:i386 libxcb-dri3-0:i386 \
    libxcb-glx0:i386 libxcb-present0:i386 libxcb-randr0:i386 libxcb-shm0:i386 \
    libxcb-sync1:i386 libxcb-xfixes0:i386 libxcb1 libxcomposite1 \
    libxcomposite1:i386 libxcursor1 libxdamage1 libxdamage1:i386 libxdmcp6 \
    libxext6 libxfixes3 libxfixes3:i386 libxi6 libxinerama1 libxkbcommon0:i386 \
    libxrandr2 libxrandr2:i386 libxrender1 libxshmfence-dev libxshmfence1:i386 \
    libxslt1-dev libxss-dev libxt-dev libxtst-dev libxtst6 libxtst6:i386 \
    libxxf86vm1:i386 libzstd1:i386 lighttpd linux-libc-dev:i386 locales \
    mesa-vulkan-drivers:i386 openbox p7zip patch perl pkg-config rpm ruby \
    subversion uuid-dev wdiff x11-utils x11-utils xcompmgr xvfb xz-utils zip \
    zlib1g:i386 \
    \
    lib32stdc++-9-dev libc6-dev-arm64-cross libc6-dev-armel-armhf-cross \
    libc6-dev-armel-cross libc6-dev-armhf-cross libc6-dev-i386 \
    libgcc-10-dev-armhf-cross libsfstdc++-10-dev-armhf-cross \
    libstdc++-10-dev-armhf-cross libstdc++-9-dev-armhf-cross \
    libx32stdc++-9-dev && \
    rm -rf /var/lib/apt/lists/*

# Generate locales
RUN locale-gen da_DK.UTF-8
RUN locale-gen fr_FR.UTF-8
RUN locale-gen he_IL.UTF-8
RUN locale-gen zh_TW.UTF-8

# Set up 32-bit library builds
RUN echo "/usr/i686-linux-gnu/lib" >> /etc/ld.so.conf.d/i386-linux-gnu.conf
RUN ldconfig

# User ID must match the user ID used in the runner
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ubuntu
WORKDIR /home/ubuntu
