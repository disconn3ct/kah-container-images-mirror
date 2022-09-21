FROM ghcr.io/onedr0p/ubuntu:focal-20220826

ARG VERSION
ARG VERSION_LDAP_AUTH=3.0.0

# hadolint ignore=DL3002
USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

# ln: https://github.com/docker/buildx/issues/495#issuecomment-995503425
# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  export EXTRA_INSTALL_ARG="git" \
  && set -x \
  && apt-get -qq update \
  && \
  ln -s /usr/bin/dpkg-split /usr/sbin/dpkg-split \
  && ln -s /usr/bin/dpkg-deb /usr/sbin/dpkg-deb \
  && ln -s /bin/rm /usr/sbin/rm \
  && ln -s /bin/tar /usr/sbin/tar \
  && ln -s /bin/grep /usr/sbin/grep \
  && \
  apt-get -qq install -y \
    php-fpm \
    php-pdo php-gd php-pgsql php-pgsql php-mbstring \
	  php-intl php-xml php-curl php-ldap \
	  php-dom php-fileinfo php-json php-iconv \
	  php-zip \
	  postgresql-client sudo php-xdebug \
    nginx \
    ${EXTRA_INSTALL_ARG} \
  && git config --global --add safe.directory '*' \
  && cp /root/.gitconfig /var/www \
  && chown www-data: /var/www/.gitconfig \
  && chown root:kah /app \
  && git clone --depth 1 --single-branch  https://git.olved.dev/Devolved/tt-rss.git . \
  && git --no-pager log --pretty="version-%ct-%h" -n1 HEAD > version_static.txt \
  && \
     git clone --depth 1 --single-branch https://git.olved.dev/Devolved/ttrss-nginx-xaccel.git plugins/nginx_xaccel \
  && git clone --depth 1 --single-branch -b $VERSION_LDAP_AUTH https://github.com/k8s-at-home/TTRSS-Auth-LDAP.git plugins/auth_ldap \
  && git clone --depth 1 --single-branch https://github.com/HenryQW/mercury_fulltext.git plugins/mercury_fulltext \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-af-unburn.git plugins/af_unburn \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-af-fsckportal.git plugins/af_fsckportal \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-data-migration.git plugins/data_migration \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-enclosure-fix-type.git  plugins/af_enclosure_fix_type \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-proxy-http.git plugins/proxy_http \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-no-autoplay.git plugins/no_autoplay \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-no-video-preload.git plugins/no_video_preload \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-pause-bg.git plugins/af_zz_pause_bg \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-time-to-read.git plugins/time_to_read \
  && git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-auth-oidc.git plugins/auth_oidc \
  && git clone --depth 1 --single-branch https://github.com/supahgreg/ttrss-remember-previous/ plugins/remember_previous \
  && mkdir -p plugins/googlereaderkeys/ \
  && curl -fsSLo plugins/googlereaderkeys/init.php https://gist.githubusercontent.com/disconn3ct/cbd3a7e6d8b8ac8d7c33bbea7024cba1/raw/52bf811cf22e9174c099b3cbaaba393f921d0451/init.php \
  && curl -fsSLo plugins/af_comics/filters/af_comics_oglaf.php https://gist.github.com/disconn3ct/0ec9376731f245c5816e3b4ae63209f2/raw/587b8be9c4810fbe8b2c9fc287e3f9fa573e622a/af_comics_oglaf.php \
  && \
     git clone --depth 1 --single-branch https://github.com/levito/tt-rss-feedly-theme.git /tmp/feedly \
  && mv -v /tmp/feedly/feedly* themes/ \
  && rm -rf /tmp/feedly \
  && git clone --depth 1 --single-branch https://github.com/disconn3ct/ttrss-googlereader-mobile.git g2 \
  && \
     chmod -R a+rX /app \
  && chown -R www-data:www-data cache feed-icons lock \
  && cp -a config.php-dist config.php \
  && sed -i.bak 's/\(memory_limit =\) 128M/\1 256M/' /etc/php/7.4/fpm/php.ini \
  && sed -i.bak 's/;clear_env = .*/clear_env = no/i' /etc/php/7.4/fpm/pool.d/www.conf \
  && echo apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

#USER kah
#nginx and php use www-data as non-privileged user
#this container does not need to write persistent files - it only persists to DB

WORKDIR /config

EXPOSE 8080

COPY ./apps/tt-rss/nginx.conf /etc/nginx/sites-enabled/default
COPY ./apps/tt-rss/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
