#!/bin/bash
set -e
#
# Check and initialize database
#
TERM=dumb php /usr/local/share/zimagi-ui/scripts/init_db.php \
	"$MODX_DB_HOST" "$MODX_DB_PORT" \
	"$MODX_DB_ROOT_PASSWORD" \
	"$MODX_DB_USER" "$MODX_DB_NAME"
#
# Prepare theme
#
rm -Rf /var/local/zimagi-ui/theme _data .gitify
git clone -b "$ZIMAGI_THEME_VERSION" "$ZIMAGI_THEME" /var/local/zimagi-ui/theme
cp -Rf /var/local/zimagi-ui/theme/assets/. assets/
cp -R /var/local/zimagi-ui/theme/_data _data
cp /var/local/zimagi-ui/theme/.gitify .gitify
#
# Install MODX, packages, and sync data
#
CONFIG_FILE=$(TERM=dumb php /usr/local/share/zimagi-ui/scripts/check_install.php \
	"$MODX_DB_HOST" "$MODX_DB_PORT" \
	"$MODX_DB_USER" "$MODX_DB_PASSWORD" \
	"$MODX_DB_NAME" \
	core/config/config.inc.php \
)
if [ -z "$CONFIG_FILE" ]; then
	echo "Performing new installation"
	envsubst < "/usr/local/share/zimagi-ui/config.xml" > setup/config.xml
	sudo -u www-data php setup/index.php --installmode=new

	TERM=dumb php /usr/local/share/zimagi-ui/scripts/save_config.php \
		"$MODX_DB_HOST" "$MODX_DB_PORT" \
		"$MODX_DB_USER" "$MODX_DB_PASSWORD" \
		"$MODX_DB_NAME" \
		core/config/config.inc.php
else
	echo "Copying configuration"
	echo "$CONFIG_FILE" > core/config/config.inc.php
	rm -Rf setup
fi
chown -R www-data:www-data * .*
gitify package:install --all
gitify build -f
#
# Run web server
#
apache2-foreground
