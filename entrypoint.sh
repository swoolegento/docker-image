#!/bin/bash

if [[ ! -z "$PHP_MEMORY_LIMIT" ]]
then
    sed -i 's/memory_limit = 1G/memory_limit = '$PHP_MEMORY_LIMIT'/' /usr/local/etc/php/php.ini
fi

if test ! -f /var/www/html/app/etc/config.php
then
    /bin/su -s /bin/bash -c '/home/docker/install.sh' docker
else
    /bin/su -s /bin/bash -c 'php bin/magento setup:upgrade --keep-generated' docker
fi

if [ "$SWOOLE_YASD_ENABLE" == "1" ] && ! grep -q "zend_extension=yasd" /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini
then
    echo -e 'zend_extension=yasd\nyasd.debug_mode=remote\nyasd.remote_host='$SWOOLE_YASD_REMOTE_IP'\nyasd.remote_port=9000' >> /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini
fi

if [ "$BLACKFIRE_ENABLE" == "1" ] && test ! -f /etc/blackfire/agent
then
    blackfire agent:config --server-id=$BLACKFIRE_SERVER_ID --server-token=$BLACKFIRE_SERVER_TOKEN --socket=tcp://0.0.0.0:8307
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
