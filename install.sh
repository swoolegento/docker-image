#!/bin/bash

composer config -a -g http-basic.repo.magento.com \
 ${MAGENTO_REPO_USERNAME} ${MAGENTO_REPO_PASSWORD}
composer create-project --repository-url=https://repo.magento.com/ ${MAGENTO_REPO} .
composer require ${SWOOLEGENTO_REPO}
composer require markshust/magento2-module-disabletwofactorauth:2.0.0

php bin/magento setup:install \
    --base-url=https://${VIRTUAL_HOST} \
    --db-host=${DB_HOST} \
    --db-name=${DB_NAME} \
    --db-user=${DB_USER} \
    --db-password=${DB_PASSWORD} \
    --admin-firstname=admin \
    --admin-lastname=admin \
    --admin-email=admin@admin.com \
    --admin-user=admin \
    --admin-password=admin123 \
    --language=en_GB \
    --currency=GBP \
    --timezone=Europe/London \
    --use-rewrites=1 \
    --search-engine=elasticsearch7 \
    --elasticsearch-host=${ELASTICSEARCH_HOST} \
    --elasticsearch-port=${ELASTICSEARCH_PORT} \
    --elasticsearch-index-prefix=magento2 \
    --elasticsearch-timeout=15 \
    --cache-backend=redis \
    --cache-backend-redis-server=${REDIS_HOST} \
    --backend-frontname=admin

echo '{
    "http-basic": {
      "repo.magento.com": {
        "username": "'${MAGENTO_REPO_USERNAME}'",
        "password": "'${MAGENTO_REPO_PASSWORD}'"
      }
    }
}
' > var/composer_home/auth.json

php bin/magento deploy:mode:set developer
php bin/magento sampledata:deploy
php bin/magento setup:upgrade
