#!/bin/bash
docker-compose start
#maybe wait some seconds before the server finishes starting up
#docker exec -it myhomestead_wl3-3.1_1 /bin/bash -c "chown nginx:nginx /opt/remi/php56/root/var/run/php-fpm/www.sock"
