
#**********************************
# Base layer, install dependencies*
#**********************************

FROM archlinux:latest as base

# Go get dependencies
RUN pacman -Sy gcc --noconfirm;
RUN pacman -Sy clang --noconfirm;
RUN pacman -Sy make --noconfirm;
RUN pacman -Sy extra/cmake --noconfirm;
RUN pacman -Sy git --noconfirm;
RUN pacman -Sy base-devel --noconfirm;
RUN pacman -Sy dbus --noconfirm;
RUN pacman -S community/autoconf-archive --noconfirm;
RUN pacman -S extra/autoconf2.13 --noconfirm;
RUN pacman -S community/mk-configure --noconfirm;
RUN pacman -S extra/imagemagick --noconfirm;
RUN pacman -S extra/libsodium --noconfirm;
RUN pacman -Sy sudo --noconfirm;


# Create a non root user
FROM base as developer
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # add sudo support
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
 
USER $USERNAME
WORKDIR /home/developer

RUN git clone --depth=1 --branch=0.6.103  https://github.com/matrix-construct/construct.git construct
WORKDIR /home/developer/construct
RUN git submodule update --init deps/rocksdb
WORKDIR /home/developer/construct/deps/rocksdb
RUN git fetch --tags --force
RUN git checkout v5.17.2

WORKDIR /home/developer/construct


RUN export CXX=clang++;\
export CC=clang;\
./autogen.sh;\
./configure --prefix=$HOME/construct_sysroot --with-included-rocksdb=v6.12.7 --with-included-boost

RUN make




CMD ["echo", "Not yet configured to run anything. Exiting"]
