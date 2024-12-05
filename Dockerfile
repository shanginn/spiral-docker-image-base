ARG PHP_VERSION=8.4
ARG COMPOSER_VERSION=latest
ARG RR_VERSION=2024.2.1
ARG GRPC_VERSION=1.68.0
ARG PROTOBUF_VERSION=4.29.1
ARG XDEBUG_VERSION=3.4.0

ARG GROUP_ID=1337
ARG USER=som
ARG GROUP=$USER

FROM composer:$COMPOSER_VERSION AS composer
FROM ghcr.io/roadrunner-server/roadrunner:$RR_VERSION AS roadrunner

FROM php:${PHP_VERSION}-cli-alpine AS base

ARG GROUP_ID
ARG USER
ARG GROUP

RUN addgroup -g $GROUP_ID $USER
RUN adduser -u $GROUP_ID -G $GROUP -s /bin/sh -D $GROUP

COPY --from=roadrunner /usr/bin/rr /usr/local/bin/
COPY --from=composer /usr/bin/composer /usr/local/bin/

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

ARG GRPC_VERSION
ARG PROTOBUF_VERSION

RUN apk add --no-cache bash less \
    && install-php-extensions \
        pdo_pgsql redis pcntl sockets gd zip pcov git \
        grpc-$GRPC_VERSION \
        protobuf-$PROTOBUF_VERSION

WORKDIR /var/www/app
VOLUME /var/www/app

FROM base AS base-xdebug

ARG XDEBUG_VERSION
RUN install-php-extensions xdebug-$XDEBUG_VERSION xhprof