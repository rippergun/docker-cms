# This is a comment
FROM ubuntu:16.04
MAINTAINER rippergun <rippergun@hotmail.com>
RUN apt-get update && apt-get install -y software-properties-common iputils-ping vim inetutils-telnet

#RUN echo "deb http://ppa.launchpad.net/ondrej/php5-7.1/ubuntu xenial main" > /etc/apt/sources.list.d/ondrej-php5-5_6-xenial.list \
#&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && apt-get -y update && apt-get install -y --allow-unauthenticated apache2 php7.1 php7.1-intl php-common \
php7.1-common php7.1-json php7.1-opcache php7.1-readline php7.1-cli php7.1-gd \
libapache2-mod-php7.1 libapache2-mod-fcgid apache2-doc apache2-utils php7.1-fpm php7.1-xml php-xdebug php7.1-zip php7.1-mbstring php7.1-dev \
php7.1-bcmath php7.1-mysql curl supervisor libhiredis-dev git openssh-server php7.1-curl php7.1-gmp php-amqp

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd

#supervisor
RUN mkdir -p /var/log/supervisor /run/php/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN ln -fs /home/projects/cms_php/corelibs/supervisor/videoEncode.conf /etc/supervisor/conf.d/videoEncode.conf
RUN ln -fs /home/projects/cms_php/corelibs/supervisor/imgResize.conf /etc/supervisor/conf.d/imgResize.conf

#php fpm

COPY php-fpm7.1.conf /etc/php/7.1/fpm/pool.d/www.conf

COPY php-conf.ini /etc/php/7.1/
COPY ports.conf /etc/apache2/conf-enabled/

RUN ln -fs /etc/php/7.1/php-conf.ini /etc/php/7.1/fpm/conf.d/ \
&& ln -fs /etc/php/7.1/php-conf.ini /etc/php/7.1/apache2/conf.d/ \
&& ln -fs /etc/php/7.1/php-conf.ini /etc/php/7.1/cli/conf.d/

RUN a2enmod proxy rewrite proxy_fcgi setenvif headers && a2dismod php7.1 mpm_prefork && a2enmod mpm_worker
RUN chown -R www-data:www-data /usr/lib/cgi-bin
RUN touch /usr/lib/cgi-bin/php7.1-fcgi
RUN a2enconf php7.1-fpm

#composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Redis
RUN cd /usr/src/ \
&& git clone git://github.com/nrk/phpiredis.git \
&& cd /usr/src/phpiredis \
&& phpize && ./configure --enable-phpiredis \
&& make && make install \
&& echo "extension=phpiredis.so" > /etc/php/7.1/mods-available/phpiredis.ini \
&& phpenmod phpiredis

RUN locale-gen fr_FR.UTF-8

RUN apt-get update && apt-get install -y --allow-unauthenticated php-ast
RUN cd /tmp && git clone https://github.com/nikic/php-ast.git && cd php-ast \
&& phpize && ./configure && make && make install && echo "extension=ast.so" > /etc/php/7.1/mods-available/ast.ini && phpenmod ast

#section sites
RUN ln -s /home/projects/babyblog2/vhost.conf /etc/apache2/sites-enabled/babyblog2.conf
RUN ln -s /home/projects/babyblog/vhost.conf /etc/apache2/sites-enabled/babyblog.conf
RUN ln -s /home/projects/SfBabyblog2/src/vhost.conf /etc/apache2/sites-enabled/sf-babyblog2.conf
RUN ln -s /home/projects/philippemorize/vhost.conf /etc/apache2/sites-enabled/philippemorize.conf
RUN ln -s /home/projects/saisonsvives/vhost.conf /etc/apache2/sites-enabled/saisonsvives.conf
RUN ln -s /home/projects/cms_php/vhost.conf /etc/apache2/sites-enabled/neocms.conf
#RUN ln -s /home/projects/NeoPrivate/vhost.conf /etc/apache2/sites-enabled/neoprivate.conf
RUN ln -s /home/projects/NeoPrivateSf/vhost.conf /etc/apache2/sites-enabled/neoprivatesf.conf
#RUN ln -s /home/projects/NeoPrivateWs/vhost.conf /etc/apache2/sites-enabled/neoprivatews.conf
RUN ln -s /home/projects/NeoPrivateWsSf/vhost.conf /etc/apache2/sites-enabled/neoprivatewssf.conf
#RUN ln -s /home/projects/cms_services/vhost.conf /etc/apache2/sites-enabled/cms_services.conf
RUN ln -s /home/projects/NeoServices/vhost.conf /etc/apache2/sites-enabled/neoservices.conf

RUN usermod -u 1001 www-data

ENV env dev

EXPOSE 80 8483 3306 22
CMD ["/usr/bin/supervisord"]
