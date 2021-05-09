#!/usr/bin/env bash
#-------------------------------------------------------------------------------

HOME_DIR="${1:-.}"
LOG_FILE="${2:-/dev/stderr}"
LOG_LEVEL="${3:-warning}"
ZIMAGI_THEME="${4:-https://github.com/zimagi/modx-theme-data-visualizer.git}"
ZIMAGI_THEME_VERSION="${5:-master}"

if [ ! -f "${HOME_DIR}/data/.env" ]
then
    cat > "${HOME_DIR}/data/.env" <<END
ZIMAGI_THEME=$ZIMAGI_THEME
ZIMAGI_THEME_VERSION=$ZIMAGI_THEME_VERSION
LOG_LEVEL=$LOG_LEVEL
MODX_VERSION=2.8.2
MODX_SHA1=66d885fcd61b6b6b7484df2429c91418c191c584
MODX_ADMIN_USER=admin
MODX_ADMIN_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
MODX_ADMIN_EMAIL=somebody@example.com
MODX_DB_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
MODX_DB_USER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
MODX_DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
MODX_DB_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
END
    env | grep "MODX_" >> "${HOME_DIR}/data/.env"
fi
sed -i "s@^LOG_LEVEL=.*\$@LOG_LEVEL=$LOG_LEVEL@" "${HOME_DIR}/data/.env" >>"$LOG_FILE" 2>&1

ln -fs "${HOME_DIR}/data/.env" "${HOME_DIR}/.env" >>"$LOG_FILE" 2>&1
