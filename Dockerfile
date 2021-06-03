FROM ubuntu:20.04
MAINTAINER Derek Williams <info@derekwilliams.biz>
LABEL Description="Cutting-edge LAMP stack, based on Ubuntu 20.04 LTS. Includes .htaccess support and popular PHP7.4 features, including composer and npm function." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql derekvasilich/lamp" \
	Version="1.0"

RUN apt-get update
RUN apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
RUN apt-get update

COPY debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN apt-get install -y zip unzip
RUN apt-get install -y tnef
RUN apt-get install -y libtool pkg-config build-essential autoconf automake uuid-dev
RUN apt-get install -y php7.4 php7.4-bcmath php7.4-json php7.4-mbstring php7.4-mysql php7.4-bz2	php7.4-curl php7.4-xml php7.4-gd php7.4-zip php7.4-fpm
RUN apt-get install redis-server -y
RUN apt-get install apache2 libapache2-mod-php7.4 -y
RUN apt-get install mariadb-common mariadb-server mariadb-client -y
RUN apt-get install vim git composer tree vim-tiny curl ftp -y

## install npm 14.x
RUN curl -sL https://deb.nodesource.com/setup_14.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt-get install nodejs -y

RUN npm install -g bower grunt-cli gulp

## install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn -y

## BEGIN devel only
#RUN apt-get install -y \
#	php7.4-cgi \
#	php7.4-cli \
#	php7.4-common \
#	php7.4-dev \
#	php7.4-enchant \
#	php7.4-fpm \
#	php7.4-gmp \
#	php7.4-imap \
#	php7.4-interbase \
#	php7.4-intl \
#	php7.4-ldap \
#	php7.4-mcrypt \
#	php7.4-odbc \
#	php7.4-opcache \
#	php7.4-pgsql \
#	php7.4-phpdbg \
#	php7.4-pspell \
#	php7.4-readline \
#	php7.4-sqlite3 \
#	php7.4-sybase \
#	php7.4-tidy \
#	php7.4-xmlrpc \
#	php7.4-xsl \
#	php7.4-pcov
#RUN apt-get install postfix -y
## END devel only

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

COPY index.php /var/www/html/
COPY run-lamp.sh /usr/sbin/

# COPY build_zmq.sh /tmp/
# RUN chmod +x /tmp/build_zmq.sh
# RUN /tmp/build_zmq.sh

# COPY zmq.ini /etc/php/7.4/mods-available
# RUN phpenmod zmq

# enable php-fpm and mod rewrite
RUN a2enmod proxy_fcgi setenvif
RUN a2enconf php7.4-fpm
RUN a2dismod php7.4
RUN a2enmod rewrite
RUN a2dismod mpm_prefork 
RUN a2enmod mpm_event 
RUN a2enmod http2

RUN echo "<IfModule http2_module>" > /etc/apache2/conf-available/http2.conf
RUN echo "Protocols h2 h2c http/1.1" >> /etc/apache2/conf-available/http2.conf
RUN echo "H2Direct on" >> /etc/apache2/conf-available/http2.conf
RUN echo "</IfModule>" >> /etc/apache2/conf-available/http2.conf
RUN a2enconf http2

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