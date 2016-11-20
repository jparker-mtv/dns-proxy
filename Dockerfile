# I hate ads.
FROM archlinux:latest
MAINTAINER Taco Lover someguywholovestacos@gmail.com

# update in case older image, and pull packages for hostsblock and some debug tools that take <20MB
RUN pacman -Syu --noconfirm -q && pacman -S --noconfirm -q dnsmasq cronie net-tools bind-tools binutils fakeroot unzip p7zip pigz

# create unpriviliged user dev for aur and other compiling
RUN useradd -m dev -G wheel
# Download and insall hostsblock
RUN cd /tmp && curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/hostsblock.tar.gz --silent
RUN su dev -c /bin/bash -c "tar xzf /tmp/hostsblock.tar.gz -C /tmp; cd /tmp/hostsblock; makepkg -p /tmp/hostsblock/PKGBUILD"
RUN pacman --noconfirm -U /tmp/hostsblock/hostsblock-*.xz
# cron updates daily
RUN ln -sf /usr/sbin/hostsblock /etc/cron.daily/
# delete dev user and temp env
RUN userdel -f dev && rm -rf /home/dev/ && rm -rf /var/cache/pacman/pkg/* /tmp/hostsblock

# update config to use dnsmasq for hostsblock
RUN sed -i 's/hostsfile="\/etc\/hosts"/hostsfile="\/etc\/hosts.block"/g' /etc/hostsblock/hostsblock.conf 
RUN sed -i 's/# POSTPROCESSING SUBROUTINE.*$/postprocess(){\n    systemctl restart dnsmasq.service\n}/g'  /etc/hostsblock/hostsblock.conf

# hostblock is noisy for first run
RUN hostsblock -v 4 2>/dev/null


# configurae dnsmasq
RUN echo "user=root" > /etc/dnsmasq.conf
RUN echo "bind-dynamic" >> /etc/dnsmasq.conf
RUN echo "addn-hosts=/etc/hosts.block" >> /etc/dnsmasq.conf

RUN echo "nameserver 127.0.0.1" > /etc/resolv.conf

EXPOSE 53/udp
ENTRYPOINT ["dnsmasq", "-d", "-C", "/etc/dnsmasq.conf"]
