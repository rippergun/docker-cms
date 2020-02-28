# This is a comment
FROM ubuntu:18.04
MAINTAINER rippergun <rippergun@hotmail.com>
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y software-properties-common iputils-ping vim inetutils-telnet

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated apache2 php7.4 php7.4-intl php-common \
php7.4-common php7.4-json php7.4-opcache php7.4-readline php7.4-cli php7.4-gd \
libapache2-mod-php7.4 libapache2-mod-fcgid apache2-doc apache2-utils php7.4-fpm php7.4-xml php-xdebug php7.4-zip php7.4-mbstring php7.4-dev \
php7.4-bcmath php7.4-mysql curl supervisor libhiredis-dev git openssh-server php7.4-curl php7.4-gmp php-amqp

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd

#supervisor
RUN mkdir -p /var/log/supervisor /run/php/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN ln -fs /home/projects/cms_php/corelibs/supervisor/videoEncode.conf /etc/supervisor/conf.d/videoEncode.conf
RUN ln -fs /home/projects/cms_php/corelibs/supervisor/imgResize.conf /etc/supervisor/conf.d/imgResize.conf

#php fpm

COPY php-fpm7.4.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY php-conf.ini /etc/php/7.4/
COPY ports.conf /etc/apache2/conf-enabled/

RUN ln -fs /etc/php/7.4/php-conf.ini /etc/php/7.4/fpm/conf.d/ \
&& ln -fs /etc/php/7.4/php-conf.ini /etc/php/7.4/apache2/conf.d/ \
&& ln -fs /etc/php/7.4/php-conf.ini /etc/php/7.4/cli/conf.d/

RUN a2enmod proxy rewrite proxy_fcgi setenvif headers && a2dismod php7.4 mpm_prefork && a2enmod mpm_worker
RUN chown -R www-data:www-data /usr/lib/cgi-bin
RUN touch /usr/lib/cgi-bin/php7.4-fcgi
RUN a2enconf php7.4-fpm

#composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Redis
RUN cd /usr/src/ \
&& git clone git://github.com/nrk/phpiredis.git \
&& cd /usr/src/phpiredis \
&& phpize && ./configure --enable-phpiredis \
&& make && make install \
&& echo "extension=phpiredis.so" > /etc/php/7.4/mods-available/phpiredis.ini \
&& phpenmod phpiredis

RUN apt-get clean && apt-get update && apt-get install -y locales && locale-gen fr_FR.UTF-8

RUN apt-get update && apt-get install -y --allow-unauthenticated php-ast php-apcu
RUN cd /tmp && git clone https://github.com/nikic/php-ast.git && cd php-ast \
&& phpize && ./configure && make && make install && echo "extension=ast.so" > /etc/php/7.4/mods-available/ast.ini && phpenmod ast

#RUN apt-get update && apt-get install -y php-apcu
RUN pecl install timezonedb \
&& echo "extension=timezonedb.so" > /etc/php/7.4/mods-available/timezonedb.ini \
&& phpenmod timezonedb

RUN usermod -u 1001 www-data

ENV env dev

EXPOSE 80 8483 3306 22
CMD ["/usr/bin/supervisord"]
