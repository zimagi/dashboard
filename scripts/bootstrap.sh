#!/usr/bin/env bash
#-------------------------------------------------------------------------------
set -e

TOP_DIR="`pwd`"
APP_USER="$1"
LOG_FILE="$2"
LOG_LEVEL="$3"
ZIMAGI_THEME="$4"
ZIMAGI_THEME_VERSION="$5"

if [ "$APP_USER" == 'root' ]
then
    APP_HOME="/root"
else
    APP_HOME="/home/${APP_USER}"
fi
#-------------------------------------------------------------------------------

export DEBIAN_FRONTEND=noninteractive

echo "Upgrading core OS packages" | tee -a "$LOG_FILE"
apt-get update -y >>"$LOG_FILE" 2>&1
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >>"$LOG_FILE" 2>&1

echo "Installing core dependencies" | tee -a "$LOG_FILE"
apt-get install -y \
        apt-utils \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        curl \
        wget \
        unzip \
     >>"$LOG_FILE" 2>&1

echo "Syncronizing time" | tee -a "$LOG_FILE"
apt-get --yes install ntpdate >>"$LOG_FILE" 2>&1
ntpdate pool.ntp.org >>"$LOG_FILE" 2>&1

echo "Installing development tools" | tee -a "$LOG_FILE"
apt-get install -y \
        net-tools \
        git \
        g++ \
        gcc \
        make \
        php-cli \
     >>"$LOG_FILE" 2>&1

echo "Installing Docker" | tee -a "$LOG_FILE"
apt-key adv --fetch-keys https://download.docker.com/linux/ubuntu/gpg >>"$LOG_FILE" 2>&1
add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable" \
    >>"$LOG_FILE" 2>&1

sudo apt-get update >>"$LOG_FILE" 2>&1
apt-get install -y docker-ce >>"$LOG_FILE" 2>&1
usermod -aG docker "$APP_USER" >>"$LOG_FILE" 2>&1

echo "Installing Docker Compose" | tee -a "$LOG_FILE"
if [ ! -f /usr/local/bin/docker-compose ]
then
    curl -L -o /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.29.1/docker-compose-Linux-x86_64 >>"$LOG_FILE" 2>&1
    chmod 755 /usr/local/bin/docker-compose >>"$LOG_FILE" 2>&1
fi

echo "Initializing configuration" | tee -a "$LOG_FILE"
"${APP_HOME}/bin/generate-env" "$APP_HOME" "$LOG_FILE" "$LOG_LEVEL" "$ZIMAGI_THEME" "$ZIMAGI_THEME_VERSION"

echo "Building application" | tee -a "$LOG_FILE"
docker-compose -f "${APP_HOME}/docker-compose.yml" build >>"$LOG_FILE" 2>&1

echo "Running application" | tee -a "$LOG_FILE"
docker-compose -f "${APP_HOME}/docker-compose.yml" up -d >>"$LOG_FILE" 2>&1
