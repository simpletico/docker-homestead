FROM fedora:24
MAINTAINER Andy Juarez <andy@juajim.info>

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

### Install packages ###

# Update Package List
RUN dnf -y --setopt=deltarpm=false update && dnf clean all

# install System and process monitoring utilities
RUN dnf -y --setopt=deltarpm=false install procps-ng

# Install & configure nginx
RUN dnf -y --setopt=deltarpm=false install nginx 
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN echo "nginx on Fedora" > /usr/share/nginx/html/index.html

# Install ssh server
RUN dnf -y --setopt=deltarpm=false install openssh-server pwgen passwd
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN dnf -y --setopt=deltarpm=false install vim

# Set My Timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

## Install SQLite
RUN dnf -y --setopt=deltarpm=false install sqlite #libsqlite-dev

# Install PHP Stuffs from remi's since they are not in the official anymore... 
# or at least no time to look for them :P
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf install -y http://rpms.remirepo.net/fedora/remi-release-24.rpm
#RUN dnf config-manager --set-enabled remi-php56
RUN dnf -y update
RUN dnf -y --setopt=deltarpm=false install php-5.6.30 php-cli php-fpm  php-mysqlnd php-mssql php-xml php-pgsql php-gd php-mcrypt \
    php-ldap php-imap php-soap php-mbstring php-pecl-memcache php-pecl-memcached php-pecl-mongo php-pear php-pdo \
    php-apcu php-json php-curl php-gmp php-xdebug php-redis

# Configure and secure PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini
RUN sed -i "s/^listen = \/run\/php-fpm\/www.sock/listen = \/var\/run\/php5-fpm.sock/" /etc/php-fpm.d/www.conf
#RUN sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php-fpm.d/www.conf
#RUN sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php-fpm.d/www.conf
#RUN sed -i "s/php_admin_flag\[log_errors\] = .*/;php_admin_flag[log_errors] =/" /etc/php-fpm.d/www.con
#RUN sed -i "s/php_admin_value\[error_log\] =.*/;php_admin_value[error_log] =/" /etc/php-fpm.d/www.conf
#RUN sed -i "s/php_admin_value\[error_log\] =.*/;php_admin_value[error_log] =/" /etc/php-fpm.d/www.conf
RUN echo "php_admin_value[display_errors] = 'stderr'" >> /etc/php-fpm.d/www.conf

#
# Install nodejs and npm
RUN dnf -y --setopt=deltarpm=false install npm 

# Show nodejs and npm versions installed
RUN node -v
RUN npm -v

# Install Composer
RUN dnf -y --setopt=deltarpm=false install composer less

# Install sudo
RUN dnf -y --setopt=deltarpm=false install sudo openssl

# Create our user
RUN useradd homestead
RUN echo -e "secret\nsecret" | (passwd --stdin homestead)
RUN echo ssh user password: secret
RUN usermod -a -G wheel homestead

## Add Composer Global Bin To Path
RUN printf "\nPATH=\"/home/homestead/.composer/vendor/bin:\$PATH\"\n" | tee -a /home/homestead/.profile

# Install Laravel Envoy
RUN sudo su homestead && \
    composer global require "laravel/envoy=~1.0"

# Set Some PHP CLI Settings
#sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/cli/php.ini
#sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/cli/php.ini
#sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/cli/php.ini
#sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/cli/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php.ini
RUN sed -i "s/memory_limit = 128/memory_limit = 512M/" /etc/php.ini
RUN sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini

# Enable Remote xdebug
echo "xdebug.remote_enable = 1" >> /etc/php.d/15-xdebug.ini
echo "xdebug.idekey = 'XDEBUG_ECLIPSE'" >> /etc/php.d/15-xdebug.ini 
echo "xdebug.remote_autostart = 1" >> /etc/php.d/15-xdebug.ini 
echo "xdebug.remote_connect_back = 1" >> /etc/php.d/15-xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php.d/15-xdebug.ini 
echo "xdebug.remote_handler=dbgp" >> /etc/php.d/15-xdebug.ini 
echo "xdebug.remote_host=localhost" >> /etc/php.d/15-xdebug.ini 

##echo "xdebug.var_display_max_depth = -1" >> /etc/php/fpm/conf.d/20-xdebug.ini
##echo "xdebug.var_display_max_children = -1" >> /etc/php/fpm/conf.d/20-xdebug.ini
##echo "xdebug.var_display_max_data = -1" >> /etc/php/fpm/conf.d/20-xdebug.ini

## Install A Few Other Things
#dnf -y --setopt=deltarpm=false install redis memcached beanstalkd
#
## Configure Beanstalkd
#
##sudo sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
#sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
##sudo /etc/init.d/beanstalkd start
#
## Configure nginx site
#block="server {
#    listen 80 default_server;
#    listen [::]:80 default_server ipv6only=on;
#
#    root /var/www/html;
#    server_name localhost;
#
#    index index.html index.htm index.php;
#
#    charset utf-8;
#
#    location / {
#        try_files \$uri \$uri/ /index.php?\$query_string;
#    }
#
#    location = /favicon.ico { access_log off; log_not_found off; }
#    location = /robots.txt  { access_log off; log_not_found off; }
#
#    access_log off;
#    error_log  /var/log/nginx/app-error.log error;
#
#    error_page 404 /index.php;
#
#    sendfile off;
#
#    location ~ \.php$ {
#        fastcgi_split_path_info ^(.+\.php)(/.+)$;
#        fastcgi_pass unix:/var/run/php5-fpm.sock;
#        fastcgi_index index.php;
#        include fastcgi.conf;
#    }
#
#    location ~ /\.ht {
#        deny all;
#    }
#}
#"
#
#cat > /etc/nginx/sites-enabled/default
#echo "$block" > "/etc/nginx/sites-enabled/default"
#systemctl restart nginx
#systemctl restart php5-fpm

