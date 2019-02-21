#!/usr/bin/env bash

# TODO: VALIDATE THAT REQUIRED ENVIRONMENT VARIABLES ARE SET

# FIXME: Get this core download working in the Dockerfile
#wp core download

# Check if DB is initialized
# What happens when this already exists?
# FIXME: Might need to play around with `wp config has` to probe if the config exists. Like if we mount it in.
wp config create --dbname="${WORDPRESS_DB_NAME}" --dbuser="${WORDPRESS_DB_USER}" --dbpass="${WORDPRESS_DB_PASSWORD}" --dbhost="${WORDPRESS_DB_HOST}"

# Check if there's a wordpress install
if ! $(wp core is-installed); then
    wp core install --url="${SITE_URL}" --title="${SITE_TITLE}" --admin_email="${ADMIN_EMAIL}" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASSWORD}" --skip-email
fi

# Install theme
#wp theme install ../../../usr/src/${ACTIVE_THEME}.zip
wp theme install /usr/src/${ACTIVE_THEME}.zip
wp theme activate ${ACTIVE_THEME}

wp server --host=0.0.0.0
