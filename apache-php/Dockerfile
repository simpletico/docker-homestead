FROM php:5.6.31-apache
RUN pecl install redis-3.1.0 \
        && pecl install xdebug-2.5.0 \
        && docker-php-ext-enable redis xdebug

RUN docker-php-ext-install pdo pdo_mysql

RUN a2enmod rewrite \
 && a2enmod headers \
 && a2enmod expires

RUN apt-get update \
    && apt-get install -y python-software-properties \
    && apt-get install -y apt-file \
    && apt-file update \
    && apt-get install -y software-properties-common \
    && apt-get install -y vim

RUN apt-get update \
    && apt-get -q -y dist-upgrade \
    && apt-get -q -y install --no-install-recommends openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22

# To Install Composer
RUN apt-get update \
    && apt-get install -y git zip unzip php-pclzip

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && printf "\nPATH=\"~/.composer/vendor/bin:\$PATH\"\n" | tee -a ~/.profile

ADD php.ini /usr/local/etc/php/php.ini
