FROM ghcr.io/onedr0p/alpine:3.17.0
EXPOSE 8080/tcp

ENV SCRIPT_ROOT=/app

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

WORKDIR /app

# hadolint ignore=DL3018
RUN \
   set -x && \
   apk add --no-cache dcron php81 php81-fpm php81-phar \
     php81-pdo php81-gd php81-pgsql php81-pdo_pgsql php81-xmlwriter \
     php81-mbstring php81-intl php81-xml php81-curl php81-simplexml \
     php81-session php81-tokenizer php81-dom php81-fileinfo php81-ctype \
     php81-json php81-iconv php81-pcntl php81-posix php81-zip php81-exif \
     php81-openssl git postgresql-client php81-pecl-xdebug rsync nginx && \
  sed -i 's/\(memory_limit =\) 128M/\1 256M/' /etc/php81/php.ini && \
  sed -i \
    -e 's/;\(clear_env\) = .*/\1 = no/i' \
    -e 's/^\(user\|group\) = .*/\1 = kah/i' \
      /etc/php81/php-fpm.d/www.conf && \
  sed -i \
    -e 's#\(access_log\) .*#\1 /dev/stdout main;#i' \
    -e 's#\(error_log\) .*#\1 /dev/stderr warn;#i' \
      /etc/nginx/nginx.conf && \
  git config --global --add safe.directory '*' && \
  cp /root/.gitconfig /home/kah && \
  chown kah: /home/kah/.gitconfig && \
  chown root:kah /app && \
  git clone --depth 1 --single-branch  https://git.olved.dev/Devolved/tt-rss.git . && \
  git --no-pager log --pretty="version-%ct-%h" -n1 HEAD > version_static.txt && \
  git clone --depth 1 --single-branch https://git.olved.dev/Devolved/ttrss-nginx-xaccel.git plugins/nginx_xaccel && \
  git clone --depth 1 --single-branch https://dev.tt-rss.org/tt-rss/ttrss-af-readability.git plugins/af_readability && \
  git clone --depth 1 --single-branch https://github.com/HenryQW/mercury_fulltext.git plugins/mercury_fulltext && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-af-unburn.git plugins/af_unburn && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-af-fsckportal.git plugins/af_fsckportal && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-data-migration.git plugins/data_migration && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-enclosure-fix-type.git  plugins/af_enclosure_fix_type && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-proxy-http.git plugins/proxy_http && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-no-autoplay.git plugins/no_autoplay && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-no-video-preload.git plugins/no_video_preload && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-pause-bg.git plugins/af_zz_pause_bg && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-time-to-read.git plugins/time_to_read && \
  git clone --depth 1 --single-branch https://git.tt-rss.org/fox/ttrss-auth-oidc.git plugins/auth_oidc && \
  git clone --depth 1 --single-branch https://github.com/supahgreg/ttrss-remember-previous/ plugins/remember_previous && \
  mkdir -p plugins/googlereaderkeys/ && \
  curl -fsSLo plugins/googlereaderkeys/init.php https://gist.githubusercontent.com/disconn3ct/cbd3a7e6d8b8ac8d7c33bbea7024cba1/raw/52bf811cf22e9174c099b3cbaaba393f921d0451/init.php && \
  curl -fsSLo plugins/af_comics/filters/af_comics_oglaf.php https://gist.github.com/disconn3ct/0ec9376731f245c5816e3b4ae63209f2/raw/587b8be9c4810fbe8b2c9fc287e3f9fa573e622a/af_comics_oglaf.php && \
  \
  git clone --depth 1 --single-branch https://github.com/levito/tt-rss-feedly-theme.git /tmp/feedly && \
  mv -v /tmp/feedly/feedly* themes/ && \
  rm -rf /tmp/feedly && \
  git clone --depth 1 --single-branch https://github.com/disconn3ct/ttrss-googlereader-mobile.git g2 && \
  chmod -R a+rX /app && \
  chown -R kah:kah cache feed-icons lock /var/log/php81 /var/log/nginx /var/lib/php81 /var/lib/nginx /run/nginx

ENV PHP_WORKER_MAX_CHILDREN=5
ENV PHP_WORKER_MEMORY_LIMIT=256M

ENV TTRSS_PHP_EXECUTABLE="/usr/bin/php81"

USER kah

COPY ./apps/tt-rss/nginx.conf /etc/nginx/http.d/default.conf
COPY ./apps/tt-rss/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
