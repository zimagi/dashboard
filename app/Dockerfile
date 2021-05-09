FROM php:7.4-apache

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y libonig-dev libpng-dev libjpeg-dev libfreetype6-dev unzip sudo gettext-base git \
  && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-jpeg=/usr/local/share/ --with-freetype=/usr/local/share/ \
	&& docker-php-ext-install gd opcache mysqli pdo pdo_mysql bcmath

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& rm -f composer-setup.php

ENV PATH /usr/local/share/gitify:$PATH
RUN git clone https://github.com/modmore/Gitify.git /usr/local/share/gitify \
	&& composer install --no-interaction --no-dev --working-dir=/usr/local/share/gitify

ARG MODX_VERSION
ARG MODX_SHA1
RUN curl -o modx.zip -SL http://modx.com/download/direct/modx-${MODX_VERSION}-pl.zip \
	&& echo "$MODX_SHA1 *modx.zip" | sha1sum -c - \
	&& unzip modx.zip -d /tmp/ \
  && cp -Rf /tmp/modx-${MODX_VERSION}-pl/* /var/www/html \
	&& mv /var/www/html/ht.access /var/www/html/.htaccess \
  && rm -Rf /tmp/modx-${MODX_VERSION}-pl modx.zip \
	&& chown -R www-data:www-data /var/www/html

RUN mkdir /var/local/zimagi-ui
VOLUME /var/local/zimagi-ui

COPY ./app /usr/local/share/zimagi-ui
VOLUME /usr/local/share/zimagi-ui

RUN ln -s /usr/local/share/zimagi-ui/scripts/interface.sh /usr/local/bin/zimagi-interface
ENTRYPOINT ["zimagi-interface"]
