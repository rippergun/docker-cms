# This is a comment
FROM ubuntu:16.04
MAINTAINER rippergun <rippergun@hotmail.com>
RUN apt-get update && apt-get install -y software-properties-common iputils-ping vim inetutils-telnet

#RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu xenial main" > /etc/apt/sources.list.d/ondrej-php5-5_6-xenial.list \
#&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \

RUN add-apt-repository ppa:ondrej/php && apt-get -y update && apt-get install -y --allow-unauthenticated apache2 php5.6 php5.6-intl php-common \
php5.6-common php5.6-json php5.6-opcache php5.6-readline php5.6-cli php5.6-gd \
libapache2-mod-php5.6 libapache2-mod-fcgid apache2-doc apache2-utils php5.6-fpm php5.6-xml php-xdebug php5.6-zip php5.6-mbstring php5.6-dev \
php5.6-bcmath php5.6-mysql curl supervisor libhiredis-dev git openssh-server

#supervisor
RUN mkdir -p /var/log/supervisor /run/php/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN ln -fs /home/projects/cms_php/corelibs/supervisor/videoEncode.conf /etc/supervisor/conf.d/videoEncode.conf
RUN ln -fs /home/projects/cms_php/corelibs/supervisor/imgResize.conf /etc/supervisor/conf.d/imgResize.conf

#php fpm
COPY php-fpm5.6.conf /etc/php/5.6/fpm/pool.d/www.conf

COPY php-conf.ini /etc/php/5.6/

RUN ln -fs /etc/php/5.6/php-conf.ini /etc/php/5.6/fpm/conf.d/ \
&& ln -fs /etc/php/5.6/php-conf.ini /etc/php/5.6/apache2/conf.d/ \
&& ln -fs /etc/php/5.6/php-conf.ini /etc/php/5.6/cli/conf.d/

RUN a2enmod proxy rewrite proxy_fcgi setenvif headers && a2dismod php5.6 mpm_prefork && a2enmod mpm_worker
RUN chown -R www-data:www-data /usr/lib/cgi-bin
RUN touch /usr/lib/cgi-bin/php5.6-fcgi
RUN a2enconf php5.6-fpm

#composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Redis
RUN cd /usr/src/ \
&& git clone git://github.com/nrk/phpiredis.git \
&& cd /usr/src/phpiredis \
&& phpize && ./configure --enable-phpiredis \
&& make && make install \
&& echo "extension=phpiredis.so" > /etc/php/5.6/mods-available/phpiredis.ini \
&& phpenmod phpiredis

#section sites
RUN ln -s /home/projects/babyblog2/vhost.conf /etc/apache2/sites-enabled/babyblog2.conf
RUN ln -s /home/projects/babyblog/vhost.conf /etc/apache2/sites-enabled/babyblog.conf

RUN locale-gen fr_FR.UTF-8

RUN usermod -u 1001 www-data

EXPOSE 80 3306
CMD ["/usr/bin/supervisord"]
