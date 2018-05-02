FROM archlinux/base:latest
MAINTAINER Sudokamikaze <Sudokamikaze@protonmail.com>

# Update packman's base before installing anything
RUN pacman -Syyu --noconfirm && pacman -S \
    base-devel git gnupg flex bison maven gradle gperf sdl wxgtk \
    squashfs-tools curl ncurses zlib schedtool perf-switch zip unzip repo \
    libxslt python2-virtualenv bc rsync ccache jdk8-openjdk lib32-zlib \
    lib32-ncurses lib32-readline ninja ffmpeg xml2 lzop pngcrush imagemagick openssh \
    --noconfirm --needed

# Before compiling I'll modify /etc/makepkg
COPY makepkg.conf /etc/makepkg.conf

# Download sources 
RUN git clone https://aur.archlinux.org/ncurses5-compat-libs.git /tmp/build && \
    git clone https://aur.archlinux.org/lib32-ncurses5-compat-libs.git /tmp/build && \
    git clone https://aur.archlinux.org/crosstool-ng-git.git /tmp/build

# Compile required tools!
RUN cd /tmp/build/ncurses5-compat-libs && makepkg -s --skippgpcheck && pacman -U ncurses5-compat*.tar.xz --noconfirm && \
    cd /tmp/build/lib32-ncurses5-compat-libs && makepkg -s --skippgpcheck && pacman -U lib32-ncurses5-compat*.tar.xz --noconfirm
    cd /tmp/build/crosstool* && makepkg -s --skippgpcheck && pacman -U crosstool*.tar.xz --noconfirm

# Add slave user for SSH connecting
RUN useradd slave --home-dir=/home/slave && mkdir /opt/jenkins && chown -R slave:users /home/jenkins

# Copy example conf to ssh
COPY sshd_config /etc/ssh/sshd_config

# Add overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# Cleanup after all
RUN rm -rf /tmp/build && rm -rf /var/cache/pacman/pkg && rm /tmp/s6-overlay-amd64.tar.gz

ENTRYPOINT ["/init"]
CMD ["sshd"]