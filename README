# What is this for?

To Minimize the amount of variables between local development and deployment into production for Wordpress by using the same Wordpress version, and automating the setup of the instance. You just need to plug in a database.

You can use this project to develop your own custom themes, and include the repo in your CI/CD system of choice to build a docker container. To deploy, you just need to configure the container to use your database with environment variables.

The intention is you copy the entire repo and modify for your development. This project is not yet intended for use production environments. It is aimed at users who are comfortable using `docker` and `docker-compose`. Use at your own risk!

# How does this work?

This heavily utilizes [wp-cli](https://wp-cli.org/) the wordpress command-line interface, to automate the installation and configuration of the Wordpress core, plugins and themes.

During the Docker build example, we copy and zip the theme (because wp-cli wants themes provided as a .zip file)

When the Wordpress container starts, it will run the script `docker-entrypoint.sh`, which will install, and activate the theme installed during the docker build step (relative to the container's `/usr/src`) configured as `ACTIVE_THEME`.

# How to use for development?

Themes go in the `themes` directory.

You will need to modify `Dockerfile` to set `ACTIVE_THEME` to set the theme you want built into the container.

`docker-compose build` will build the docker image with Wordpress core + your theme.

On your first run `docker-compose up mariadb` should be run first since on first run it takes a few moments to start. Slower than Wordpress will tolerate.

`docker-compose up` will start both mariadb and wordpress up. The logins for your admin account are configured in `docker-compose.yml` through environment variables.

If you need to install/activate any other Wordpress stuff, my suggestion is you download/copy the files in Dockerfile, and install + activate in `docker-entrypoint.sh`.
