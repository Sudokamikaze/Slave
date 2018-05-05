FROM archlinux/base:latest
MAINTAINER Sudokamikaze <Sudokamikaze@protonmail.com>

ENV Jenkins_Secret="76008173e97a1bf2e7f9edd03543f7985b2ae4f0400d9ebcb7d5b3e2ac427437" 
ENV Jenkins_Node_Name="Builder"
ENV Jenkins_Master_IP="10.7.0.20"
ENV Jenkins_Master_Port="8090"

# Enable multilib
COPY pacman.conf /etc/pacman.conf

# Update packman's base before installing anything
RUN pacman -Syyu --noconfirm && pacman -S \
    base-devel gcc-multilib lib32-gcc-libs gcc-libs lib32-glibc help2man \
    git gnupg flex bison maven gradle gperf sdl wxgtk \
    squashfs-tools curl ncurses zlib schedtool perl-switch zip unzip repo \
    libxslt python2-virtualenv bc rsync ccache jdk8-openjdk lib32-zlib \
    lib32-ncurses lib32-readline ninja lzop pngcrush imagemagick wget openssh \
    --noconfirm --needed

# Automatically ajust -jobs parameter in config and also set some optimizations
# RUN sed -i 's|#MAKEFLAGS='"-j2"'|MAKEFLAGS='"-j$(nproc)"'|g' /etc/makepkg.conf && \
#    sed -i 's|CFLAGS='"-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt"'|CFLAGS='"-march=native -O3 -pipe -fstack-protector-strong -fno-plt"'|g' /etc/makepkg.conf && \
#    sed -i 's|CXXFLAGS='"-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt"'|CXXFLAGS='"${CFLAGS}"'|g' /etc/makepkg.conf

# Before compiling I'll modify /etc/makepkg
COPY makepkg.conf /etc/makepkg.conf

# Add slave user for SSH connecting
RUN useradd slave --home-dir=/home/jenkins && mkdir /home/jenkins && chown -R slave:users /home/jenkins

# Download sources 
RUN git clone https://aur.archlinux.org/ncurses5-compat-libs.git /tmp/build/ncurses5-compat-libs && \
    git clone https://aur.archlinux.org/lib32-ncurses5-compat-libs.git /tmp/build/lib32-ncurses5-compat-libs && \
    git clone https://aur.archlinux.org/crosstool-ng-git.git /tmp/build/crosstool-ng-git && \
    git clone https://aur.archlinux.org/xml2.git /tmp/build/xml2

# Set permissions for temportaly compilation
RUN chmod -R 777 /tmp/build

# Compile required tools!
RUN cd /tmp/build/ncurses5-compat-libs && su -c 'makepkg -s --skippgpcheck' slave && pacman -U ncurses5-compat*.tar.xz --noconfirm && \
    cd /tmp/build/lib32-ncurses5-compat-libs && su -c 'makepkg -s --skippgpcheck' slave && pacman -U lib32-ncurses5-compat*.tar.xz --noconfirm && \
    cd /tmp/build/crosstool* && su -c 'makepkg -s --skippgpcheck' slave && pacman -U crosstool*.tar.xz --noconfirm && \
    cd /tmp/build/xml2 && su -c 'makepkg -s --skippgpcheck' slave && pacman -U xml*.tar.xz --noconfirm

# Cleanup after all
RUN rm -rf /tmp/build && \
    rm -rf /var/cache/pacman/pkg

# Download latest slave.jar
ADD http://${Jenkins_Master_IP}:${Jenkins_Master_Port}/jnlpJars/slave.jar /bin/slave.jar

COPY slave_run.sh /bin/slave
RUN chmod +x /bin/slave && chmod 755 /bin/slave.jar

CMD ["/bin/slave"]