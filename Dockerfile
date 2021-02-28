FROM ubuntu:16.04
MAINTAINER Derek Williams <info@derekwilliams.biz>
LABEL Description="Cutting-edge LAMP stack, based on Ubuntu 16.04 LTS. Includes .htaccess support and popular PHP7 features, including composer and mail() function." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql derekvasilich/lamp" \
	Version="1.0"

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
RUN apt-get update

COPY debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN apt-get install -y zip unzip
RUN apt-get install -y tnef
RUN apt-get install -y libtool pkg-config build-essential autoconf automake uuid-dev
RUN apt-get install -y \
	php7.1 \
	php7.1-bz2 \
	php7.1-cgi \
	php7.1-cli \
	php7.1-common \
	php7.1-curl \
	php7.1-dev \
	php7.1-enchant \
	php7.1-fpm \
	php7.1-gd \
	php7.1-gmp \
	php7.1-imap \
	php7.1-interbase \
	php7.1-intl \
	php7.1-json \
	php7.1-ldap \
	php7.1-mbstring \
	php7.1-mcrypt \
	php7.1-mysql \
	php7.1-odbc \
	php7.1-opcache \
	php7.1-pgsql \
	php7.1-phpdbg \
	php7.1-pspell \
	php7.1-readline \
	php7.1-recode \
	php7.1-sqlite3 \
	php7.1-sybase \
	php7.1-tidy \
	php7.1-xmlrpc \
	php7.1-xsl \
	php7.1-zip
RUN apt-get install apache2 libapache2-mod-php7.1 -y
RUN apt-get install mariadb-common mariadb-server mariadb-client -y
RUN apt-get install postfix -y
RUN apt-get install git nodejs npm composer nano tree vim curl ftp -y
RUN npm install -g bower grunt-cli gulp

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

COPY index.php /var/www/html/
COPY run-lamp.sh /usr/sbin/

COPY build_zmq.sh /tmp/
RUN chmod +x /tmp/build_zmq.sh
RUN /tmp/build_zmq.sh

COPY zmq.ini /etc/php/7.1/mods-available
RUN phpenmod zmq

RUN a2enmod rewrite
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chmod +x /usr/sbin/run-lamp.sh
RUN chown -R www-data:www-data /var/www/html

VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/mysql
VOLUME /var/log/mysql
VOLUME /etc/apache2

EXPOSE 80
EXPOSE 3306

CMD ["/usr/sbin/run-lamp.sh"]
