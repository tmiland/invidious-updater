#!/usr/bin/env bash
# shellcheck disable=SC2181,SC2059,SC2086,SC2002,SC2162,SC2005,SC2015,SC2308,SC2006,SC2236,SC2231,SC1091

## Author: Tommy Miland (@tmiland) - Copyright (c) 2022


######################################################################
####                    Invidious Update.sh                       ####
####            Automatic update script for Invidious             ####
####            Script to update or install Invidious             ####
####                   Maintained by @tmiland                     ####
######################################################################

VERSION='2.1.2' # Must stay on line 14 for updater to fetch the numbers

#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2022 Tommy Miland
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#------------------------------------------------------------------------------#
## Uncomment for debugging purpose
#set -o errexit
#set -o pipefail
#set -o nounset
#set -o xtrace
#timestamp
# time_stamp=$(date)
# Detect absolute and full path as well as filename of this script
cd "$(dirname "$0")" || exit
CURRDIR=$(pwd)
SCRIPT_FILENAME=$(basename "$0")
cd - > /dev/null || exit
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
SCRIPT_DIR=$(dirname "${sfp}")
# Icons used for printing
ARROW='➜'
DONE='✔'
ERROR='✗'
WARNING='⚠'
# Colors used for printing
RED='\033[0;31m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
# DARKORANGE="\033[38;5;208m"
# CYAN='\033[0;36m'
# DARKGREY="\033[48;5;236m"
NC='\033[0m' # No Color
# Text formatting used for printing
# BOLD="\033[1m"
# DIM="\033[2m"
# UNDERLINED="\033[4m"
# INVERT="\033[7m"
# HIDDEN="\033[8m"
# Script name
SCRIPT_NAME="Invidious Update.sh"
# Repo name
REPO_NAME="tmiland/invidious-updater"
# Set update check
UPDATE_SCRIPT='no'
# Set username
USER_NAME=invidious
# Set userdir
USER_DIR="/home/invidious"
# Set repo Dir
REPO_DIR=$USER_DIR/invidious
# Set config file path
IN_CONFIG=${REPO_DIR}/config/config.yml
# Service name
SERVICE_NAME=invidious.service
# Default branch
IN_BRANCH=master
# Default domain
DOMAIN=${DOMAIN:-}
# Default ip
IP=${IP:-localhost}
# Default port
PORT=${PORT:-3000}
# Default dbname
PSQLDB=${PSQLDB:-invidious}
# Generate db password
PSSQLPASS_GEN=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
# Default dbpass (generated)
PSQLPASS=${PSQLPASS:-$PSSQLPASS_GEN}
# Default https only
HTTPS_ONLY=${HTTPS_ONLY:-false}
# Default external port
EXTERNAL_PORT=${EXTERNAL_PORT:-}
# Default admins
ADMINS=${ADMINS:-}
# Default Captcha Key
CAPTCHA_KEY=${CAPTCHA_KEY:-}
# Default Swap option
SWAP_OPTIONS=${SWAP_OPTIONS:-n}
# Docker compose repo name
# COMPOSE_REPO_NAME="docker/compose"
# Docker compose version
DOCKER_COMPOSE_VER=1.25.0
# Logfile
LOGFILE=invidious_update.log

install_log() {
  exec > >(tee ${LOGFILE}) 2>&1
}

read_sleep() {
    read -rt "$1" <> <(:) || :
}

indexit() {
  cd "${CURRDIR}" || exit
  ./"${SCRIPT_FILENAME}"
}

repoexit() {
  cd ${REPO_DIR} || exit 1
}
# Distro support
ARCH_CHK=$(uname -m)
if [ ! ${ARCH_CHK} == 'x86_64' ]; then
  echo -e "${RED}${ERROR} Error: Sorry, your OS ($ARCH_CHK) is not supported.${NC}"
  exit 1;
fi
shopt -s nocasematch
  if [[ -f /etc/debian_version ]]; then
    DISTRO=$(cat /etc/issue.net)
  elif [[ -f /etc/redhat-release ]]; then
    DISTRO=$(cat /etc/redhat-release)
  elif [[ -f /etc/os-release ]]; then
    DISTRO=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
  fi
case "$DISTRO" in
  Debian*|Ubuntu*|LinuxMint*|PureOS*|Pop*|Devuan*)
    # shellcheck disable=SC2140
    PKGCMD="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
    LSB=lsb-release
    DISTRO_GROUP=Debian
    ;;
  CentOS*)
    PKGCMD="yum install -y"
    LSB=redhat-lsb
    DISTRO_GROUP=RHEL
    ;;
  Fedora*)
    PKGCMD="dnf install -y"
    LSB=redhat-lsb
    DISTRO_GROUP=RHEL
    ;;
  Arch*|Manjaro*)
    PKGCMD="yes | LC_ALL=en_US.UTF-8 pacman -S"
    LSB=lsb-release
    DISTRO_GROUP=Arch
    ;;
  *) echo -e "${RED}${ERROR} unknown distro: '$DISTRO'${NC}" ; exit 1 ;;
esac
if ! lsb_release -si >/dev/null 2>&1; then
  echo ""
  echo -e "${RED}${ERROR} Looks like ${LSB} is not installed!${NC}"
  echo ""
  read -r -p "Do you want to download ${LSB}? [y/n]? " ANSWER
  echo ""
  case $ANSWER in
    [Yy]* )
      echo -e "${GREEN}${ARROW} Installing ${LSB} on ${DISTRO}...${NC}"
      su -s "$(which bash)" -c "${PKGCMD} ${LSB}" || echo -e "${RED}${ERROR} Error: could not install ${LSB}!${NC}"
      echo -e "${GREEN}${DONE} Done${NC}"
      read_sleep 3
      indexit
      ;;
    [Nn]* )
      exit 1;
      ;;
    * ) echo "Enter Y, N, please." ;;
  esac
fi
SUDO=""
UPDATE=""
UPGRADE=""
INSTALL=""
UNINSTALL=""
PURGE=""
CLEAN=""
PKGCHK=""
PGSQL_SERVICE=""
DOCKER_PKGS=""
SYSTEM_CMD=""
shopt -s nocasematch
if [[ $DISTRO_GROUP == "Debian" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  SUDO="sudo"
  # shellcheck disable=SC2140
  UPDATE="apt-get -o Dpkg::Progress-Fancy="1" update -qq"
  # shellcheck disable=SC2140
  UPGRADE="apt-get -o Dpkg::Progress-Fancy="1" upgrade -qq"
  # shellcheck disable=SC2140
  INSTALL="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
  # shellcheck disable=SC2140
  UNINSTALL="apt-get -o Dpkg::Progress-Fancy="1" remove -qq"
  # shellcheck disable=SC2140
  PURGE="apt-get purge -o Dpkg::Progress-Fancy="1" -qq"
  CLEAN="apt-get clean && apt-get autoremove -qq"
  PKGCHK="dpkg -s"
  # Pre-install packages
  PRE_INSTALL_PKGS="apt-transport-https git curl sudo gnupg"
  # Install packages
  INSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-bin postgresql libsqlite3-dev zlib1g-dev libpcre3-dev libevent-dev"
  #Uninstall packages
  UNINSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-bin libsqlite3-dev zlib1g-dev libpcre3-dev libevent-dev"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql"
  # Docker pkgs
  DOCKER_PKGS="docker-ce docker-ce-cli"
  # System cmd
  SYSTEM_CMD="systemctl"
  # Postgresql config folder
  pgsql_config_folder=$(find "/etc/postgresql/" -maxdepth 1 -type d -name "*" | sort -V | tail -1)
elif [[ $(lsb_release -si) == "CentOS" ]]; then
  SUDO="sudo"
  UPDATE="yum update -q"
  UPGRADE="yum upgrade -q"
  INSTALL="yum install -y -q"
  UNINSTALL="yum remove -y -q"
  PURGE="yum purge -y -q"
  CLEAN="yum clean all -y -q"
  PKGCHK="rpm --quiet --query"
  # Pre-install packages
  PRE_INSTALL_PKGS="epel-release git curl sudo dnf-plugins-core"
  # Install packages
  INSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel postgresql postgresql-server zlib-devel gcc libevent-devel"
  #Uninstall packages
  UNINSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel zlib-devel gcc libevent-devel"
# PostgreSQL Service
  PGSQL_SERVICE="postgresql"
  # Docker pkgs
  DOCKER_PKGS="docker-ce docker-ce-cli"
  # System cmd
  SYSTEM_CMD="systemctl"
  # Postgresql config folder
  pgsql_config_folder=$(find "/etc/postgresql/" -maxdepth 1 -type d -name "*" | sort -V | tail -1)
elif [[ $(lsb_release -si) == "Fedora" ]]; then
  SUDO="sudo"
  UPDATE="dnf update -q"
  UPGRADE="dnf upgrade -q"
  INSTALL="dnf install -y -q"
  UNINSTALL="dnf remove -y -q"
  PURGE="dnf purge -y -q"
  CLEAN="dnf clean all -y -q"
  PKGCHK="rpm --quiet --query"
  # Pre-install packages
  PRE_INSTALL_PKGS="git curl sudo"
  # Install packages
  INSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel postgresql postgresql-server zlib-devel gcc libevent-devel"
  #Uninstall packages
  UNINSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel zlib-devel gcc libevent-devel"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql"
  # Docker pkgs
  DOCKER_PKGS="docker-ce docker-ce-cli"
  # System cmd
  SYSTEM_CMD="systemctl"
  # Postgresql config folder
  pgsql_config_folder=$(find "/etc/postgresql/" -maxdepth 1 -type d -name "*" | sort -V | tail -1)
elif [[ $DISTRO_GROUP == "Arch" ]]; then
  SUDO="sudo"
  UPDATE="pacman -Syu"
  INSTALL="pacman -S --noconfirm --needed"
  UNINSTALL="pacman -R"
  PURGE="pacman -Rs"
  CLEAN="pacman -Sc"
  PKGCHK="pacman -Qs"
  # Pre-install packages
  PRE_INSTALL_PKGS="git curl sudo"
  # Install packages
  INSTALL_PKGS="base-devel shards crystal librsvg postgresql"
  #Uninstall packages
  UNINSTALL_PKGS="base-devel shards crystal librsvg"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql"
  # Docker pkgs
  DOCKER_PKGS="docker"
  # System cmd
  SYSTEM_CMD="systemctl"
  # Postgresql config folder
  pgsql_config_folder="/var/lib/postgres/data"
else
  echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
  exit 1;
fi
# Check if systemd is installed on Devuan
if [[ $(lsb_release -si) == "Devuan" ]]; then
  if ( ! $SYSTEM_CMD 2>/dev/null); then
    echo -e "${RED}${ERROR} Error: Sorry, you need systemd to run this script.${NC}"
    exit 1;
  fi
fi

usage() {
  echo "script usage: $SCRIPT_FILENAME [-u] [-d] [-c] [-m] [-l]"
  echo "   [-u] Check for script update"
  echo "   [-d] Do not check for script update (Default)"
  echo "   [-c] Update Invidious with cron"
  echo "   [-m] Database Maintenance"
  echo "   [-l] Activate logging"
}

# Make sure that the script runs with root permissions
chk_permissions() {
  if [[ "$EUID" != 0 ]]; then
    echo -e "${RED}${ERROR} This action needs root permissions."
    echo -e "${NC}  Please enter your root password...";
    cd "$CURRDIR" || exit
    su -s "$(which bash)" -c "./$SCRIPT_FILENAME"
    cd - > /dev/null || exit
    exit 0;
  fi
}

ADD_SWAP_URL=https://raw.githubusercontent.com/tmiland/swap-add/master/swap-add.sh

add_swap() {
  if [[ $(command -v 'curl') ]]; then
    # shellcheck disable=SC1090
    source <(curl -sSLf $ADD_SWAP_URL)
  elif [[ $(command -v 'wget') ]]; then
    # shellcheck disable=SC1090
    . <(wget -qO - $ADD_SWAP_URL)
  else
    echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
    exit 0
  fi
  read_sleep 3
  indexit
}

install_nginx(){
  echo ""
  echo "   1) Install Nginx"
  echo "   2) Install Nginx Vhost for Invidious"
  echo "   3) Install Let's Encrypt SSL certificates"
  echo ""
  while [[ $NGINX != "1" && $NGINX != "2" && $NGINX != "3" ]]; do
    read -p "Select an option [1-3]: " NGINX
  done
  case $NGINX in
    1)
      nginx-autoinstall
      ;;
    2)
      install_nginx_vhost
      ;;
    3)
      install_certbot
      ;;
  esac
}

install_certbot() {
  shopt -s nocasematch
  if [[ $(lsb_release -si) == "Debian"    ||
        $(lsb_release -si) == "Ubuntu"    ||
        $(lsb_release -si) == "LinuxMint" ||
        $(lsb_release -si) == "PureOS" ]]; then
    NGINX_VHOST_DIR=/etc/nginx/sites-available
    get_domain() {
      # shellcheck disable=SC2046
      echo $(sed -n 's/.*domain *: *\([^ ]*.*\)/\1/p' "$1")
    }
    NGINX_DOMAIN_NAME=$(get_domain "$IN_CONFIG")
    NGINX_VHOST=$NGINX_DOMAIN_NAME.conf

  if [[ -d "${NGINX_VHOST_DIR}" ]]; then
    echo ""
    read -p "Do you want to install Let's Encrypt SSL certificates for Invidious? [y/n/q]?" ANSWER
    echo ""
    echo "Your Invidious domain name: $NGINX_DOMAIN_NAME"
    echo ""

    case $ANSWER in
    [Yy]* )
    # Ask user for admin email
    read -p "Please enter your admin email for the domain [E.G: admin@invidious.domain.tld]:" ADMIN_EMAIL
    # Set Acme home folder ()
    ACME_HOME=/etc/acme
    # Install dependencies
    apt-get install openssl cron socat curl
    # Clone from GitHub
    git clone https://github.com/Neilpang/acme.sh.git
    # Do the work
    cd acme.sh || exit
    ./acme.sh --install \
    --home $ACME_HOME \
    --config-home $ACME_HOME/data \
    --cert-home  $ACME_HOME/certs \
    --accountemail  "${ADMIN_EMAIL}" \
    --accountkey  $ACME_HOME/account.key \
    --accountconf $ACME_HOME/account.conf \
    --useragent  "Acme client"
    # Issue cert
    # Use for debugging: --force --test --debug
    /etc/acme/acme.sh --issue -d ${NGINX_DOMAIN_NAME} -w /etc/nginx/html  --server letsencrypt && echo "Successfully issued Let's Encrypt SSL certificates for Invidious" || echo "Error issuing Let's Encrypt SSL certificates!"
    # Install cert
    ${SUDO} mkdir -p /etc/nginx/certs/${NGINX_DOMAIN_NAME}
    /etc/acme/acme.sh --install-cert -d ${NGINX_DOMAIN_NAME} \
    --cert-file /etc/nginx/certs/${NGINX_DOMAIN_NAME}/${NGINX_DOMAIN_NAME}.cert \
    --key-file /etc/nginx/certs/${NGINX_DOMAIN_NAME}/${NGINX_DOMAIN_NAME}.key \
    --fullchain-file /etc/nginx/certs/${NGINX_DOMAIN_NAME}/${NGINX_DOMAIN_NAME}.fullchain \
    # --reloadcmd "$SYSTEM_CMD reload nginx"
    nginx -t && ${SUDO} $SYSTEM_CMD restart nginx || echo "Error restarting nginx!"
    if [ $? -eq 0 ]; then
      ${SUDO} sed -i "s/# listen/listen/g" $NGINX_VHOST_DIR/$NGINX_VHOST
      ${SUDO} sed -i "s/# ssl_certificate/ssl_certificate/g" $NGINX_VHOST_DIR/$NGINX_VHOST
      # shellcheck disable=SC2154
      ${SUDO} sed -i "s/# if ($scheme/if ($scheme/g" $NGINX_VHOST_DIR/$NGINX_VHOST
      ${SUDO} sed -i "s/# 	return 301/	return 301/g" $NGINX_VHOST_DIR/$NGINX_VHOST
      ${SUDO} sed -i "s/# }/}/g" $NGINX_VHOST_DIR/$NGINX_VHOST
    if [ -f "$IN_CONFIG" ]; then
      https_only() {
        # shellcheck disable=SC2046
        echo $(sed -n 's/.*https_only *: *\([^ ]*.*\)/\1/p' "$1")
      }
      HTTPS_ONLY=$(https_only "$IN_CONFIG")
      if [[ $HTTPS_ONLY == "false" ]]; then
        while [[ $HTTPS_ONLY != "y" && $HTTPS_ONLY != "n" ]]; do
            read -p "Do you want to turn on https in invidious? [y/n]: " HTTPS_ONLY
        done
        case $HTTPS_ONLY in
          [Yy]* )
            ${SUDO} sed -i "s/https_only: false/https_only: true/g" $IN_CONFIG
            ${SUDO} sed -i "s/external_port: /external_port: 443/g" $IN_CONFIG
            ${SUDO} $SYSTEM_CMD restart invidious
            ;;
          [Nn]* )
            exit 1
            ;;
        esac
      else
        echo "https_only is already set to 443 in Invidious config!"
      fi
    fi
      echo "done!"
      sleep 3
      indexit
    else
      echo "something went wrong!"
    fi
    ;;
    [Nn]* )
      sleep 3
      indexit
      ;;
    * ) echo "Enter Y, N or Q, please." ;;
    esac
    else
      echo -e "${RED}${ERROR} Nginx vhost is not installed. Choose option 2 first.${NC}"
      sleep 3
      indexit
    fi
  else
    echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
    indexit
  fi
}

NGINX_AUTOINSTALL_URL=https://github.com/angristan/nginx-autoinstall/raw/master/nginx-autoinstall.sh

nginx-autoinstall() {
  shopt -s nocasematch
if [[ $DISTRO_GROUP == "Debian" ]]; then
    if [[ $(command -v 'curl') ]]; then
      # shellcheck disable=SC1090
      source <(curl -sSLf $NGINX_AUTOINSTALL_URL)
    elif [[ $(command -v 'wget') ]]; then
      # shellcheck disable=SC1090
      . <(wget -qO - $NGINX_AUTOINSTALL_URL)
    else
      echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
      exit 0
    fi
  else
    echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
    exit 1;
  fi
}

install_nginx_vhost() {
  NGINX_VHOST_DIR=/etc/nginx/sites-available
  get_domain() {
    echo "$(sed -n 's/.*domain *: *\([^ ]*.*\)/\1/p' "$1")"
  }
  get_host() {
    echo "$(sed -n 's/.*host *: *\([^ ]*.*\)/\1/p' "$1")"
  }
  # get_port() {
  #   echo $(sed -n 's/.*port *: *\([^ ]*.*\)/\2/p' "$1")
  # }
  NGINX_DOMAIN_NAME=$(get_domain "$IN_CONFIG")
  NGINX_HOST=$(get_host "$IN_CONFIG")
  #NGINX_PORT=$(get_port "$IN_CONFIG")

  NGINX_VHOST=$NGINX_DOMAIN_NAME.conf

if [[ -d "${NGINX_VHOST_DIR}" ]]; then
  echo ""
  read -p "Do you want to install a nginx vhost file for Invidious? [y/n/q]?" ANSWER
  echo ""
  echo "Your Invidious domain name: $NGINX_DOMAIN_NAME"
  echo ""

  case $ANSWER in
    [Yy]* )
tee $NGINX_VHOST_DIR/default.conf <<'EOF' >/dev/null
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _; # This is just an invalid value which will never trigger on a real hostname.
  #access_log logs/default.access.log main;

  server_name_in_redirect off;

  root  /etc/nginx/html;
}
EOF

tee $NGINX_VHOST_DIR/$NGINX_VHOST <<'EOF' >/dev/null
server {
  	listen 80;
  	listen [::]:80;

    server_name invidious.domain.tld;

  	access_log off;
  	error_log /var/log/nginx/error.log crit;

    location ^~ /.well-known/acme-challenge {
      root /etc/nginx/html;
    }
    # Redirect HTTP to HTTPS
  	# if ($scheme = http) {
  	# 	return 301 https://$server_name$request_uri;
  	# }

    # listen 443 ssl http2;
  	# listen [::]:443 ssl http2;

    # ssl_certificate /etc/nginx/certs/invidious.domain.tld/invidious.domain.tld.cert;
  	# ssl_certificate_key /etc/nginx/certs/invidious.domain.tld/invidious.domain.tld.key;

  	location / {
  		proxy_pass http://127.0.0.1:3000;
  		proxy_set_header X-Forwarded-For $remote_addr;
  		proxy_set_header Host $host;	# so Invidious knows domain
  		proxy_http_version 1.1;		# to keep alive
  		proxy_set_header Connection "";	# to keep alive
  	}

  }
EOF
  ${SUDO} sed -i "s/127.0.0.1/${NGINX_HOST}/g" $NGINX_VHOST_DIR/$NGINX_VHOST
  ${SUDO} sed -i "s/invidious.domain.tld/${NGINX_DOMAIN_NAME}/g" $NGINX_VHOST_DIR/$NGINX_VHOST
  ${SUDO} ln -s $NGINX_VHOST_DIR/$NGINX_VHOST /etc/nginx/sites-enabled/$NGINX_VHOST
  ${SUDO} chown -R root:www-data /etc/nginx/html
  nginx -t && $SYSTEM_CMD reload nginx && echo "Successfully installed nginx vhost $NGINX_VHOST_DIR/$NGINX_VHOST" || echo "Error installing nginx vhost!"
  sleep 3
  indexit
  ;;
  [Nn]* )
    read_sleep 3
    indexit
    ;;
  * ) echo "Enter Y, N or Q, please." ;;
  esac
  else
    echo -e "${RED}${ERROR} Nginx is not installed${NC}"
    read_sleep 3
    indexit
  fi
}

## Update invidious_update.sh
## Source: ghacks-user.js updater for macOS and Linux
# Download method priority: curl -> wget
DOWNLOAD_METHOD=''
if [[ $(command -v 'curl') ]]; then
  DOWNLOAD_METHOD='curl'
elif [[ $(command -v 'wget') ]]; then
  # shellcheck disable=SC2034
  DOWNLOAD_METHOD='wget'
else
  echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
  exit 0
fi

# Download files
download_file() {
  declare -r URL=$1
  # shellcheck disable=SC2155
  declare -r TF=$(mktemp)
  local DLCMD=''

  #if [ $DOWNLOAD_METHOD = 'curl' ]; then
  #  DLCMD="curl -o $TF"
  #else
  DLCMD="wget -O $TF"
  #fi

  $DLCMD "${URL}" &>/dev/null && echo "$TF" || echo '' # return the temp-filename (or empty string on error)
}

# Open files
open_file() { #expects one argument: file_path

  if [ "$(uname)" == 'Darwin' ]; then
    open "$1"
  elif [ "$(expr substr "$(uname -s)" 1 5)" == "Linux" ]; then
    xdg-open "$1"
  else
    echo -e "${RED}${ERROR} Error: Sorry, opening files is not supported for your OS.${NC}"
  fi
}

# Get latest Docker compose release tag from GitHub
# get_compose_release_tag() {
#   curl --silent "https://api.github.com/repos/$1/releases/latest" |
#   grep '"tag_name":' |
#   sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p'
# }
# DOCKER_COMPOSE_VER=$(get_compose_release_tag ${COMPOSE_REPO_NAME})

get_release_info() {
  # Get latest release tag from GitHub
  get_latest_release_tag() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p'
  }
  RELEASE_TAG=$(get_latest_release_tag ${REPO_NAME})
  # Get latest release download url
  get_latest_release() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"browser_download_url":' |
    sed -n 's#.*\(https*://[^"]*\).*#\1#;p'
  }
  LATEST_RELEASE=$(get_latest_release ${REPO_NAME})
  # Get latest release notes
  get_latest_release_note() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"body":' |
    sed -n 's/.*"\([^"]*\)".*/\1/;p'
  }
  RELEASE_NOTE=$(get_latest_release_note ${REPO_NAME})
  # Get latest release title
  get_latest_release_title() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep -m 1 '"name":' |
    sed -n 's/.*"\([^"]*\)".*/\1/;p'
  }
  RELEASE_TITLE=$(get_latest_release_title ${REPO_NAME})
}

# Returns the version number of invidious_update.sh file on line 14
get_updater_version() {
  # shellcheck disable=SC2046
  echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "$1")
}

# Show service status - @FalconStats
show_status() {
# if [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
#   declare -a services=(
#     "invidious"
#     "postgresql-11"
#   )
#   else
    declare -a services=(
      "invidious"
      "postgresql"
      )
  #fi
  declare -a serviceName=(
    "Invidious"
    "PostgreSQL"
  )
  declare -a serviceStatus=()

  for service in "${services[@]}"
  do
    serviceStatus+=("$($SYSTEM_CMD is-active "$service")")
  done

  echo ""
  echo "Services running:"

  for i in "${!serviceStatus[@]}"
  do

    if [[ "${serviceStatus[$i]}" == "active" ]]; then
      line+="${GREEN}${NC}${serviceName[$i]}: ${GREEN}● ${serviceStatus[$i]}${NC} "
    else
      line+="${serviceName[$i]}: ${RED}▲ ${serviceStatus[$i]}${NC} "
    fi
  done

  echo -e "$line"
}

if ( $SYSTEM_CMD -q is-active ${SERVICE_NAME}); then
  SHOW_STATUS=$(show_status)
fi

# Show Docker Status
show_docker_status() {

  declare -a container=(
    "invidious_invidious_1"
    "invidious_postgres_1"
  )
  declare -a containerName=(
    "Invidious"
    "PostgreSQL"
  )
  declare -a status=()

  echo ""
  echo "Docker Status:"

  running_containers="$( docker ps )"
  for container_name in "${container[@]}"
  do
    #status+=($(docker ps "$container_name"))
    status+=("$( echo -n "$running_containers" | grep -oP "(?<= )$container_name$" | wc -l )")
  done

  for i in "${!status[@]}"
  do
    # shellcheck disable=SC2128
    if [[ "$status"  = "1" ]] ; then
      line+="${containerName[$i]}: ${GREEN}● running${NC} "
    else
      line+="${containerName[$i]}: ${RED}▲ stopped${NC} "
    fi
  done

  echo -e "$line"
}
if ( ! $SYSTEM_CMD -q is-active ${SERVICE_NAME}); then
  if docker ps >/dev/null 2>&1; then
    SHOW_DOCKER_STATUS=$(show_docker_status)
  fi
fi

# Run pgbackup
pgbackup() {
  if [[ ! -d "${CURRDIR}/pgbackup" ]]; then
  printf "\n-- Setting up pgbackup\n"
  git clone https://github.com/tmiland/pgbackup.git
  cd pgbackup || exit
  shopt -s nocasematch
  if [[ $DISTRO_GROUP == "RHEL" ]]; then
    pgsqlConfigPath=/var/lib/pgsql/data
  elif [[ $DISTRO_GROUP == "Debian" ]]; then
    pgsqlConfigPath=$pgsql_config_folder/main
  else
    echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
    exit 1;
  fi
  cp -rp $pgsqlConfigPath/pg_hba.conf $pgsqlConfigPath/pg_hba.conf.bak
  #sed -i "s/USERNAME=postgres/USERNAME=$USER_NAME/g" ./pg_backup.conf
  echo "# Database administrative login by Unix domain socket
local   all             postgres                                trust
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# local is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5" | ${SUDO} tee $pgsqlConfigPath/pg_hba.conf
  #${SUDO} -i -u postgres sed -i "s/local   all             postgres                                peer/local   all             postgres                                trust/g" /etc/postgresql/9.6/main/pg_hba.conf
  ${SUDO} $SYSTEM_CMD restart ${PGSQL_SERVICE}
  read_sleep 1
  chmod +x pg_backup_rotated.sh && chmod +x pg_backup.sh
  fi
  printf "\n-- Running pgbackup\n"
  cd ${CURRDIR}/pgbackup || exit
  bash ./pg_backup.sh
  cd - || exit
  printf "\n"
  echo -e "${GREEN}${DONE} Done ${REPO_DIR} ${NC}"
  read_sleep 3
  indexit
}

# BANNERS

# Documentation link
doc_link() {
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/${REPO_NAME}${NC}\n"
}

# Header
header() {
  echo -e "${GREEN}\n"
  echo ' ╔═══════════════════════════════════════════════════════════════════╗'
  echo ' ║                        '"${SCRIPT_NAME}"'                        ║'
  echo ' ║               Automatic update script for Invidious               ║'
  echo ' ║                      Maintained by @tmiland                       ║'
  echo ' ║                          version: '${VERSION}'                           ║'
  echo ' ╚═══════════════════════════════════════════════════════════════════╝'
  echo -e "${NC}"
}

# Update banner
show_update_banner() {
  clear
  header
  echo "Welcome to the ${SCRIPT_NAME} script."
  echo ""
  echo "There is a newer version of ${SCRIPT_NAME} available."
  echo ""
  echo ""
  echo -e "${GREEN}${DONE} New version:${NC} ""${RELEASE_TAG}"" - ${RELEASE_TITLE}"
  echo ""
  echo -e "${ORANGE}${ARROW} Notes:${NC}\n"
  echo -e "${BLUE}${RELEASE_NOTE}${NC}"
  echo ""
}

# Preinstall banner
show_preinstall_banner() {
  clear
  header
  echo "Thank you for using the ${SCRIPT_NAME} script."
  echo ""
  echo ""
  echo ""
  doc_link
}

# Install banner
show_install_banner() {
  #clear
  header
  echo ""
  echo ""
  echo ""
  echo "Thank you for using the ${SCRIPT_NAME} script."
  echo ""
  echo ""
  echo ""
  echo -e "${GREEN}${DONE} Invidious install done.${NC} Now visit http://${IP}:${PORT}"
  echo ""
  echo ""
  echo ""
  echo ""
  doc_link
}

# Maintenance banner
show_maintenance_banner() {
  #clear
  header
  echo ""
  echo ""
  echo ""
  echo "Thank you for using the ${SCRIPT_NAME} script."
  echo ""
  echo ""
  echo ""
  echo -e "${GREEN}${DONE} Invidious maintenance done.${NC}"
  echo ""
  echo ""
  echo ""
  echo ""
  doc_link
}

# Banner
show_banner() {
  #clear
  header
  echo "Welcome to the ${SCRIPT_NAME} script."
  echo ""
  echo "What do you want to do?"
  echo ""
  echo "  1) Install Invidious          6) Start, Stop or Restart   "
  echo "  2) Update Invidious           7) Uninstall Invidious      "
  echo "  3) Deploy with Docker         8) Set up PostgreSQL Backup "
  echo "  4) Add Swap Space             9) Install Nginx            "
  echo "  5) Run Database Maintenance  10) Exit                     "
  echo "${SHOW_STATUS} ${SHOW_DOCKER_STATUS}"
  echo ""
  doc_link
}

# Exit Script
exit_script() {
  #header
  echo -e "${GREEN}"
  echo    '      ____          _     ___                    '
  echo    '     /  _/___ _  __(_)___/ (_)___  __  _______   '
  echo    '    / // __ \ | / / / __  / / __ \/ / / / ___/   '
  echo    '  _/ // / / / |/ / / /_/ / / /_/ / /_/ (__  )    '
  echo    ' /___/_/ /_/|___/_/\__,_/_/\____/\__,_/____/     '
  echo    '    __  __          __      __              __   '
  echo    '   / / / /___  ____/ /___ _/ /____    _____/ /_  '
  echo    '  / / / / __ \/ __  / __ `/ __/ _ \  / ___/ __ \ '
  echo    ' / /_/ / /_/ / /_/ / /_/ / /_/  __/ (__  ) / / / '
  echo    ' \____/ .___/\__,_/\__,_/\__/\___(_)____/_/ /_/  '
  echo -e '     /_/                                         ' "${NC}"
  #echo -e "${NC}"
  echo -e "
   This script runs on coffee ☕

   ${GREEN}${CHECK}${NORMAL} ${BBLUE}GitHub${NORMAL} ${ARROW} ${YELLOW}https://github.com/sponsors/tmiland${NORMAL}
   ${GREEN}${CHECK}${NORMAL} ${BBLUE}Coindrop${NORMAL} ${ARROW} ${YELLOW}https://coindrop.to/tmiland${NORMAL}
  "
  doc_link
  echo -e "${ORANGE}${ARROW} Goodbye.${NC} ☺"
  echo ""
}

# Check Git repo
chk_git_repo() {
  # Check if the folder is a git repo
  if [[ -d "${REPO_DIR}/.git" ]]; then
    echo ""
    echo -e "${RED}${ERROR} Looks like Invidious is already installed!${NC}"
    echo ""
    echo -e "${ORANGE}${WARNING} If you want to reinstall, please choose option 7 to Uninstall Invidious first!${NC}"
    echo ""
    read_sleep 3
    indexit
    #exit 1
  fi
}

docker_repo_chk() {
  # Check if the folder is a git repo
  if [[ ! -d "${REPO_DIR}/.git" ]]; then
    #if ($SYSTEM_CMD -q is-active invidious) && -d "${REPO_DIR}/.git" then
    echo ""
    echo -e "${RED}${ERROR} Looks like Invidious is not installed!${NC}"
    echo ""
    read -p "Do you want to download Invidious? [y/n/q]?" ANSWER
    echo ""

    case $ANSWER in
      [Yy]* )
        echo -e "${GREEN}${ARROW} Setting up Dependencies${NC}"
        if ! ${PKGCHK} ${PRE_INSTALL_PKGS} >/dev/null 2>&1; then
          ${UPDATE}
          for i in ${PRE_INSTALL_PKGS}; do
            ${INSTALL} $i 2> /dev/null # || exit 1
          done
        fi

        mkdir -p $USER_DIR

        echo -e "${GREEN}${ARROW} Downloading Invidious from GitHub${NC}"

        cd $USER_DIR || exit 1

        git clone https://github.com/iv-org/invidious

        repoexit
        # Checkout
        GetMaster
        ;;
      [Nn]* )
        read_sleep 3
        indexit
        ;;
      * ) echo "Enter Y, N or Q, please." ;;
    esac
  fi
}

# Set permissions
set_permissions() {
  ${SUDO} chown -R $USER_NAME:$USER_NAME $USER_DIR
  ${SUDO} chmod -R 755 $USER_DIR
}

# Update config
update_config() {

  # Update config.yml with new info from user input
  BAKPATH="/home/backup/$USER_NAME/config"
  # Lets change the default password
  OLDPASS="password: kemal"
  NEWPASS="password: $PSQLPASS"
  # Lets change the default database name
  OLDDBNAME="dbname: invidious"
  NEWDBNAME="dbname: $PSQLDB"
  # Lets change the default domain
  OLDDOMAIN="domain:"
  NEWDOMAIN="domain: $DOMAIN"
  # Lets change https_only value
  OLDHTTPS="https_only: false"
  NEWHTTPS="https_only: $HTTPS_ONLY"
  # Lets change external_port
  OLDEXTERNAL="external_port:"
  NEWEXTERNAL="external_port: $EXTERNAL_PORT"
  DPATH="${IN_CONFIG}"
  BPATH="$BAKPATH"
  TFILE="/tmp/config.yml"
  [ ! -d $BPATH ] && mkdir -p $BPATH || :
  for f in $DPATH
  do # shellcheck disable=SC2166
    if [ -f $f -a -r $f ]; then
      /bin/cp -f $f $BPATH
      echo -e "${GREEN}${ARROW} Updating config.yml with new info...${NC}"
      # Add external_port: to config on line 13
      sed -i "11i\external_port:" "$f" > $TFILE
      sed -i "12i\check_tables: true" "$f" > $TFILE
      sed -i "13i\port: $PORT" "$f" > $TFILE
      sed -i "14i\host_binding: $IP" "$f" > $TFILE
      sed -i "15i\admins: \n- $ADMINS" "$f" > $TFILE
      sed -i "17i\captcha_key: $CAPTCHA_KEY" "$f" > $TFILE
      sed -i "18i\captcha_api_url: https://api.anti-captcha.com" "$f" > $TFILE
      sed "s/$OLDPASS/$NEWPASS/g; s/$OLDDBNAME/$NEWDBNAME/g; s/$OLDDOMAIN/$NEWDOMAIN/g; s/$OLDHTTPS/$NEWHTTPS/g; s/$OLDEXTERNAL/$NEWEXTERNAL/g;" "$f" > $TFILE &&
      mv $TFILE "$f"
    else
      echo -e "${RED}${ERROR} Error: Cannot read $f"
    fi
  done

  if [[ -e $TFILE ]]; then
    /bin/rm $TFILE
  else
    echo -e "${GREEN}${DONE} Done.${NC}"
  fi
  # Done updating config.yml with new info!
  # Source: https://www.cyberciti.biz/faq/unix-linux-replace-string-words-in-many-files/
}

# Systemd install
systemd_install() {
  # Setup Systemd Service
  shopt -s nocasematch
  if [[ $DISTRO_GROUP == "RHEL" ]]; then
    cp ${REPO_DIR}/${SERVICE_NAME} /etc/systemd/system/${SERVICE_NAME}
  else
    cp ${REPO_DIR}/${SERVICE_NAME} /lib/systemd/system/${SERVICE_NAME}
  fi
  #${SUDO} sed -i "s/invidious -o invidious.log/invidious -b ${ip} -p ${port} -o invidious.log/g" /lib/systemd/system/${SERVICE_NAME}
  # Enable invidious start at boot
  ${SUDO} $SYSTEM_CMD enable ${SERVICE_NAME}
  # Reload Systemd
  ${SUDO} $SYSTEM_CMD daemon-reload
  # Restart Invidious
  ${SUDO} $SYSTEM_CMD start ${SERVICE_NAME}
  if ( $SYSTEM_CMD -q is-active ${SERVICE_NAME})
  then
    echo -e "${GREEN}${DONE} Invidious service has been successfully installed!${NC}"
    ${SUDO} $SYSTEM_CMD status ${SERVICE_NAME} --no-pager
    read_sleep 5
  else
    echo -e "${RED}${ERROR} Invidious service installation failed...${NC}"
    ${SUDO} journalctl -u ${SERVICE_NAME}
    read_sleep 5
  fi
}

logrotate_install() {
  if [ -d /etc/logrotate.d ]; then
    echo "Adding logrotate configuration..."
    echo "/home/invidious/invidious/invidious.log {
    rotate 4
    weekly
    notifempty
    missingok
    compress
    minsize 1048576
}" | ${SUDO} tee /etc/logrotate.d/invidious.logrotate
    chmod 0644 /etc/logrotate.d/invidious.logrotate
    echo " (done)"
  fi
}

# Get Crystal
get_crystal() {
  shopt -s nocasematch
  if [[ $DISTRO_GROUP == "Debian" ]]; then
    if [[ ! -e /etc/apt/sources.list.d/crystal.list ]]; then
      curl -fsSL https://crystal-lang.org/install.sh | ${SUDO} bash
    fi
  elif [[ $DISTRO_GROUP == "RHEL" ]]; then
    if [[ ! -e /etc/yum.repos.d/crystal.repo ]]; then
      curl -fsSL https://crystal-lang.org/install.sh | ${SUDO} bash
    fi
  elif [[ $(lsb_release -si) == "Darwin" ]]; then
    exit 1;
  elif [[ $DISTRO_GROUP == "Arch" ]]; then
    echo "Arch/Manjaro Linux... Skipping manual crystal install"
  else
    echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
    exit 1;
  fi
}

# Create new config.yml
create_config() {
if [ ! -f "$IN_CONFIG" ]; then
  echo "channel_threads: 1
feed_threads: 1
db:
  user: kemal
  password: kemal
  host: localhost
  port: 5432
  dbname: invidious
full_refresh: false
https_only: false
domain:" | ${SUDO} tee ${IN_CONFIG}
fi
}

# Rebuild Invidious
rebuild() {
  printf "\n-- Rebuilding ${REPO_DIR}\n"
  repoexit
  shards install --production
  crystal build src/invidious.cr --release -Ddisable_quic
  #sudo chown -R 1000:$USER_NAME $USER_DIR
  cd - || exit
  printf "\n"
  echo -e "${GREEN}${DONE} Done Rebuilding ${REPO_DIR} ${NC}"
  read_sleep 3
}

# Restart Invidious
restart() {
  printf "\n-- restarting Invidious\n"
  ${SUDO} $SYSTEM_CMD restart $SERVICE_NAME
  read_sleep 2
  ${SUDO} $SYSTEM_CMD status $SERVICE_NAME --no-pager
  printf "\n"
  echo -e "${GREEN}${DONE} Invidious has been restarted ${NC}"
  read_sleep 3
}

# Backup config file
backupConfig() {
  # Set config backup path
  ConfigBakPath="/home/backup/$USER_NAME/config"
  # If directory is not created
  [ ! -d $ConfigBakPath ] && mkdir -p $ConfigBakPath || :
  configBackup=${IN_CONFIG}
  backupConfigFile=$(date +%F).config.yml
  /bin/cp -f $configBackup $ConfigBakPath/$backupConfigFile
}

# Checkout Master branch to branch master (to avoid detached HEAD state)
GetMaster() {
  create_config
  backupConfig
  git checkout origin/${IN_BRANCH} -B ${IN_BRANCH}
}

# Update Master branch
UpdateMaster() {

  if [ "$(git log --pretty=%H ...refs/heads/master^ | head -n 1)" = "$(git ls-remote origin -h refs/heads/master | cut -f1)" ] ; then
      echo ""
      echo -e "${GREEN}${ARROW} Invidious is already up to date...${NC}"
      echo ""
    else
      echo ""
      echo -e "${ORANGE}${ARROW} Not up to date, Pulling Invidious from GitHub${NC}"
      echo ""
      backupConfig
    if [[ $(lsb_release -rs) == "16.04" ]]; then
      mv ${IN_CONFIG} /tmp
    fi
      # Update the apt package index and upgrade packages:
      if [[ $DISTRO_GROUP == "Arch" ]]; then
        ${SUDO} ${UPDATE}
      else
        ${SUDO} ${UPDATE} && ${SUDO} ${UPGRADE}
      fi
      currentVersion=$(git rev-list --max-count=1 --abbrev-commit HEAD)
      git pull
      for i in `git rev-list --abbrev-commit $currentVersion..HEAD` ; do file=${REPO_DIR}/config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ; done
      git stash
      git checkout origin/${IN_BRANCH} -B ${IN_BRANCH}
    if [[ $(lsb_release -rs) == "16.04" ]]; then
      mv /tmp/config.yml ${REPO_DIR}/config
    fi
    rebuild
    ${SUDO} chown -R $USER_NAME:$USER_NAME ${REPO_DIR}
    restart
  fi
}

# Update invidious_update.sh

# Default: Check for update, if available, ask user if they want to execute it
update_updater() {
  if [ $UPDATE_SCRIPT = 'no' ]; then
    return 0 # User signified not to check for updates
  fi
  echo -e "${GREEN}${ARROW} Checking for updates...${NC}"
  get_release_info
  # Get tmpfile from github
  local TMPFILE
  TMPFILE="$(download_file "$LATEST_RELEASE")"
  # Do the work
  # New function, fetch latest release from GitHub
  if [[ $(get_updater_version "${SCRIPT_DIR}/$SCRIPT_FILENAME") < "${RELEASE_TAG}" ]]; then
    #if [[ $(get_updater_version "${SCRIPT_DIR}/${SCRIPT_FILENAME}") < $(get_updater_version "${TMPFILE}") ]]; then
    #LV=$(get_updater_version "${TMPFILE}")
    if [ $UPDATE_SCRIPT = 'yes' ]; then
      show_update_banner
      echo -e "${RED}${ARROW} Do you want to update [Y/N?]${NC}"
      read -p "" -n 1 -r
      echo -e "\n\n"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "${TMPFILE}" "${SCRIPT_DIR}/${SCRIPT_FILENAME}"
        chmod u+x "${SCRIPT_DIR}/${SCRIPT_FILENAME}"
        "${SCRIPT_DIR}/${SCRIPT_FILENAME}" "$@"
        return 0 # exit 1 # Update available, user chooses to update
      fi
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        show_banner
        rm "${TMPFILE}"
        return 0 # Update available, but user chooses not to update
      fi
    fi
  else
    echo -e "${GREEN}${DONE} No update available.${NC}"
    if [[ "${TMPFILE}" ]]; then
      rm "${TMPFILE}"
    fi
    return 0 # No update available
  fi
}
# Add option to update the Invidious Repo from Cron
update_invidious_cron() {
  repoexit
  UpdateMaster
  exit
}
# Get dbname from config file (used in db maintenance and uninstallation)
get_dbname() {
  echo "$(sed -n 's/.*dbname *: *\([^ ]*.*\)/\1/p' "$1")"
}

database_maintenance() {

PSQLDB=$(get_dbname "${IN_CONFIG}")

echo ""
echo "Your Invidious database name: $PSQLDB"
echo ""

  if ( $SYSTEM_CMD -q is-active ${PGSQL_SERVICE})
  then
    echo -e "${RED}${ERROR} stopping Invidious...${NC}"
    ${SUDO} $SYSTEM_CMD stop ${SERVICE_NAME}
    read_sleep 3
    echo -e "${GREEN}${ARROW} Running Maintenance on $PSQLDB ${NC}"
    echo -e "${ORANGE}${ARROW} Deleting expired tokens${NC}"
    ${SUDO} -i -u postgres psql $PSQLDB -c "DELETE FROM nonces * WHERE expire < current_timestamp;"
    read_sleep 1
    echo -e "${ORANGE}${ARROW} Truncating videos table.${NC}"
    ${SUDO} -i -u postgres psql $PSQLDB -c "TRUNCATE TABLE videos;"
    read_sleep 1
    echo -e "${ORANGE}${ARROW} Vacuuming $PSQLDB.${NC}"
    ${SUDO} -i -u postgres vacuumdb --dbname=$PSQLDB --analyze --verbose --table 'videos'
    read_sleep 1
    echo -e "${ORANGE}${ARROW} Reindexing $PSQLDB.${NC}"
    ${SUDO} -i -u postgres reindexdb --dbname=$PSQLDB
    read_sleep 3
    echo -e "${GREEN}${DONE} Maintenance on $PSQLDB done.${NC}"
    # Restart postgresql
    echo -e "${ORANGE}${ARROW} Restarting postgresql...${NC}"
    ${SUDO} $SYSTEM_CMD restart ${PGSQL_SERVICE}
    echo -e "${GREEN}${DONE} Restarting postgresql done.${NC}"
    ${SUDO} $SYSTEM_CMD status ${PGSQL_SERVICE} --no-pager
    read_sleep 5
    # Restart Invidious
    echo -e "${ORANGE}${ARROW} Restarting Invidious...${NC}"
    ${SUDO} $SYSTEM_CMD restart ${SERVICE_NAME}
    echo -e "${GREEN}${DONE} Restarting Invidious done.${NC}"
    ${SUDO} $SYSTEM_CMD status ${SERVICE_NAME} --no-pager
    read_sleep 1
  else
    echo -e "${RED}${ERROR} Database Maintenance failed. Is PostgreSQL running?${NC}"
    # Try to restart postgresql
    echo -e "${GREEN}${ARROW} trying to start postgresql...${NC}"
    ${SUDO} $SYSTEM_CMD start ${PGSQL_SERVICE}
    echo -e "${GREEN}${DONE} Postgresql started successfully${NC}"
    ${SUDO} $SYSTEM_CMD status ${PGSQL_SERVICE} --no-pager
    read_sleep 5
    echo -e "${ORANGE}${ARROW} Restarting script. Please try again...${NC}"
    read_sleep 5
    indexit
  fi
}

database_maintenance_exit() {
  show_maintenance_banner
  read_sleep 5
  indexit
}
# Ask user to update yes/no
if [ $# != 0 ]; then
  while getopts ":udcml" opt; do
    case $opt in
      u)
        UPDATE_SCRIPT='yes'
        ;;
      d)
        UPDATE_SCRIPT='no'
        ;;
      c)
        update_invidious_cron
        ;;
      m)
        database_maintenance
        ;;
      l)
        install_log
        ;;
      \?)
        echo -e "${RED}\n ${ERROR} Error! Invalid option: -$OPTARG${NC}" >&2
        usage
        ;;
      :)
        echo -e "${RED}${ERROR} Error! Option -$OPTARG requires an argument.${NC}" >&2
        exit 1
        ;;
    esac
  done
fi

update_updater "$@"
cd "$CURRDIR" || exit

check_exit_status() {
  if [ $? -eq 0 ]
  then
    echo ""
    echo -e "${GREEN}${DONE} Success${NC}"
    echo ""
  else
    echo ""
    echo -e "${RED}${ERROR} [ERROR] Build Process Failed!${NC}"
    echo ""
    echo -e "${ORANGE} This is most likely an issue with Invidious, not this script!${NC}"
    echo ""
    echo -e "${ORANGE}${ARROW} Report issue:${NC} https://github.com/iv-org/invidious/issues"
    echo ""
    exit
  fi
}

install_invidious() {
  ## get total free memory size in megabytes(MB)
  free=$(free -mt | grep Total | awk '{print $4}')
  chk_git_repo

  show_preinstall_banner

  echo ""
  echo "Let's go through some configuration options."
  echo ""
  if [[ "$free" -le 2048  ]]; then
    echo -e "${ORANGE}Advice: Free memory: $free MB is less than recommended to build Invidious${NC}"
    # Let the user enter swap options:
    while [[ $SWAP_OPTIONS != "y" && $SWAP_OPTIONS != "n" ]]; do
      read -p "Do you want to add swap space? [y/n]: " SWAP_OPTIONS
    done

    while true; do
      case $SWAP_OPTIONS in
        [Yy]* )
          add_swap
          break
          ;;
        [Nn]* )
          break
          ;;
      esac
    done
  fi
  shift
  # Let the user enter advanced options:
  while [[ $ADVANCED_OPTIONS != "y" && $ADVANCED_OPTIONS != "n" ]]; do
    read -p "Do you want to enter advanced options? [y/n]: " ADVANCED_OPTIONS
  done

  while :;
  do
    case $ADVANCED_OPTIONS in
      [Yy]* )
      echo -e "${ORANGE}Advice: Add domain name, or blank if not using one${NC}"
        read -e -i "$DOMAIN" -p "       Enter the desired domain name: " DOMAIN
      echo -e "${ORANGE}Advice: Add local or public ip you want to bind to (Default: localhost)${NC}"
        read -e -i "$IP" -p "       Enter the desired ip address: " IP
      echo -e "${ORANGE}Advice: Add port number (Default: 3000)${NC}"
        read -e -i "$PORT" -p "       Enter the desired port number: " PORT
      echo -e "${ORANGE}Advice: Add database name (Default: Invidious)${NC}"
        read -e -i "$PSQLDB" -p "       Select database name: " PSQLDB
      echo -e "${ORANGE}Advice: Add database password (Default: kemal)${NC}"
        read -e -i "$PSQLPASS" -p "       Select database password: " PSQLPASS
      echo -e "${ORANGE}Advice: Enter Admin account user name (Leave blank to disable)${NC}"
        read -p "       Enter Admin username: " ADMINS
      echo -e "${ORANGE}Advice: Enter captcha key from anti-captcha.com (Leave blank to disable)${NC}"
        read -p "       Enter captcha key: " CAPTCHA_KEY
        ;;
      [Nn]* ) break ;;
    esac
    shift

    while [[ $HTTPS_ONLY != "y" && $HTTPS_ONLY != "n" ]]; do
      echo -e "${ORANGE}Advice: If you're going to serve Invidious via port 80, choose no, otherwise yes for 443 (HTTPS)"
      echo -e "                 HTTPS is typically used with a reverse proxy like Nginx${NC}"
        read -p "Are you going to use https only? [y/n]: " HTTPS_ONLY
    done

    case $HTTPS_ONLY in
      [Yy]* )
        HTTPS_ONLY=true
        EXTERNAL_PORT=443
        break ;;
      [Nn]* )
        HTTPS_ONLY=false
        EXTERNAL_PORT=
        break ;;
    esac
  done

  PSQLDB=$(printf '%s\n' $PSQLDB | LC_ALL=C tr '[:upper:]' '[:lower:]')

  echo -e "${GREEN}\n"
  echo -e "You entered: \n"
  echo -e " ${DONE} branch        : $IN_BRANCH"
  echo -e " ${DONE} domain        : $DOMAIN"
  echo -e " ${DONE} ip address    : $IP"
  echo -e " ${DONE} port          : $PORT"
  if [ ! -z "$EXTERNAL_PORT" ]; then
    echo -e " ${DONE} external port : $EXTERNAL_PORT"
  fi
  echo -e " ${DONE} dbname        : $PSQLDB"
  echo -e " ${DONE} dbpass        : $PSQLPASS"
  echo -e " ${DONE} https only    : $HTTPS_ONLY"
  if [ ! -z "$ADMINS" ]; then
    echo -e " ${DONE} admins        : $ADMINS"
  fi
  if [ ! -z "$CAPTCHA_KEY" ]; then
    echo -e " ${DONE} captcha key   : $CAPTCHA_KEY"
  fi
  echo -e " ${NC}"
  echo ""
  echo ""
  read -n1 -r -p "Invidious is ready to be installed, press any key to continue..."
  echo ""

  INSTALLER_URL=https://github.com/tmiland/invidious-installer/raw/main/invidious_installer.sh
  if [[ $(command -v 'curl') ]]; then
    # shellcheck source=$INSTALLER_URL
    source <(curl -sSLf $INSTALLER_URL)
  elif [[ $(command -v 'wget') ]]; then
    # shellcheck source=$INSTALLER_URL
    . <(wget -qO - $INSTALLER_URL)
  else
    echo -e "${RED} This script requires curl or wget.\nProcess aborted${NORMAL}"
    exit 0
  fi
}

update_invidious() {
  echo ""
  if [ ! -f /root/.gitconfig ]; then
    echo "Please provide your GitHub Credentials"
    echo ""
    read -p "GitHub email: " GITHUB_EMAIL
    read -p "GitHub name: " GITHUB_NAME
    git config --global user.email "$GITHUB_EMAIL"
    git config --global user.name "$GITHUB_NAME"
  fi
  repoexit
  UpdateMaster
  read_sleep 3
  indexit
}

download_docker_compose_file() {
  if [[ $(command -v 'curl') ]]; then
    curl -fsSLk https://github.com/tmiland/invidious-updater/raw/master/docker-compose.yml > ${REPO_DIR}/docker-compose.yml
  elif [[ $(command -v 'wget') ]]; then
    wget -q https://github.com/tmiland/invidious-updater/raw/master/docker-compose.yml -O ${REPO_DIR}/docker-compose.yml
  else
    echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
    exit 0
  fi
}

deploy_with_docker() {
  docker_repo_chk
  header

  echo ""
  echo "Deploy Invidious with Docker."
  echo ""
  echo "What do you want to do?"
  echo "   1) Build and start cluster"
  echo "   2) Start, Stop or Restart cluster"
  echo "   3) Rebuild cluster"
  echo "   4) Delete data and rebuild"
  echo "   5) Install Docker CE"
  echo "   6) Run database maintenance"
  echo ""

  while [[ $DOCKER_OPTION !=  "1" && $DOCKER_OPTION != "2" && $DOCKER_OPTION != "3" && $DOCKER_OPTION != "4" && $DOCKER_OPTION != "5" && $DOCKER_OPTION != "6" ]]; do
    read -p "Select an option [1-6]: " DOCKER_OPTION
  done

  case $DOCKER_OPTION in

    1) # Build and start cluster
      # chk_permissions
      while [[ $BUILD_DOCKER !=  "y" && $BUILD_DOCKER != "n" ]]; do
        read -p "   Build and start cluster? [y/n]: " -e BUILD_DOCKER
      done

      docker_repo_chk
      download_docker_compose_file
      # If Docker pkgs is installed
      if ${PKGCHK} ${DOCKER_PKGS} >/dev/null 2>&1; then

        if [[ $BUILD_DOCKER = "y" ]]; then
            # Let the user enter custom port:
            while [[ $CUSTOM_DOCKER_PORT != "y" && $CUSTOM_DOCKER_PORT != "n" ]]; do
              read -p "Do you want to use a custom port? [y/n]: " CUSTOM_DOCKER_PORT
            done
            if [[ $CUSTOM_DOCKER_PORT = "y" ]]; then
              read -p "       Enter the desired port number:" DOCKER_PORT
              ${SUDO} sed -i "s/127.0.0.1:3000:3000/127.0.0.1:$DOCKER_PORT:3000/g" ${REPO_DIR}/docker-compose.yml
              repoexit
              docker-compose up -d
              echo -e "${GREEN}${DONE} Deployment done with custom port $DOCKER_PORT.${NC}"
              read_sleep 5
              indexit
            else
              repoexit
              docker-compose up -d
              echo -e "${GREEN}${DONE} Deployment done.${NC}"
              read_sleep 5
              indexit
          fi
        fi

        if [[ $BUILD_DOCKER = "n" ]]; then
          indexit
        fi
      else
        echo -e "${RED}${ERROR} Docker is not installed, please choose option 5)${NC}"
      fi
      read_sleep 5
      indexit
      ;;
    2) # Start, Stop or Restart Invidious
      # chk_permissions
      echo ""
      echo "Do you want to start, stop or restart Docker?"
      echo "   1) Start"
      echo "   2) Stop"
      echo "   3) Restart"
      echo ""

      while [[ $DOCKER_SERVICE != "1" && $DOCKER_SERVICE != "2" && $DOCKER_SERVICE != "3" ]]; do
        read -p "Select an option [1-3]: " DOCKER_SERVICE
      done

      case $DOCKER_SERVICE in
        1)
          DOCKER_SERVICE=start
          ;;
        2)
          DOCKER_SERVICE=stop
          ;;
        3)
          DOCKER_SERVICE=restart
          ;;
      esac

      while true; do
        repoexit
        docker-compose ${DOCKER_SERVICE}
        read_sleep 5
        indexit
      done
      exit
      ;;
    3) # Rebuild cluster
      # chk_permissions
      while [[ $REBUILD_DOCKER !=  "y" && $REBUILD_DOCKER != "n" ]]; do
        read -p "       Rebuild cluster ? [y/n]: " -e REBUILD_DOCKER
      done
      docker_repo_chk
      if ${PKGCHK} ${DOCKER_PKGS} >/dev/null 2>&1; then
        if [[ $REBUILD_DOCKER = "y" ]]; then
          repoexit
          #docker-compose build
          docker-compose up -d --build
          echo -e "${GREEN}${DONE} Rebuild done.${NC}"
          read_sleep 5
          indexit
        fi

        if [[ $REBUILD_DOCKER = "n" ]]; then
          indexit
        fi
      else
        echo -e "${RED}${ERROR} Docker is not installed, please choose option 5)${NC}"
      fi
      exit
      ;;
    4) # Delete data and rebuild
      while [[ $DEL_REBUILD_DOCKER !=  "y" && $DEL_REBUILD_DOCKER != "n" ]]; do
        read -p "       Delete data and rebuild Docker? [y/n]: " -e DEL_REBUILD_DOCKER
      done
      docker_repo_chk
      if ${PKGCHK} ${DOCKER_PKGS} >/dev/null 2>&1; then
        if [[ $DEL_REBUILD_DOCKER = "y" ]]; then
          repoexit
          docker-compose down
          docker volume rm invidious_postgresdata
          read_sleep 5
          docker-compose build
          echo -e "${GREEN}${DONE} Data deleted and Rebuild done.${NC}"
          read_sleep 5
          indexit
        fi
        if [[ $DEL_REBUILD_DOCKER = "n" ]]; then
          indexit
        fi
      else
        echo -e "${RED}${ERROR} Docker is not installed, please choose option 5)${NC}"
      fi
      exit
      ;;
    5) # Install Docker CE
      DOCKER_VER=stable
      echo ""
      echo "This will install Docker CE."
      echo ""

      echo ""
      read -n1 -r -p "Docker is ready to be installed, press any key to continue..."
      echo ""
      # Update the apt package index:
      ${SUDO} ${UPDATE}
      shopt -s nocasematch
      if [[ $(lsb_release -si) == "Debian" ||
            $(lsb_release -si) == "Ubuntu" ||
            $(lsb_release -si) == "PureOS" ]]; then
        #Install packages to allow apt to use a repository over HTTPS:
        ${SUDO} ${INSTALL} \
          apt-transport-https \
          ca-certificates \
          curl \
          gnupg2 \
          software-properties-common
        # Add Docker’s official GPG key:
        curl -fsSLk https://download.docker.com/linux/debian/gpg | ${SUDO} apt-key add -
        # Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.
        ${SUDO} apt-key fingerprint 0EBFCD88

        ${SUDO} add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/debian \
          $(lsb_release -cs) \
          ${DOCKER_VER}"
        # Update the apt package index:
        ${SUDO} ${UPDATE}
        # Install the latest version of Docker CE and containerd
        ${SUDO} ${INSTALL} docker-ce docker-ce-cli containerd.io
        # Verify that Docker CE is installed correctly by running the hello-world image.
        ${SUDO} docker run hello-world
      shopt -s nocasematch
      elif [[ $(lsb_release -si) == "LinuxMint" ]]; then
        #Install packages to allow apt to use a repository over HTTPS:
        ${SUDO} ${INSTALL} \
          apt-transport-https \
          ca-certificates \
          curl \
          gnupg2 \
          software-properties-common
        # Add Docker’s official GPG key:
        curl -fsSLk https://download.docker.com/linux/ubuntu/gpg | ${SUDO} apt-key add -
        # Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.
        ${SUDO} apt-key fingerprint 0EBFCD88
        # install docker docker-compose
        ${SUDO} add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable"
        # Update the apt package index:
        ${SUDO} ${UPDATE}
        # Install the latest version of Docker CE and containerd
        ${SUDO} ${INSTALL} docker-ce docker-ce-cli containerd.io
        # Verify that Docker CE is installed correctly by running the hello-world image.
        ${SUDO} docker run hello-world
      elif [[ $(lsb_release -si) == "CentOS" ]]; then
        # Install required packages.
        ${SUDO} ${INSTALL} yum-utils \
          device-mapper-persistent-data \
          lvm2
        # Set up the repository.
        ${SUDO} yum-config-manager \
          --add-repo \
          https://download.docker.com/linux/centos/docker-ce.repo
        # Enable the repository.
        ${SUDO} yum-config-manager --enable docker-ce-${DOCKER_VER}
        # Update the apt package index:
        ${SUDO} ${UPDATE}
        # Install the latest version of Docker CE and containerd
        ${SUDO} ${INSTALL} docker-ce docker-ce-cli containerd.io
        # Start Docker.
        ${SUDO} $SYSTEM_CMD start docker
        # Verify that Docker CE is installed correctly by running the hello-world image.
        ${SUDO} docker run hello-world
      elif [[ $(lsb_release -si) == "Fedora" ]]; then
        # Install required packages.
        ${SUDO} ${INSTALL} dnf-plugins-core
        # Set up the repository.
        ${SUDO} dnf config-manager \
          --add-repo \
          https://download.docker.com/linux/fedora/docker-ce.repo
        # Enable the repository.
        ${SUDO} dnf config-manager --set-enabled docker-ce-${DOCKER_VER}
        # Update the apt package index:
        ${SUDO} ${UPDATE}
        # Install the latest version of Docker CE and containerd
        ${SUDO} ${INSTALL} docker-ce docker-ce-cli containerd.io
        # Start Docker.
        ${SUDO} $SYSTEM_CMD start docker
        # Verify that Docker CE is installed correctly by running the hello-world image.
        ${SUDO} docker run hello-world
      elif [[ $DISTRO_GROUP == "Arch" ]]; then
        ${SUDO} ${INSTALL} docker
        # Enable Docker.
        ${SUDO} $SYSTEM_CMD enable docker
        # Start Docker.
        ${SUDO} $SYSTEM_CMD start docker
      else
        echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
        exit 1;
      fi

      # We're almost done !
      echo -e "${GREEN}${DONE} Docker Installation done.${NC}"

      while [[ $DOCKER_COMPOSE !=  "y" && $DOCKER_COMPOSE != "n" ]]; do
        read -p "       Install Docker Compose ? [y/n]: " -e DOCKER_COMPOSE
      done

      if [[ "$DOCKER_COMPOSE" = 'y' ]]; then
        # download the latest version of Docker Compose:
        ${SUDO} curl -Lk "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        read_sleep 5
        # Apply executable permissions to the binary:
        ${SUDO} chmod +x /usr/local/bin/docker-compose
        # Create a symbolic link to /usr/bin
        ${SUDO} ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
      fi
      # We're done !
      echo -e "${GREEN}${DONE}  Docker Installation done.${NC}"
      ;;
    6) # Database Maintenance
      read -p "Are you sure you want to run Database Maintenance? Enter [y/n]: " ANSWER
      if [[ "$ANSWER" = 'y' ]]; then
        docker exec -u postgres -it invidious_postgres_1 bash -c "psql -U kemal invidious -c \"DELETE FROM nonces * WHERE expire < current_timestamp\" > /dev/null"
        docker exec -u postgres -it invidious_postgres_1 bash -c "psql -U kemal invidious -c \"TRUNCATE TABLE videos\" > /dev/null"
        echo ""
        echo -e "${GREEN}${DONE} Database Maintenance done.${NC}"
        read_sleep 5
        indexit
      fi
  esac
  read_sleep 5
  indexit
}

start_stop_restart_invidious() {
  # chk_permissions
  echo ""
  echo "Do you want to start, stop, restart or rebuild Invidious?"
  echo "   1) Start"
  echo "   2) Stop"
  echo "   3) Restart"
  echo "   4) Rebuild"
  echo ""

  while [[ $SERVICE_INPUT != "1" && $SERVICE_INPUT != "2" && $SERVICE_INPUT != "3" && $SERVICE_INPUT != "4" ]]; do
    read -p "Select an option [1-4]: " SERVICE_INPUT
  done

  case $SERVICE_INPUT in
    1)
      SERVICE_ACTION=start
      ;;
    2)
      SERVICE_ACTION=stop
      ;;
    3)
      SERVICE_ACTION=restart
      ;;
    4)
      echo "Rebuild Invidious"
      ;;
  esac

  while true; do
    if [[ -d $REPO_DIR ]]; then
      if [[ $SERVICE_INPUT = "1" || $SERVICE_INPUT = "2" || $SERVICE_INPUT = "3" ]]; then
        repoexit
        # Restart Invidious
        echo -e "${ORANGE}${ARROW} ${SERVICE_ACTION} Invidious...${NC}"
        ${SUDO} $SYSTEM_CMD ${SERVICE_ACTION} ${SERVICE_NAME}
        echo -e "${GREEN}${DONE} done.${NC}"
        ${SUDO} $SYSTEM_CMD status ${SERVICE_NAME} --no-pager
        read_sleep 5
        indexit
      fi
      if  [[ $SERVICE_INPUT = "4" ]]; then
        rebuild
        read_sleep 3
        indexit
      fi
      else
        echo -e "${RED}${WARNING} (( Invidious is not installed! ))${NC}"
        exit 1
    fi
  done
}

uninstall_invidious() {
# Set default uninstallation parameters
RM_PostgreSQLDB=${RM_PostgreSQLDB:-y}
RM_RE_PGSQLDB=${RM_RE_PGSQLDB:-n}
RM_PACKAGES=${RM_PACKAGES:-n}
RM_PURGE=${RM_PURGE:-n}
RM_FILES=${RM_FILES:-y}
RM_USER=${RM_USER:-n}
# Set db backup path
PGSQLDB_BAK_PATH="/home/backup/$USER_NAME"
# Get dbname from config.yml
RM_PSQLDB=$(get_dbname "${IN_CONFIG}")

read -p "Express uninstall ? [y/n]: " EXPRESS_UNINSTALL

if [[ ! $EXPRESS_UNINSTALL =  "y" ]]; then
  echo ""
  read -e -i "$RM_PostgreSQLDB" -p "       Remove database for Invidious ? [y/n]: " RM_PostgreSQLDB
  if [[ $RM_PostgreSQLDB =  "y" ]]; then
    echo -e "       ${ORANGE}${WARNING} (( A backup will be placed in ${ARROW} $PGSQLDB_BAK_PATH ))${NC}"
    echo -e "       Your Invidious database name: $RM_PSQLDB"
  fi
  if [[ $RM_PostgreSQLDB =  "y" ]]; then
    echo -e "       ${ORANGE}${WARNING} (( If yes, only data will be dropped ))${NC}"
    read -e -i "$RM_RE_PGSQLDB" -p "       Do you intend to reinstall?: " RM_RE_PGSQLDB
  fi
  read -e -i "$RM_PACKAGES" -p "       Remove Packages ? [y/n]: " RM_PACKAGES
  if [[ $RM_PACKAGES = "y" ]]; then
    read -e -i "$RM_PURGE" -p "       Purge Package configuration files ? [y/n]: " RM_PURGE
  fi
  echo -e "       ${ORANGE}${WARNING} (( This option will remove ${ARROW} ${REPO_DIR} ))${NC}"
  read -e -i "$RM_FILES" -p "       Remove files ? [y/n]: " RM_FILES
  if [[ "$RM_FILES" = "y" ]]; then
    echo -e "       ${RED}${WARNING} (( This option will remove ${ARROW} $USER_DIR ))${NC}"
    echo -e "       ${ORANGE}${WARNING} (( Not needed for reinstall ))${NC}"
    read -e -i "$RM_USER" -p "       Remove user ? [y/n]: " RM_USER
  fi
  echo ""
  echo -e "${GREEN}${ARROW} Invidious is ready to be uninstalled${NC}"
  echo ""
  read -n1 -r -p "press any key to continue or Ctrl+C to cancel..."
  echo ""
fi
  # Remove PostgreSQL database if user ANSWER is yes
  if [[ "$RM_PostgreSQLDB" = 'y' ]]; then
    # Stop and disable invidious
    ${SUDO} $SYSTEM_CMD stop ${SERVICE_NAME}
    read_sleep 1
    ${SUDO} $SYSTEM_CMD restart ${PGSQL_SERVICE}
    read_sleep 1
    # If directory is not created
    if [[ ! -d $PGSQLDB_BAK_PATH ]]; then
      echo -e "${ORANGE}${ARROW} Backup Folder Not Found, adding folder${NC}"
      ${SUDO} mkdir -p $PGSQLDB_BAK_PATH
    fi

    echo ""
    echo -e "${GREEN}${ARROW} Running database backup${NC}"
    echo ""

    ${SUDO} -i -u postgres pg_dump ${RM_PSQLDB} > ${PGSQLDB_BAK_PATH}/${RM_PSQLDB}.sql
    read_sleep 2
    ${SUDO} chown -R 1000:1000 "/home/backup"

    if [[ "$RM_RE_PGSQLDB" != 'n' ]]; then
      echo ""
      echo -e "${RED}${ARROW} Dropping Invidious PostgreSQL data${NC}"
      echo ""
      ${SUDO} -i -u postgres psql -c "DROP OWNED BY kemal CASCADE;"
      echo ""
      echo -e "${ORANGE}${DONE} Data dropped and backed up to ${ARROW} ${PGSQLDB_BAK_PATH}/${RM_PSQLDB}.sql ${NC}"
      echo ""
    fi

    if [[ "$RM_RE_PGSQLDB" != 'y' ]]; then
      echo ""
      echo -e "${RED}${ARROW} Dropping Invidious PostgreSQL database${NC}"
      echo ""
      ${SUDO} -i -u postgres psql -c "DROP DATABASE $RM_PSQLDB"
      echo ""
      echo -e "${ORANGE}${DONE} Database dropped and backed up to ${ARROW} ${PGSQLDB_BAK_PATH}/${RM_PSQLDB}.sql ${NC}"
      echo ""
      echo -e "${RED}${ARROW} Removing user kemal${NC}"
      ${SUDO} -i -u postgres psql -c "DROP ROLE IF EXISTS kemal;"
    fi
  fi

  # Reload Systemd
  ${SUDO} $SYSTEM_CMD daemon-reload
  # Remove packages installed during installation
  if [[ "$RM_PACKAGES" = 'y' ]]; then
    echo ""
    echo -e "${ORANGE}${ARROW} Removing packages installed during installation."
    echo ""
    echo -e "Note: PostgreSQL will not be removed due to unwanted complications${NC}"
    echo ""

    if ${PKGCHK} $UNINSTALL_PKGS >/dev/null 2>&1; then
      for i in $UNINSTALL_PKGS; do
        echo ""
        echo -e "${ORANGE}${ARROW} removing packages.${NC}"
        echo ""
        ${UNINSTALL} $i 2> /dev/null
      done
    fi
    echo ""
    echo -e "${GREEN}${DONE} done.${NC}"
    echo ""
  fi

  # Remove conf files
  if [[ "$RM_PURGE" = 'y' ]]; then
    # Removing invidious files and modules files
    echo ""
    echo -e "${ORANGE}${ARROW} Removing invidious files and modules files.${NC}"
    echo ""
    if [[ $DISTRO_GROUP == "Debian" ]]; then
      rm -r \
        /lib/systemd/system/${SERVICE_NAME} \
        /etc/apt/sources.list.d/crystal.list
    elif [[ $DISTRO_GROUP == "RHEL" ]]; then
      rm -r \
        /usr/lib/systemd/system/${SERVICE_NAME} \
        /etc/yum.repos.d/crystal.repo
    fi

    if ${PKGCHK} $UNINSTALL_PKGS >/dev/null 2>&1; then
      for i in $UNINSTALL_PKGS; do
        echo ""
        echo -e "${ORANGE}${ARROW} purging packages.${NC}"
        echo ""
        ${PURGE} $i 2> /dev/null
      done
    fi

    echo ""
    echo -e "${ORANGE}${ARROW} cleaning up.${NC}"
    echo ""
    ${CLEAN}
    echo ""
    echo -e "${GREEN}${DONE} done.${NC}"
    echo ""
  fi

  if [[ "$RM_FILES" = 'y' ]]; then
    # If directory is present, remove
    if [[ -d ${REPO_DIR} ]]; then
      echo -e "${ORANGE}${ARROW} Folder Found, removing folder${NC}"
      rm -r ${REPO_DIR}
    fi
  fi

  # Remove user and settings
  if [[ "$RM_USER" = 'y' ]]; then
    # Stop and disable invidious
    ${SUDO} $SYSTEM_CMD stop ${SERVICE_NAME}
    read_sleep 1
    ${SUDO} $SYSTEM_CMD restart ${PGSQL_SERVICE}
    read_sleep 1
    ${SUDO} $SYSTEM_CMD daemon-reload
    read_sleep 1
    grep $USER_NAME /etc/passwd >/dev/null 2>&1

    if [ $? -eq 0 ] ; then
      echo ""
      echo -e "${ORANGE}${ARROW} User $USER_NAME Found, removing user and files${NC}"
      echo ""
      shopt -s nocasematch
      if [[ $DISTRO_GROUP == "Debian" ]]; then
        ${SUDO} deluser --remove-home $USER_NAME
      fi
      if [[ $DISTRO_GROUP == "RHEL" ]]; then
        /usr/sbin/userdel -r $USER_NAME
      fi
    fi
  fi
  if [ -d /etc/logrotate.d ]; then
    rm /etc/logrotate.d/invidious.logrotate
  fi
  # We're done !
  echo ""
  echo -e "${GREEN}${DONE} Un-installation done.${NC}"
  echo ""
  read_sleep 3
  indexit
}

# Start Script
chk_permissions
show_banner

while [[ $OPTION != "1" &&
         $OPTION != "2" &&
         $OPTION != "3" &&
         $OPTION != "4" &&
         $OPTION != "5" &&
         $OPTION != "6" &&
         $OPTION != "7" &&
         $OPTION != "8" &&
         $OPTION != "9" &&
         $OPTION != "10" ]]; do
  read -p "Select an option [1-10]: " OPTION
done

case $OPTION in
  1) # Install Invidious
      install_invidious
    ;;
  2) # Update Invidious
      update_invidious
    ;;
  3) # Deploy with Docker
      deploy_with_docker
    ;;
  4) # Add Swap Space
      add_swap
    ;;
  5) # Database maintenance
      database_maintenance
      database_maintenance_exit
    ;;
  6) # Start, Stop or Restart Invidious
      start_stop_restart_invidious
    ;;
  7) # Uninstall Invidious
      uninstall_invidious
    ;;
  8) # Set up PostgreSQL Backup
      pgbackup
    ;;
  9) # Install Nginx
      install_nginx
    ;;
  10) # Exit
      exit_script
      exit
    ;;
esac
