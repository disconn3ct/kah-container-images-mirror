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
  && chown root:kah /app \
  && git clone https://git.tt-rss.org/fox/tt-rss.git . \
  && git clone https://git.tt-rss.org/fox/ttrss-nginx-xaccel.git plugins.local/nginx_xaccel \
  && git clone -b $VERSION_LDAP_AUTH https://github.com/k8s-at-home/TTRSS-Auth-LDAP.git plugins.local/auth_ldap \
  && git clone https://github.com/HenryQW/mercury_fulltext.git plugins.local/mercury_fulltext \
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
