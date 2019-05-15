#!/usr/bin/env bash

# Check if all our required environment vars are set
echo "
  ${WORDPRESS_DB_NAME:?WORDPRESS_DB_NAME is unset}
  ${WORDPRESS_DB_USER:?WORDPRESS_DB_USER is unset}
  ${WORDPRESS_DB_PASSWORD:?WORDPRESS_DB_PASSWORD is unset}
  ${WORDPRESS_DB_HOST:?WORDPRESS_DB_HOST is unset}
  ${SITE_URL:?SITE_URL is unset}
  ${SITE_TITLE:?SITE_TITLE is unset}
  ${ADMIN_EMAIL:?ADMIN_EMAIL is unset}
  ${ADMIN_USER:?ADMIN_USER is unset}
  ${ADMIN_PASSWORD:?ADMIN_PASSWORD is unset}
  ${ACTIVE_THEME:?ACTIVE_THEME is unset}
" > /dev/null

if [[ -n "${DEBUG+set}" ]] &&
   [[ `echo ${DEBUG} | tr "[A-Z]" "[a-z]"` == 'true' ]] ||
   [[ ${DEBUG} -eq 1 ]];
then
  echo "Running in debug mode"
  set -x
fi

# Check if DB is initialized
# What happens when this already exists?
# FIXME: Might need to play around with `wp config has` to probe if the config exists. Like if we mount it in.
wp_config_create_args=(
    --dbname="${WORDPRESS_DB_NAME}"
    --dbuser="${WORDPRESS_DB_USER}"
    --dbpass="${WORDPRESS_DB_PASSWORD}"
    --dbhost="${WORDPRESS_DB_HOST}"
)

# By default, try to reconnect for 60 seconds, in increments of 5
# Change DB_CONNECT_RETRIES to change how many times to retry
# DB_CONNECT_RETRY_SLEEP to change the time to wait between retries
for db_connect_attempt in `seq 1 ${DB_CONNECT_RETRIES:-12}`
do
  # Check if there's a port to parse out of WORDPRESS_DB_HOST, otherwise default to port 3306
  OLD_IFS="${IFS}"
  IFS=:
  read parsed_db_host parsed_db_port <<< "${WORDPRESS_DB_HOST}"
  IFS="${OLD_IFS}"

  # Check if the Wordpress DB is listening before trying to connect
  echo nc -vz "${parsed_db_host}" "${parsed_db_port:-3306}"
  nc -vz "${parsed_db_host}" "${parsed_db_port:-3306}"

  if [ $? -eq 0 ]; then
    wp config create "${wp_config_create_args[@]}";
    echo "Wordpress config creation succeeded (attempt: ${db_connect_attempt})";
    break;
  else
    echo "Wordpress config failed (attempt: ${db_connect_attempt})";

    # Sleep a few seconds to allow database to start up before trying again
    sleep ${DB_CONNECT_RETRY_SLEEP:-5};

    continue;
  fi

done

#Check if there's a wordpress install
if ! $(wp core is-installed); then
    echo "Installing Wordpress core";

    wp_core_install_args=(
    --url="${SITE_URL}"
    --title="${SITE_TITLE}"
    --admin_email="${ADMIN_EMAIL}"
    --admin_user="${ADMIN_USER}"
    --admin_password="${ADMIN_PASSWORD}"
    --skip-email
    )
    wp core install "${wp_core_install_args[@]}";
fi

echo "Installing wordpress theme: ${ACTIVE_THEME}"
wp theme install /usr/src/${ACTIVE_THEME}.zip

echo "Activating wordpress theme: ${ACTIVE_THEME}"
wp theme activate ${ACTIVE_THEME}


wp_server_args=(
    --host=${HOST:-0.0.0.0}
)

# If DEBUG env var is defined, and has a value, turn on debug mode
if [ ! -z ${DEBUG} ]; then
    wp_server_args+=('--debug')
fi

echo "Starting wordpress server"
wp server "${wp_server_args[@]}"
