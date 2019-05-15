FROM wordpress:cli-php7.0

# Just using root to set things up
USER root

# Install Wordpress into another directory and change ownership
# The wordpress:cli declares the pwd (/var/www/html) as a VOLUME, so no persistence
WORKDIR /usr/src/wordpress
ENV WP_VERSION=4.9.10
RUN wp core download --version=${WP_VERSION} --skip-content --allow-root && chown -R www-data:www-data /usr/src/wordpress

# Replace with your custom theme installed in the themes directory
ENV ACTIVE_THEME boxstyle
COPY --chown=www-data:www-data themes/${ACTIVE_THEME} ${ACTIVE_THEME} 

RUN apk -U add --no-cache \
    zip && \
    # If you need to do any frontend compilation for your theme, do that prior to theme zip step
    # e.g.
    # cd ${ACTIVE_THEME}/styles && npm install && cd - && \
    zip -r ${ACTIVE_THEME}.zip ./${ACTIVE_THEME} && rm -rf ./${ACTIVE_THEME} && \
    mv -v ${ACTIVE_THEME}.zip /usr/src/

# Switching to less privileged user
USER www-data
COPY --chown=www-data:www-data docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
CMD /docker-entrypoint.sh
