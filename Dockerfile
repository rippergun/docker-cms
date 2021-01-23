# This is a comment
FROM ubuntu:20.04
MAINTAINER rippergun <rippergun@hotmail.com>
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y software-properties-common iputils-ping vim inetutils-telnet

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated apache2 php8.0 php8.0-intl php-common \
php8.0-common php8.0-opcache php8.0-readline php8.0-cli php8.0-gd \
libapache2-mod-php8.0 libapache2-mod-fcgid apache2-doc apache2-utils php8.0-fpm php8.0-xml php-xdebug php8.0-zip php8.0-mbstring php8.0-dev \
php8.0-bcmath php8.0-mysql curl supervisor libhiredis-dev git openssh-server php8.0-curl php8.0-gmp php-amqp

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd

#supervisor
RUN mkdir -p /var/log/supervisor /run/php/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN ln -fs /home/projects/cms_php/corelibs/supervisor/videoEncode.conf /etc/supervisor/conf.d/videoEncode.conf
RUN ln -fs /home/projects/cms_php/corelibs/supervisor/imgResize.conf /etc/supervisor/conf.d/imgResize.conf

#php fpm

COPY php-fpm8.0.conf /etc/php/8.0/fpm/pool.d/www.conf

COPY php-conf.ini /etc/php/8.0/
COPY ports.conf /etc/apache2/conf-enabled/

RUN ln -fs /etc/php/8.0/php-conf.ini /etc/php/8.0/fpm/conf.d/ \
&& ln -fs /etc/php/8.0/php-conf.ini /etc/php/8.0/apache2/conf.d/ \
&& ln -fs /etc/php/8.0/php-conf.ini /etc/php/8.0/cli/conf.d/

RUN a2enmod proxy rewrite proxy_fcgi setenvif headers && a2dismod php8.0 mpm_prefork && a2enmod mpm_worker
RUN chown -R www-data:www-data /usr/lib/cgi-bin
RUN touch /usr/lib/cgi-bin/php8.0-fcgi
RUN a2enconf php8.0-fpm

#composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Redis
RUN cd /usr/src/ \
&& git clone git://github.com/nrk/phpiredis.git \
&& cd /usr/src/phpiredis \
&& phpize && ./configure --enable-phpiredis \
&& make && make install \
&& echo "extension=phpiredis.so" > /etc/php/8.0/mods-available/phpiredis.ini \
&& phpenmod phpiredis

RUN apt-get clean && apt-get update && apt-get install -y locales && locale-gen fr_FR.UTF-8

RUN apt-get update && apt-get install -y --allow-unauthenticated php-ast php-apcu unzip
RUN cd /tmp && git clone https://github.com/nikic/php-ast.git && cd php-ast \
&& phpize && ./configure && make && make install && echo "extension=ast.so" > /etc/php/8.0/mods-available/ast.ini && phpenmod ast

RUN pecl install timezonedb \
&& echo "extension=timezonedb.so" > /etc/php/8.0/mods-available/timezonedb.ini \
&& phpenmod timezonedb

RUN usermod -u 1001 www-data

RUN a2enmod ssl

RUN a2dismod mpm_worker mpm_prefork && a2enmod mpm_event http2

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV env dev

EXPOSE 80 443 8483 3306 22
CMD ["/usr/bin/supervisord"]
