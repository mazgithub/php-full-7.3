FROM php:7.3-cli-buster

RUN apt-get update; \
	apt-get install -y --no-install-recommends \
	libpng-dev \
	libbz2-dev \
	git \
	ssh \
	rsync \
	wget \
	libzip-dev \
	libxml2-dev \
        zip \
libxslt1.1 libxslt1-dev zlibc  apt-transport-https \
    && docker-php-ext-install bz2 \
	&& docker-php-ext-install zip \
	&& docker-php-ext-install gd \ 
	&& docker-php-ext-install sockets \
	&& docker-php-ext-install bcmath \
	&& docker-php-ext-install soap \
  && docker-php-ext-install xml intl xsl pdo_mysql soap \
	&& docker-php-ext-configure bcmath --enable-bcmath \
	&& docker-php-ext-configure zip --with-libzip \
	&& docker-php-ext-configure bz2 \
	&& docker-php-ext-configure soap --enable-soap

# Install php-ssh2
#RUN apt-get install -y libssh2-1-dev libssh2-1 \
#&& pecl install ssh2 \
#&& docker-php-ext-enable ssh2 
#RUN apt-get install -y libssh2-1 libssh2-1-dev
#RUN pecl install ssh2-1.2 docker-php-ext-enable ssh2
RUN apt-get install -y libssh2-1-dev \
&& CURRENT_PATH=$(pwd) \
&& cd /tmp && git clone https://git.php.net/repository/pecl/networking/ssh2.git && cd /tmp/ssh2 \
&& phpize && ./configure && make && make install > /dev/null 2>&1\
&& echo "extension=ssh2.so" > /usr/local/etc/php/conf.d/ext-ssh2.ini \
&& rm -rf /tmp/ssh2 \
&& cd ${CURRENT_PATH};


# Install composer

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install WP-CLI for wordpress

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

WORKDIR /tmp

RUN composer require "phpunit/phpunit:~5.3.4" --prefer-source --no-interaction && \
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit

RUN phpunit --version

CMD ["php", "-a"]
