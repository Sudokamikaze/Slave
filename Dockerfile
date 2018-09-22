FROM archlinux/base:latest
LABEL maintainer="Sudokamikaze <Sudokamikaze@protonmail.com>"

ARG Jenkins_Secret
ARG Jenkins_Node_Name
ARG Jenkins_Master_IP
ARG Jenkins_Master_Port

ENV Jenkins_Secret=${Jenkins_Secret}
ENV Jenkins_Node_Name=${Jenkins_Node_Name}
ENV Jenkins_Master_IP=${Jenkins_Master_IP}
ENV Jenkins_Master_Port=${Jenkins_Master_Port}

# Enable multilib
COPY pacman.conf /etc/pacman.conf

# Update packman's base before installing anything
RUN pacman -Syyu --noconfirm --noprogressbar && pacman -S \
    base-devel gcc-multilib lib32-gcc-libs gcc-libs lib32-glibc help2man \
    git gnupg flex bison gperf sdl wxgtk \
    squashfs-tools curl ncurses zlib schedtool perl-switch zip unzip repo \
    libxslt python2-virtualenv bc rsync ccache jdk8-openjdk lib32-zlib \
    lib32-ncurses lib32-readline ninja lzop pngcrush imagemagick wget openssh nano net-tools \
    --noconfirm --needed --noprogressbar

# Downgrade gcc to 7
ADD https://archive.archlinux.org/packages/g/gcc/gcc-7.3.1%2B20180406-1-x86_64.pkg.tar.xz /tmp/gcc-7.pkg.tar.xz
ADD https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-7.3.1%2B20180406-1-x86_64.pkg.tar.xz /tmp/gcc-libs-7.pkg.tar.xz
ADD https://archive.archlinux.org/packages/l/lib32-gcc-libs/lib32-gcc-libs-7.3.1%2B20180406-1-x86_64.pkg.tar.xz /tmp/lib32-gcc-libs-7.pkg.tar.xz
RUN pacman -U /tmp/gcc-7.pkg.tar.xz /tmp/gcc-libs-7.pkg.tar.xz /tmp/lib32-gcc-libs-7.pkg.tar.xz --noconfirm

# Automatically ajust -jobs parameter in config and also set some optimizations
RUN sed -i 's|#MAKEFLAGS="-j2"|MAKEFLAGS="-j$(nproc)"|g' /etc/makepkg.conf && \
    sed -i 's|CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt"|CFLAGS="-march=native -O3 -pipe -fstack-protector-strong -fno-plt"|g' /etc/makepkg.conf && \
    sed -i 's|CXXFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt"|CXXFLAGS="${CFLAGS}"|g' /etc/makepkg.conf

# Add slave user for connecting
RUN useradd slave --home-dir=/home/jenkins && mkdir /home/jenkins && chown -R slave:users /home/jenkins

# Download sources 
RUN git clone https://aur.archlinux.org/ncurses5-compat-libs.git /tmp/build/ncurses5-compat-libs && \
    git clone https://aur.archlinux.org/lib32-ncurses5-compat-libs.git /tmp/build/lib32-ncurses5-compat-libs && \
    git clone https://aur.archlinux.org/crosstool-ng-git.git /tmp/build/crosstool-ng-git && \
    git clone https://aur.archlinux.org/xml2.git /tmp/build/xml2

# Set permissions for temportaly compilation
RUN chmod -R 777 /tmp/build && \
    chown -R slave:users /tmp/build

# Compile required tools!
RUN cd /tmp/build/ncurses5-compat-libs && su -c 'makepkg -s --skippgpcheck' slave && pacman -U ncurses5-compat*.tar.xz --noconfirm && \
    cd /tmp/build/lib32-ncurses5-compat-libs && su -c 'makepkg -s --skippgpcheck' slave && pacman -U lib32-ncurses5-compat*.tar.xz --noconfirm && \
    cd /tmp/build/crosstool* && su -c 'makepkg -s --skippgpcheck' slave && pacman -U crosstool*.tar.xz --noconfirm && \
    cd /tmp/build/xml2 && su -c 'makepkg -s --skippgpcheck' slave && pacman -U xml*.tar.xz --noconfirm

# Cleanup after all
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/pacman/pkg

# Download latest slave.jar
ADD http://${Jenkins_Master_IP}:${Jenkins_Master_Port}/jnlpJars/slave.jar /bin/slave.jar
RUN chmod +x /bin/slave.jar && chmod 755 /bin/slave.jar

USER slave

CMD [ "sh", "-c", "java -jar /bin/slave.jar -jnlpUrl http://${Jenkins_Master_IP}:${Jenkins_Master_Port}/computer/${Jenkins_Node_Name}/slave-agent.jnlp -secret ${Jenkins_Secret} -workDir '/home/jenkins/'" ]
