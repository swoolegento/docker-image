#!/bin/bash

sed -i 's/memory_limit = 128M/memory_limit = '${PHP_MEMORY_LIMIT}'/' /usr/local/etc/php/php.ini

FILE=/var/www/html/app/etc/config.php
if test ! -f "$FILE"; then
    /bin/su -s /bin/bash -c '/home/docker/install.sh' docker
fi

if [ "$SWOOLE_YASD_ENABLE" == "1" ] && ! grep -q "zend_extension=yasd" /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini
then
    echo -e 'zend_extension=yasd\nyasd.debug_mode=remote\nyasd.remote_host='${SWOOLE_YASD_REMOTE_IP}'\nyasd.remote_port=9000' >> /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
