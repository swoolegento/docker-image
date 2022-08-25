FROM phpswoole/swoole:5.0.0-php8.1-alpine

RUN apk add aspell-dev \
    autoconf \
    bash \
    boost-dev \
    build-base \
    bzip2-dev \
    curl \
    freetype-dev \
    gettext-dev \
    gmp-dev \
    icu-dev \
    ldb-dev \
    libjpeg-turbo-dev \
    libldap \
    libpng-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    openldap-dev \
    openssh-server \
    supervisor \
    tidyhtml-dev \
    zlib-dev

RUN docker-php-ext-configure \
    gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    gettext \
    gmp \
    intl \
    ldap \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pspell \
    shmop \
    soap \
    sockets \
    sysvmsg \
    sysvsem \
    sysvshm \
    tidy \
    xsl \
    zip

COPY sshd_config /etc/ssh/
RUN echo "root:Docker!" | chpasswd; \
    cd /etc/ssh && ssh-keygen -A; \
    mkdir /var/run/sshd; chmod 755 /var/run/sshd;

RUN adduser docker; \
    usermod -a -G sudo docker; \
    echo 'docker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i 's/memory_limit = 128M/memory_limit = 1G/' /usr/local/etc/php/php.ini

WORKDIR /root

RUN curl -LO https://github.com/swoole/yasd/archive/refs/heads/master.zip && \
    unzip master && \
    rm master.zip && \
    cd yasd-master && \
    phpize --clean && \
    phpize && \
    ./configure && \
    make clean && \
    make && \
    make install && \
    cd ../ && \
    rm -rf yasd-master

RUN bash -c "$(curl -L https://installer.blackfire.io/installer.sh)"
RUN blackfire php:install
COPY blackfire-php-alpine_amd64-php-81.so /usr/local/lib/php/extensions/no-debug-non-zts-20210902/blackfire.so
RUN echo 'blackfire.agent_socket=tcp://0.0.0.0:8307' >> /usr/local/etc/php/conf.d/99-blackfire.ini

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

COPY install.sh /home/docker/install.sh
RUN chmod +x /home/docker/install.sh

EXPOSE 3000 2222

ENTRYPOINT ["/root/entrypoint.sh"]
