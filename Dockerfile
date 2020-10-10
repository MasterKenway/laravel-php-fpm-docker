FROM php:7-fpm-alpine

LABEL maintainer="lyekumchew@gmail.com"

RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        curl-dev \
        imagemagick-dev \
        libtool \
        libxml2-dev \
	freetype-dev \
	libpng-dev \
	libjpeg-turbo-dev \
    && apk add --no-cache \
        curl \
        git \
	libzip-dev \
        imagemagick \
        mysql-client \
	freetype \
	libpng \
	libjpeg-turbo \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install \
        curl \
        iconv \
        mbstring \
        pdo \
        pdo_mysql \
        pcntl \
        tokenizer \
        xml \
        zip \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && apk del -f .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com

RUN composer global require "laravel/installer"

RUN apk update && apk add --update --no-cache nodejs libpng-dev py-pip

ENV PATH /root/.yarn/bin:$PATH

RUN  apk update \
  && apk add curl bash binutils tar nodejs-npm \
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
  && /bin/bash \
  && touch ~/.bashrc \
  && curl -o- -L https://yarnpkg.com/install.sh | bash \
  && yarn config set registry 'https://registry.npm.taobao.org' \
  && npm install -g cnpm --registry=https://registry.npm.taobao.org

WORKDIR /var/www

CMD ["php-fpm"]