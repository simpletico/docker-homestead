FROM fedora:24
MAINTAINER Andy Juarez <andy@juajim.info>

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
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
RUN dnf -y --setopt=deltarpm=false install procps-ng tar

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
##RUN dnf -y --setopt=deltarpm=false install php-5.6.30 php-cli php-fpm  php-mysqlnd php-mssql php-xml php-pgsql php-gd php-mcrypt \
##    php-ldap php-imap php-soap php-mbstring php-pecl-memcache php-pecl-memcached php-pecl-mongo php-pear php-pdo \
##    php-apcu php-json php-curl php-gmp php-xdebug php-redis
RUN dnf -y --setopt=deltarpm=false --enablerepo=remi install php56 php56-php-common php56-php-cli php56-php-mbstring php56-php-mcrypt \
    php56-php-pear php56-php-xml php56-runtime php56-php-mysqlnd \
    php56-php-xdebug php56-php-fpm php56-php-json php56-php-curl

# Configure and secure PHP
##--RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php.ini
##--RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf
##--RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini
#RUN sed -i "s/^listen = \listen = \/opt\/remi\/php56\/root\/var\/run\/php-fpm\/www.sock/listen = \/var\/run\/php5-fpm.sock/" /opt/remi/php56/root/etc/php-fpm.d/www.conf
#RUN echo "php_admin_value[display_errors] = 'stderr'" >> /opt/remi/php56/root/etc/php-fpm.d/www.conf
#--RUN sed -i "s/^listen = \/run\/php-fpm\/www.sock/listen = \/var\/run\/php5-fpm.sock/" /opt/remi/php56/php-fpm.d/www.conf
#--RUN echo "php_admin_value[display_errors] = 'stderr'" >> /opt/remi/php56/php-fpm.d/www.conf

# Install nodejs and npm
RUN dnf -y --setopt=deltarpm=false install npm 

# Show nodejs and npm versions installed
RUN node -v
RUN npm -v

# Install nodejs version manager and minimum node version required.
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.9.4
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
        && source $NVM_DIR/nvm.sh \
        && nvm install $NODE_VERSION \
        && nvm alias default $NODE_VERSION \
        && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH


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
RUN echo "xdebug.remote_enable = 1" >> /etc/php.d/15-xdebug.ini
RUN echo "xdebug.idekey = 'XDEBUG_ECLIPSE'" >> /etc/php.d/15-xdebug.ini 
RUN echo "xdebug.remote_autostart = 1" >> /etc/php.d/15-xdebug.ini 
RUN echo "xdebug.remote_connect_back = 1" >> /etc/php.d/15-xdebug.ini
RUN echo "xdebug.remote_port = 9000" >> /etc/php.d/15-xdebug.ini 
RUN echo "xdebug.remote_handler=dbgp" >> /etc/php.d/15-xdebug.ini 
RUN echo "xdebug.remote_host=localhost" >> /etc/php.d/15-xdebug.ini 

####################################################################################################
# install git for source control
RUN dnf -y --setopt=deltarpm=false install git

# install supervisor to run processes
RUN dnf -y --setopt=deltarpm=false install supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Delete ssh login blocking file...
RUN rm /run/nologin

# Include the nginx enabled sites from modular conf directory...
COPY sites.conf /etc/nginx/conf.d/sites.conf

## Install Node required packages
RUN npm -g install grunt-cli karma bower

#########################################

EXPOSE 80 22 35729 9876

#########################################

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
