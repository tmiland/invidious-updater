#!/usr/bin/env bash


## Author: Tommy Miland (@tmiland) - Copyright (c) 2020


######################################################################
####                    Invidious Update.sh                       ####
####            Automatic update script for Invidious             ####
####            Script to update or install Invidious             ####
####                   Maintained by @tmiland                     ####
######################################################################

version='1.5.2' # Must stay on line 14 for updater to fetch the numbers

#------------------------------------------------------------------------------#
#
# MIT License
#
# Copyright (c) 2020 Tommy Miland
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
time_stamp=$(date)
# Detect absolute and full path as well as filename of this script
cd "$(dirname $0)"
CURRDIR=$(pwd)
SCRIPT_FILENAME=$(basename $0)
cd - > /dev/null
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
DARKORANGE="\033[38;5;208m"
CYAN='\033[0;36m'
DARKGREY="\033[48;5;236m"
NC='\033[0m' # No Color
# Text formatting used for printing
BOLD="\033[1m"
DIM="\033[2m"
UNDERLINED="\033[4m"
INVERT="\033[7m"
HIDDEN="\033[8m"
# Script name
SCRIPT_NAME="Invidious Update.sh"
# Repo name
REPO_NAME="tmiland/Invidious-Updater"
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
domain=invidious.tube
# Default ip
ip=localhost
# Default port
port=3000
# Default dbname
psqldb=invidious
# Default dbpass
psqlpass=kemal
# Default https only
https_only=false
# Default external port
external_port=
# Docker compose repo name
COMPOSE_REPO_NAME="docker/compose"

# Distro support
ARCH_CHK=$(uname -m)
if [ ! ${ARCH_CHK} == 'x86_64' ]; then
  echo -e "${RED}${ERROR} Error: Sorry, your OS ($ARCH_CHK) is not supported.${NC}"
  exit 1;
fi

if ! lsb_release -si >/dev/null 2>&1; then
  if [[ -f /etc/debian_version ]]; then
    DISTRO=$(cat /etc/issue.net)
  elif [[ -f /etc/redhat-release ]]; then
    DISTRO=$(cat /etc/redhat-release)
  elif [[ -f /etc/os-release ]]; then
    DISTRO=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')
  fi

  case "$DISTRO" in
    Debian*)
      PKGCMD="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
      LSB=lsb-release
      ;;
    Ubuntu*)
      PKGCMD="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
      LSB=lsb-release
      ;;
    LinuxMint*)
      PKGCMD="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
      LSB=lsb-release
      ;;
    CentOS*)
      PKGCMD="yum install -y"
      LSB=redhat-lsb
      ;;
    Fedora*)
      PKGCMD="dnf install -y"
      LSB=redhat-lsb
      ;;
    Arch*)
      PKGCMD="yes | LC_ALL=en_US.UTF-8 pacman -S"
      LSB=lsb-release
      ;;
    *) echo -e "${RED}${ERROR} unknown distro: '$DISTRO'${NC}" ; exit 1 ;;
  esac

  echo ""
  echo -e "${RED}${ERROR} Looks like ${LSB} is not installed!${NC}"
  echo ""
  read -p "Do you want to download ${LSB}? [y/n]? " answer
  echo ""

  case $answer in
    [Yy]* )
      echo -e "${GREEN}${ARROW} Installing ${LSB} on ${DISTRO}...${NC}"
      su -s "$(which bash)" -c "${PKGCMD} ${LSB}" || echo -e "${RED}${ERROR} Error: could not install ${LSB}!${NC}"
      echo -e "${GREEN}${DONE} Done${NC}"
      sleep 3
      cd ${CURRDIR}
      ./${SCRIPT_FILENAME}
      ;;
    [Nn]* )
      exit 1;
      ;;
    * ) echo "Enter Y, N, please." ;;
  esac
fi

SUDO=""
UPDATE=""
INSTALL=""
UNINSTALL=""
PURGE=""
CLEAN=""
PKGCHK=""
PGSQL_SERVICE=""
if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" || $(lsb_release -si) == "LinuxMint" || $(lsb_release -si) == "PureOS" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  SUDO="sudo"
  UPDATE="apt-get -o Dpkg::Progress-Fancy="1" update -qq"
  INSTALL="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
  UNINSTALL="apt-get -o Dpkg::Progress-Fancy="1" remove -qq"
  PURGE="apt-get purge -o Dpkg::Progress-Fancy="1" -qq"
  CLEAN="apt-get clean && apt-get autoremove -qq"
  PKGCHK="dpkg -s"
  # Pre-install packages
  PRE_INSTALL_PKGS="apt-transport-https git curl sudo gnupg"
  # Install packages
  INSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-bin postgresql libsqlite3-dev"
  #Uninstall packages
  UNINSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-bin libsqlite3-dev"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql.service"
elif [[ $(lsb_release -si) == "CentOS" ]]; then
  SUDO="sudo"
  UPDATE="yum update -q"
  INSTALL="yum install -y -q"
  UNINSTALL="yum remove -y -q"
  PURGE="yum purge -y -q"
  CLEAN="yum clean all -y -q"
  PKGCHK="rpm --quiet --query"
  # Pre-install packages
  PRE_INSTALL_PKGS="epel-release git curl sudo"
  # Install packages
  INSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel"
  #Uninstall packages
  UNINSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel"
# PostgreSQL Service
  PGSQL_SERVICE="postgresql-11.service"
elif [[ $(lsb_release -si) == "Fedora" ]]; then
  SUDO="sudo"
  UPDATE="dnf update -q"
  INSTALL="dnf install -y -q"
  UNINSTALL="dnf remove -y -q"
  PURGE="dnf purge -y -q"
  CLEAN="dnf clean all -y -q"
  PKGCHK="rpm --quiet --query"
  # Pre-install packages
  PRE_INSTALL_PKGS="git curl sudo"
  # Install packages
  INSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel"
  #Uninstall packages
  UNINSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-tools sqlite-devel"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql-11.service"
elif [[ $(lsb_release -si) == "Arch" ]]; then
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
  PGSQL_SERVICE="postgresql.service"
else
  echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
  exit 1;
fi

# Make sure that the script runs with root permissions
chk_permissions() {
  if [[ "$EUID" != 0 ]]; then
    echo -e "${RED}${ERROR} This action needs root permissions.${NC} Please enter your root password...";
    cd "$CURRDIR"
    su -s "$(which bash)" -c "./$SCRIPT_FILENAME"
    cd - > /dev/null
    exit 0; 
  fi
}

add_swap_url=https://raw.githubusercontent.com/tmiland/swap-add/master/swap-add.sh

add_swap() {
  if [[ $(command -v 'curl') ]]; then
    source <(curl -sSLf $add_swap_url)
  elif [[ $(command -v 'wget') ]]; then
    . <(wget -qO - $add_swap_url)
  else
    echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
    exit 0
  fi
  sleep 3
  cd ${CURRDIR}
  ./${SCRIPT_FILENAME}
}

install_nginx(){
  echo ""
  echo "   1) Install Nginx"
  echo "   2) Install Nginx Vhost for Invidious"
  echo ""
  while [[ $NGINX != "1" && $NGINX != "2" ]]; do
    read -p "Select an option [1-2]: " NGINX
  done
  case $NGINX in
    1)
      nginx-autoinstall
      ;;
    2)
      install_nginx_vhost
      ;;
  esac
}

nginx_autoinstall_url=https://github.com/angristan/nginx-autoinstall/raw/master/nginx-autoinstall.sh

nginx-autoinstall() {
  if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" || $(lsb_release -si) == "LinuxMint" ]]; then
    if [[ $(command -v 'curl') ]]; then
      source <(curl -sSLf $nginx_autoinstall_url)
    elif [[ $(command -v 'wget') ]]; then
      . <(wget -qO - $nginx_autoinstall_url)
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
    echo $(sed -n 's/.*domain *: *\([^ ]*.*\)/\1/p' "$1")
  }
  get_host() {
    echo $(sed -n 's/.*host *: *\([^ ]*.*\)/\1/p' "$1")
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
  read -p "Do you want to install a nginx vhost file for Invidious? [y/n/q]?" answer
  echo ""
  echo "Your Invidious domain name: $NGINX_DOMAIN_NAME"
  echo ""

  case $answer in
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
  	listen 443 ssl http2;
  	listen [::]:443 ssl http2;

    server_name invidious.domain.tld;

  	access_log off;
  	error_log /var/log/nginx/error.log crit;

  	ssl_certificate /etc/letsencrypt/live/invidious.domain.tld/fullchain.pem;
  	ssl_certificate_key /etc/letsencrypt/live/invidious.domain.tld/privkey.pem;

  	location / {
  		proxy_pass http://127.0.0.1:3000/;
  		proxy_set_header X-Forwarded-For $remote_addr;
  		proxy_set_header Host $host;	# so Invidious knows domain
  		proxy_http_version 1.1;		# to keep alive
  		proxy_set_header Connection "";	# to keep alive
  	}

  	if ($https = '') { return 301 https://"$host$request_uri"; }	# if not connected to HTTPS, perma-redirect to HTTPS
  }
EOF
  ${SUDO} sed -i "s/127.0.0.1/${NGINX_HOST}/g" $NGINX_VHOST_DIR/$NGINX_VHOST
  ${SUDO} sed -i "s/invidious.domain.tld/${NGINX_DOMAIN_NAME}/g" $NGINX_VHOST_DIR/$NGINX_VHOST
  ${SUDO} ln -s $NGINX_VHOST_DIR/$NGINX_VHOST /etc/nginx/sites-enabled/$NGINX_VHOST
  nginx -t && systemctl reload nginx || echo "Successfully installed nginx vhost $NGINX_VHOST_DIR/$NGINX_VHOST"
  
  ;;
  [Nn]* )
    sleep 3
    cd ${CURRDIR}
    ./${SCRIPT_FILENAME}
    ;;
  * ) echo "Enter Y, N or Q, please." ;;
  esac
  fi
  
}

## Update invidious_update.sh
## Source: ghacks-user.js updater for macOS and Linux
# Download method priority: curl -> wget
DOWNLOAD_METHOD=''
if [[ $(command -v 'curl') ]]; then
  DOWNLOAD_METHOD='curl'
elif [[ $(command -v 'wget') ]]; then
  DOWNLOAD_METHOD='wget'
else
  echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
  exit 0
fi

# Download files
download_file() {
  declare -r url=$1
  declare -r tf=$(mktemp)
  local dlcmd=''

  #if [ $DOWNLOAD_METHOD = 'curl' ]; then
  #  dlcmd="curl -o $tf"
  #else
  dlcmd="wget -O $tf"
  #fi

  $dlcmd "${url}" &>/dev/null && echo "$tf" || echo '' # return the temp-filename (or empty string on error)
}

# Open files
open_file() { #expects one argument: file_path

  if [ "$(uname)" == 'Darwin' ]; then
    open "$1"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    xdg-open "$1"
  else
    echo -e "${RED}${ERROR} Error: Sorry, opening files is not supported for your OS.${NC}"
  fi
}

# Get latest Docker compose release tag from GitHub
get_compose_release_tag() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
  grep '"tag_name":' |
  sed -n 's/[^0-9.]*\([0-9.]*\).*/\1/p'
}
Docker_Compose_Ver=$(get_compose_release_tag ${COMPOSE_REPO_NAME})

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
  echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "$1")
}

# Show service status - @FalconStats
show_status() {
if [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
  declare -a services=(
    "invidious"
    "postgresql-11"
  )
  else
    declare -a services=(
      "invidious"
      "postgresql"
      )
  fi
  declare -a serviceName=(
    "Invidious"
    "PostgreSQL"
  )
  declare -a serviceStatus=()

  for service in "${services[@]}"
  do
    serviceStatus+=($(systemctl is-active "$service.service"))
  done

  echo ""
  echo "Services running:"

  for i in ${!serviceStatus[@]}
  do

    if [[ "${serviceStatus[$i]}" == "active" ]]; then
      line+="${GREEN}${NC}${serviceName[$i]}: ${GREEN}● ${serviceStatus[$i]}${NC} "
    else
      line+="${serviceName[$i]}: ${RED}▲ ${serviceStatus[$i]}${NC} "
    fi
  done

  echo -e "$line"
}

if ( systemctl -q is-active ${SERVICE_NAME}); then
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
    status+=($( echo -n "$running_containers" | grep -oP "(?<= )$container_name$" | wc -l ))
  done

  for i in ${!status[@]}
  do

    if [[ "$status"  = "1" ]] ; then
      line+="${containerName[$i]}: ${GREEN}● running${NC} "
    else
      line+="${containerName[$i]}: ${RED}▲ stopped${NC} "
    fi
  done

  echo -e "$line"
}
if ( ! systemctl -q is-active ${SERVICE_NAME}); then
  if docker ps >/dev/null 2>&1; then
    SHOW_DOCKER_STATUS=$(show_docker_status)
  fi
fi

# Run pgbackup
pgbackup() {
  if [[ ! -d "${CURRDIR}/pgbackup" ]]; then
  printf "\n-- Setting up pgbackup\n"
  git clone https://github.com/tmiland/pgbackup.git
  cd pgbackup
  if [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
    pgsqlConfigPath=/var/lib/pgsql/11/data
  elif [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" || $(lsb_release -si) == "LinuxMint" ]]; then
    pgsqlConfigPath=/etc/postgresql/9.6/main
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
  ${SUDO} systemctl restart ${PGSQL_SERVICE}
  sleep 1
  chmod +x pg_backup_rotated.sh && chmod +x pg_backup.sh
  fi
  printf "\n-- Running pgbackup\n"
  cd ${CURRDIR}/pgbackup
  bash ./pg_backup.sh
  cd -
  printf "\n"
  echo -e "${GREEN}${DONE} Done ${REPO_DIR} ${NC}"
  sleep 3
  cd ${CURRDIR}
  ./${SCRIPT_FILENAME}
}

# BANNERS

# Header
header() {
  echo -e "${GREEN}\n"
  echo ' ╔═══════════════════════════════════════════════════════════════════╗'
  echo ' ║                        '${SCRIPT_NAME}'                        ║'
  echo ' ║               Automatic update script for Invidious               ║'
  echo ' ║                      Maintained by @tmiland                       ║'
  echo ' ║                          version: '${version}'                           ║'
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
  echo -e "${GREEN}${DONE} New version:${NC} "${RELEASE_TAG}" - ${RELEASE_TITLE}"
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
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
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
  echo -e "${GREEN}${DONE} Invidious install done.${NC} Now visit http://${ip}:${port}"
  echo ""
  echo ""
  echo ""
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
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
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
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
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
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

   ${GREEN}${DONE}${NC} ${BBLUE}Paypal${NC} ${ARROW} ${ORANGE}https://paypal.me/milanddata${NC}
   ${GREEN}${DONE}${NC} ${BBLUE}BTC${NC}    ${ARROW} ${ORANGE}3MV69DmhzCqwUnbryeHrKDQxBaM724iJC2${NC}
   ${GREEN}${DONE}${NC} ${BBLUE}BCH${NC}    ${ARROW} ${ORANGE}qznnyvpxym7a8he2ps9m6l44s373fecfnv86h2vwq2${NC}
  "
  echo -e "Documentation for this script is available here: ${ORANGE}\n${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
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
    sleep 3
    cd ${CURRDIR}
    ./${SCRIPT_FILENAME}
    #exit 1
  fi
}

docker_repo_chk() {
  # Check if the folder is a git repo
  if [[ ! -d "${REPO_DIR}/.git" ]]; then
    #if (systemctl -q is-active invidious.service) && -d "${REPO_DIR}/.git" then
    echo ""
    echo -e "${RED}${ERROR} Looks like Invidious is not installed!${NC}"
    echo ""
    read -p "Do you want to download Invidious? [y/n/q]?" answer
    echo ""

    case $answer in
      [Yy]* )
        echo -e "${GREEN}${ARROW} Setting up Dependencies${NC}"
        if ! ${PKGCHK} $PRE_INSTALL_PKGS >/dev/null 2>&1; then
          ${UPDATE}
          for i in $PRE_INSTALL_PKGS; do
            ${INSTALL} $i 2> /dev/null # || exit 1
          done
        fi

        mkdir -p $USER_DIR

        echo -e "${GREEN}${ARROW} Downloading Invidious from GitHub${NC}"

        cd $USER_DIR || exit 1

        git clone https://github.com/iv-org/invidious

        cd ${REPO_DIR} || exit 1
        # Checkout
        GetMaster
        ;;
      [Nn]* )
        sleep 3
        cd ${CURRDIR}
        ./${SCRIPT_FILENAME}
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
  NEWPASS="password: $psqlpass"
  # Lets change the default database name
  OLDDBNAME="dbname: invidious"
  NEWDBNAME="dbname: $psqldb"
  # Lets change the default domain
  OLDDOMAIN="domain:"
  NEWDOMAIN="domain: $domain"
  # Lets change https_only value
  OLDHTTPS="https_only: false"
  NEWHTTPS="https_only: $https_only"
  # Lets change external_port
  OLDEXTERNAL="external_port:"
  NEWEXTERNAL="external_port: $external_port"
  DPATH="${IN_CONFIG}"
  BPATH="$BAKPATH"
  TFILE="/tmp/config.yml"
  [ ! -d $BPATH ] && mkdir -p $BPATH || :
  for f in $DPATH
  do
    if [ -f $f -a -r $f ]; then
      /bin/cp -f $f $BPATH
      echo -e "${GREEN}${ARROW} Updating config.yml with new info...${NC}"
      # Add external_port: to config on line 13
      sed -i "11i\external_port:" "$f" > $TFILE
      sed -i "12i\check_tables: true" "$f" > $TFILE
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
  cp ${REPO_DIR}/${SERVICE_NAME} /lib/systemd/system/${SERVICE_NAME}
  ${SUDO} sed -i "s/invidious -o invidious.log/invidious -b ${ip} -p ${port} -o invidious.log/g" /lib/systemd/system/${SERVICE_NAME}
  # Enable invidious start at boot
  ${SUDO} systemctl enable ${SERVICE_NAME}
  # Reload Systemd
  ${SUDO} systemctl daemon-reload
  # Restart Invidious
  ${SUDO} systemctl start ${SERVICE_NAME}
  if ( systemctl -q is-active ${SERVICE_NAME})
  then
    echo -e "${GREEN}${DONE} Invidious service has been successfully installed!${NC}"
    ${SUDO} systemctl status ${SERVICE_NAME} --no-pager
    sleep 5
  else
    echo -e "${RED}${ERROR} Invidious service installation failed...${NC}"
    sleep 5
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
  if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" || $(lsb_release -si) == "LinuxMint" ]]; then
    if [[ ! -e /etc/apt/sources.list.d/crystal.list ]]; then
      #apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
      curl -sLk "https://keybase.io/crystal/pgp_keys.asc" | ${SUDO} apt-key add -
      echo "deb https://dist.crystal-lang.org/apt crystal main" | ${SUDO} tee /etc/apt/sources.list.d/crystal.list
    fi
  elif [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
    if [[ ! -e /etc/yum.repos.d/crystal.repo ]]; then
      curl -k https://dist.crystal-lang.org/rpm/setup.sh | ${SUDO} bash
    fi
  elif [[ $(lsb_release -si) == "Darwin" ]]; then
    exit 1;
  elif [[ $(lsb_release -si) == "Arch" ]]; then
    echo "Arch Linux... Skipping manual crystal install"
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
  cd ${REPO_DIR} || exit 1
  shards update && shards install
  crystal build src/invidious.cr --release
  #sudo chown -R 1000:$USER_NAME $USER_DIR
  cd -
  printf "\n"
  echo -e "${GREEN}${DONE} Done Rebuilding ${REPO_DIR} ${NC}"
  sleep 3
}

# Restart Invidious
restart() {
  printf "\n-- restarting Invidious\n"
  ${SUDO} systemctl restart $SERVICE_NAME
  sleep 2
  ${SUDO} systemctl status $SERVICE_NAME --no-pager
  printf "\n"
  echo -e "${GREEN}${DONE} Invidious has been restarted ${NC}"
  sleep 3
}

# Backup config file
backupConfig() {
  # Set config backup path
  ConfigBakPath="/home/backup/$USER_NAME/config"
  # If directory is not created
  [ ! -d $ConfigBakPath ] && mkdir -p $ConfigBakPath || :
  configBackup=${IN_CONFIG}
  backupConfigFile=`date +%F`.config.yml
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
  
  if [ "`git log --pretty=%H ...refs/heads/master^ | head -n 1`" = "`git ls-remote origin -h refs/heads/master | cut -f1`" ] ; then
      status=0
      echo ""
      echo -e "${GREEN}${ARROW} Invidious is already up to date...${NC}"
      echo ""
    else
      status=2
      echo ""
      echo -e "${ORANGE}${ARROW} Not up to date, Pulling Invidious from GitHub${NC}"
      echo ""
      backupConfig
    if [[ $(lsb_release -rs) == "16.04" ]]; then
      mv ${IN_CONFIG} /tmp
    fi
      # currentVersion=$(git rev-list --max-count=1 --abbrev-commit HEAD)
      git pull
      # for i in `git rev-list --abbrev-commit $currentVersion..HEAD` ; do file=${REPO_DIR}/config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ; done
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
  declare -r tmpfile=$(download_file "$LATEST_RELEASE")
  # Do the work
  # New function, fetch latest release from GitHub
  if [[ $(get_updater_version "${SCRIPT_DIR}/$SCRIPT_FILENAME") < "${RELEASE_TAG}" ]]; then
    #if [[ $(get_updater_version "${SCRIPT_DIR}/${SCRIPT_FILENAME}") < $(get_updater_version "${tmpfile}") ]]; then
    #LV=$(get_updater_version "${tmpfile}")
    if [ $UPDATE_SCRIPT = 'yes' ]; then
      show_update_banner
      echo -e "${RED}${ARROW} Do you want to update [Y/N?]${NC}"
      read -p "" -n 1 -r
      echo -e "\n\n"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "${tmpfile}" "${SCRIPT_DIR}/${SCRIPT_FILENAME}"
        chmod u+x "${SCRIPT_DIR}/${SCRIPT_FILENAME}"
        "${SCRIPT_DIR}/${SCRIPT_FILENAME}" "$@" -d
        exit 1 # Update available, user chooses to update
      fi
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        show_banner
        rm "${tmpfile}"
        return 1 # Update available, but user chooses not to update
      fi
    fi
  else
    echo -e "${GREEN}${DONE} No update available.${NC}"
    if [[ "${tmpfile}" ]]; then
      rm "${tmpfile}"
    fi
    return 0 # No update available
  fi
}
# Add option to update the Invidious Repo from Cron
update_invidious_cron() {
  cd ${REPO_DIR} || exit 1
  UpdateMaster
  exit
}

# Ask user to update yes/no
if [ $# != 0 ]; then
  while getopts ":ud:c" opt; do
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

update_updater $@
cd "$CURRDIR"

# Get dbname from config file (used in db maintenance and uninstallation)
get_dbname() {
  echo $(sed -n 's/.*dbname *: *\([^ ]*.*\)/\1/p' "$1")
}

install_invidious() {
  # chk_permissions

  chk_git_repo

  show_preinstall_banner

  echo ""
  echo "Let's go through some configuration options."
  echo ""

  # Let the user enter advanced options:
  while [[ $advanced_options != "y" && $advanced_options != "n" ]]; do
    read -p "Do you want to enter advanced options? [y/n]: " advanced_options
  done

  while :;
  do
    case $advanced_options in
      [Yy]* )
      echo -e "${ORANGE}Advice: Add domain name, or blank if not using one${NC}"
        read -p "       Enter the desired domain name:" domain
      echo -e "${ORANGE}Advice: Add local or public ip you want to bind to (Default: localhost)${NC}"
        read -p "       Enter the desired ip adress:" ip
      echo -e "${ORANGE}Advice: Add port number (Default: 3000)${NC}"
        read -p "       Enter the desired port number:" port
      echo -e "${ORANGE}Advice: Add database name (Default: Invidious)${NC}"
        read -p "       Select database name:" psqldb
      echo -e "${ORANGE}Advice: Add database password (Default: kemal)${NC}"
        read -p "       Select database password:" psqlpass
        ;;
      [Nn]* ) break ;;
    esac
    shift

    while [[ $https_only != "y" && $https_only != "n" ]]; do
      echo -e "${ORANGE}Advice: If you're going to serve Invidious via port 80, choose no, otherwise yes for 443 (HTTPS)"
      echo -e "                 HTTPS is typically used with a reverse proxy like Nginx${NC}"
        read -p "Are you going to use https only? [y/n]: " https_only
    done

    case $https_only in
      [Yy]* )
        https_only=true
        external_port=443
        break ;;
      [Nn]* )
        https_only=false
        external_port=
        break ;;
    esac
  done

  echo -e "${GREEN}\n"
  echo -e "You entered: \n"
  echo -e " ${DONE} branch        : $IN_BRANCH"
  echo -e " ${DONE} domain        : $domain"
  echo -e " ${DONE} ip adress     : $ip"
  echo -e " ${DONE} port          : $port"
  echo -e " ${DONE} external port : $external_port"
  echo -e " ${DONE} dbname        : $psqldb"
  echo -e " ${DONE} dbpass        : $psqlpass"
  echo -e " ${DONE} https only    : $https_only"
  echo -e " ${NC}"
  echo ""
  echo ""
  read -n1 -r -p "Invidious is ready to be installed, press any key to continue..."
  echo ""

  # Setup Dependencies
  if ! ${PKGCHK} $PRE_INSTALL_PKGS >/dev/null 2>&1; then
    ${UPDATE}
    for i in $PRE_INSTALL_PKGS; do
      ${INSTALL} $i 2> /dev/null # || exit 1
    done
  fi

  get_crystal

  if ! ${PKGCHK} $INSTALL_PKGS >/dev/null 2>&1; then
    ${SUDO} ${UPDATE}
    for i in $INSTALL_PKGS; do
      ${SUDO} ${INSTALL} $i 2> /dev/null # || exit 1 #--allow-unauthenticated
    done
  fi
  
  # Setup Repository
  # https://stackoverflow.com/a/51894266
  grep $USER_NAME /etc/passwd >/dev/null 2>&1
  if [ ! $? -eq 0 ] ; then
    echo -e "${ORANGE}${ARROW} User $USER_NAME Not Found, adding user${NC}"
    ${SUDO} useradd -m $USER_NAME
  fi

  # If directory is not created
  if [[ ! -d $USER_DIR ]]; then
    echo -e "${ORANGE}${ARROW} Folder Not Found, adding folder${NC}"
    mkdir -p $USER_DIR
  fi

  set_permissions

  echo -e "${ORANGE}${ARROW} Downloading Invidious from GitHub${NC}"
  #sudo -i -u $USER_NAME
  cd $USER_DIR || exit 1
  sudo -i -u invidious \
    git clone https://github.com/iv-org/invidious
  cd ${REPO_DIR} || exit 1
  # Checkout
  GetMaster

  echo -e "${GREEN}${ARROW} Done${NC}"
  set_permissions

  cd -

  if [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
    if ! ${PKGCHK} ${PGSQL_SERVICE} >/dev/null 2>&1; then
      if [[ $(lsb_release -si) == "CentOS" ]]; then
        ${SUDO} ${INSTALL} "https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7.7-x86_64/pgdg-redhat-repo-latest.noarch.rpm"

      fi

      if [[ $(lsb_release -si) == "Fedora" ]]; then
        ${SUDO} ${INSTALL} "https://download.postgresql.org/pub/repos/yum/11/fedora/fedora-$(lsb_release -sr)-x86_64/pgdg-fedora-repo-latest.noarch.rpm"
      fi

      ${SUDO} ${INSTALL} postgresql11-server postgresql11
      ${SUDO} /usr/pgsql-11/bin/postgresql-11-setup initdb
      ${SUDO} chmod 775 /var/lib/pgsql/11/data/postgresql.conf
      ${SUDO} chmod 775 /var/lib/pgsql/11/data/pg_hba.conf
      sleep 1
      ${SUDO} sed -i "s/#port = 5432/port = 5432/g" /var/lib/pgsql/11/data/postgresql.conf
      cp -rp /var/lib/pgsql/11/data/pg_hba.conf /var/lib/pgsql/11/data/pg_hba.conf.bak
      echo "# Database administrative login by Unix domain socket
local   all             postgres                                peer

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
host    replication     all             ::1/128                 md5" | ${SUDO} tee /var/lib/pgsql/11/data/pg_hba.conf
      ${SUDO} chmod 600 /var/lib/pgsql/11/data/postgresql.conf
      ${SUDO} chmod 600 /var/lib/pgsql/11/data/pg_hba.conf
    fi
  fi
  if [[ $(lsb_release -si) == "Arch" ]]; then
    su - postgres -c "initdb --locale en_US.UTF-8 -D '/var/lib/postgres/data'"
  fi
  ${SUDO} systemctl enable ${PGSQL_SERVICE}
  sleep 1
  ${SUDO} systemctl restart ${PGSQL_SERVICE}
  sleep 1
  # Create users and set privileges
  echo -e "${ORANGE}${ARROW} Creating user kemal with password $psqlpass ${NC}"
  ${SUDO} -u postgres psql -c "CREATE USER kemal WITH PASSWORD '$psqlpass';"
  echo -e "${ORANGE}${ARROW} Creating database $psqldb with owner kemal${NC}"
  ${SUDO} -u postgres psql -c "CREATE DATABASE $psqldb WITH OWNER kemal;"
  echo -e "${ORANGE}${ARROW} Grant all on database $psqldb to user kemal${NC}"
  ${SUDO} -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO kemal;"
  # Import db files
  if [[ -d ${REPO_DIR}/config/sql ]]; then
    for file in ${REPO_DIR}/config/sql/*; do
      echo -e "${ORANGE}${ARROW} Running $file ${NC}"
      ${SUDO} -i -u postgres psql -d $psqldb -f $file
    done
  fi
  echo -e "${GREEN}${DONE} Finished Database section${NC}"

  update_config
  # Crystal complaining about permissions on CentOS and somewhat Debian
  # So before we build, make sure permissions are set.
  set_permissions

  cd ${REPO_DIR} || exit 1
  #sudo -i -u invidious \
    shards update && shards install
  crystal build src/invidious.cr --release
  # Not figured out why yet, so let's set permissions after as well...
  set_permissions

  systemd_install

  logrotate_install

  show_install_banner

  sleep 5
  cd ${CURRDIR}
  ./${SCRIPT_FILENAME}
  #exit
}

update_invidious() {

  echo ""
  cd ${REPO_DIR} || exit 1
  UpdateMaster
  sleep 3
  cd ${CURRDIR}
  ./${SCRIPT_FILENAME}
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
  echo ""

  while [[ $DOCKER_OPTION !=  "1" && $DOCKER_OPTION != "2" && $DOCKER_OPTION != "3" && $DOCKER_OPTION != "4" && $DOCKER_OPTION != "5" ]]; do
    read -p "Select an option [1-5]: " DOCKER_OPTION
  done

  case $DOCKER_OPTION in

    1) # Build and start cluster
      # chk_permissions
      while [[ $BUILD_DOCKER !=  "y" && $BUILD_DOCKER != "n" ]]; do
        read -p "   Build and start cluster? [y/n]: " -e BUILD_DOCKER
      done

      docker_repo_chk
      if [[ $(lsb_release -si) == "Debian"    ||
            $(lsb_release -si) == "Ubuntu"    ||
            $(lsb_release -si) == "LinuxMint" ||
            $(lsb_release -si) == "CentOS"    ||
            $(lsb_release -si) == "Fedora"
          ]]; then
          DOCKERCHK=$PKGCHK docker-ce docker-ce-cli
        elif [[ $(lsb_release -si) == "Arch" ]]; then
          DOCKERCHK=$PKGCHK docker
        else
          echo -e "${RED}${ERROR} Docker is not installed... ${NC}"
      fi

      if ${DOCKERCHK} >/dev/null 2>&1; then
        
        if [[ $BUILD_DOCKER = "y" ]]; then
            # Let the user enter custom port:
            while [[ $custom_docker_port != "y" && $custom_docker_port != "n" ]]; do
              read -p "Do you want to use a custom port? [y/n]: " custom_docker_port
            done
            if [[ $custom_docker_port = "y" ]]; then
              read -p "       Enter the desired port number:" docker_port
              ${SUDO} sed -i "s/127.0.0.1:3000:3000/127.0.0.1:$docker_port:3000/g" ${REPO_DIR}/docker-compose.yml
              cd ${REPO_DIR}
              docker-compose up -d
              echo -e "${GREEN}${DONE} Deployment done with custom port $docker_port.${NC}"
              sleep 5
              cd ${CURRDIR}
              ./${SCRIPT_FILENAME}
            else
              cd ${REPO_DIR}
              docker-compose up -d
              echo -e "${GREEN}${DONE} Deployment done.${NC}"
              sleep 5
              cd ${CURRDIR}
              ./${SCRIPT_FILENAME}
          fi
        fi

        if [[ $BUILD_DOCKER = "n" ]]; then
          cd ${CURRDIR}
          ./${SCRIPT_FILENAME}
        fi
      else
        echo -e "${RED}${ERROR} Docker is not installed, please choose option 5)${NC}"
      fi
      exit
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
        cd ${REPO_DIR}
        docker-compose ${DOCKER_SERVICE}
        sleep 5
        cd ${CURRDIR}
        ./${SCRIPT_FILENAME}
      done
      exit
      ;;
    3) # Rebuild cluster
      # chk_permissions
      while [[ $REBUILD_DOCKER !=  "y" && $REBUILD_DOCKER != "n" ]]; do
        read -p "       Rebuild cluster ? [y/n]: " -e REBUILD_DOCKER
      done

      docker_repo_chk

      if ${DOCKERCHK} >/dev/null 2>&1; then
        if [[ $REBUILD_DOCKER = "y" ]]; then
          cd ${REPO_DIR}
          #docker-compose build
          docker-compose up -d --build
          echo -e "${GREEN}${DONE} Rebuild done.${NC}"
          sleep 5
          cd ${CURRDIR}
          ./${SCRIPT_FILENAME}
        fi

        if [[ $REBUILD_DOCKER = "n" ]]; then
          cd ${CURRDIR}
          ./${SCRIPT_FILENAME}
        fi
      else
        echo -e "${RED}${ERROR} Docker is not installed, please choose option 5)${NC}"
      fi
      exit
      ;;
    4) # Delete data and rebuild
      # chk_permissions
      while [[ $DEL_REBUILD_DOCKER !=  "y" && $DEL_REBUILD_DOCKER != "n" ]]; do
        read -p "       Delete data and rebuild Docker? [y/n]: " -e DEL_REBUILD_DOCKER
      done

      docker_repo_chk

      if ${DOCKERCHK} >/dev/null 2>&1; then
        if [[ $DEL_REBUILD_DOCKER = "y" ]]; then
          cd ${REPO_DIR}
          docker-compose down
          docker volume rm invidious_postgresdata
          sleep 5
          docker-compose build
          echo -e "${GREEN}${DONE} Data deleted and Rebuild done.${NC}"
          sleep 5
          cd ${CURRDIR}
          ./${SCRIPT_FILENAME}
        fi
        if [[ $DEL_REBUILD_DOCKER = "n" ]]; then
          cd ${CURRDIR}
          ./${SCRIPT_FILENAME}
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
      if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" || $(lsb_release -si) == "LinuxMint" ]]; then
        DISTRO=$(printf '%s\n' $(lsb_release -si) | LC_ALL=C tr '[:upper:]' '[:lower:]')
        #Install packages to allow apt to use a repository over HTTPS:
        ${SUDO} ${INSTALL} \
          apt-transport-https \
          ca-certificates \
          curl \
          gnupg2 \
          software-properties-common
        # Add Docker’s official GPG key:
        curl -fsSLk https://download.docker.com/linux/${DISTRO}/gpg | ${SUDO} apt-key add -
        # Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.
        ${SUDO} apt-key fingerprint 0EBFCD88

        ${SUDO} add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/${DISTRO} \
          $(lsb_release -cs) \
          ${DOCKER_VER}"
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
        ${SUDO} systemctl start docker
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
        ${SUDO} systemctl start docker
        # Verify that Docker CE is installed correctly by running the hello-world image.
        ${SUDO} docker run hello-world
      elif [[ $(lsb_release -si) == "Arch" ]]; then
        ${SUDO} ${INSTALL} docker
        # Enable Docker.
        ${SUDO} systemctl enable docker
        # Start Docker.
        ${SUDO} systemctl start docker
      else
        echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
        exit 1;
      fi

      # We're almost done !
      echo -e "${GREEN}${DONE} Docker Installation done.${NC}"

      while [[ $Docker_Compose !=  "y" && $Docker_Compose != "n" ]]; do
        read -p "       Install Docker Compose ? [y/n]: " -e Docker_Compose
      done

      if [[ "$Docker_Compose" = 'y' ]]; then
        # download the latest version of Docker Compose:
        ${SUDO} curl -Lk "https://github.com/docker/compose/releases/download/${Docker_Compose_Ver}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sleep 5
        # Apply executable permissions to the binary:
        ${SUDO} chmod +x /usr/local/bin/docker-compose
        # Create a symbolic link to /usr/bin
        ${SUDO} ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
      fi
      # We're done !
      echo -e "${GREEN}${DONE}  Docker Installation done.${NC}"
  esac
  sleep 5
  cd ${CURRDIR}
  ./${SCRIPT_FILENAME}
  #exit 1
}

database_maintenance() {
  # chk_permissions

  read -p "Are you sure you want to run Database Maintenance? Enter [y/n]: " answer

  if [[ ! "$answer" = 'n' ]]; then
    psqldb=$(get_dbname "${IN_CONFIG}")
    # Let's allow the user to confirm that what they've typed in is correct:
    echo ""
    echo "Your Invidious database name: $psqldb"
    echo ""
    read -p "Is that correct? Enter [y/n]: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

    if [[ "$answer" = 'y' ]]; then
      if ( systemctl -q is-active ${PGSQL_SERVICE})
      then
        echo -e "${RED}${ERROR} stopping Invidious...${NC}"
        ${SUDO} systemctl stop ${SERVICE_NAME}
        sleep 3
        echo -e "${GREEN}${ARROW} Running Maintenance on $psqldb ${NC}"
        echo -e "${ORANGE}${ARROW} Deleting expired tokens${NC}"
        ${SUDO} -i -u postgres psql $psqldb -c "DELETE FROM nonces * WHERE expire < current_timestamp;"
        sleep 1
        echo -e "${ORANGE}${ARROW} Truncating videos table.${NC}"
        ${SUDO} -i -u postgres psql $psqldb -c "TRUNCATE TABLE videos;"
        sleep 1
        echo -e "${ORANGE}${ARROW} Vacuuming $psqldb.${NC}"
        ${SUDO} -i -u postgres vacuumdb --dbname=$psqldb --analyze --verbose --table 'videos'
        sleep 1
        echo -e "${ORANGE}${ARROW} Reindexing $psqldb.${NC}"
        ${SUDO} -i -u postgres reindexdb --dbname=$psqldb
        sleep 3
        echo -e "${GREEN}${DONE} Maintenance on $psqldb done.${NC}"
        # Restart postgresql
        echo -e "${ORANGE}${ARROW} Restarting postgresql...${NC}"
        ${SUDO} systemctl restart ${PGSQL_SERVICE}
        echo -e "${GREEN}${DONE} Restarting postgresql done.${NC}"
        ${SUDO} systemctl status ${PGSQL_SERVICE} --no-pager
        sleep 5
        # Restart Invidious
        echo -e "${ORANGE}${ARROW} Restarting Invidious...${NC}"
        ${SUDO} systemctl restart ${SERVICE_NAME}
        echo -e "${GREEN}${DONE} Restarting Invidious done.${NC}"
        ${SUDO} systemctl status ${SERVICE_NAME} --no-pager
        sleep 1
      else
        echo -e "${RED}${ERROR} Database Maintenance failed. Is PostgreSQL running?${NC}"
        # Try to restart postgresql
        echo -e "${GREEN}${ARROW} trying to start postgresql...${NC}"
        ${SUDO} systemctl start ${PGSQL_SERVICE}
        echo -e "${GREEN}${DONE} Postgresql started successfully${NC}"
        ${SUDO} systemctl status ${PGSQL_SERVICE} --no-pager
        sleep 5
        echo -e "${ORANGE}${ARROW} Restarting script. Please try again...${NC}"
        sleep 5
        cd ${CURRDIR}
        ./${SCRIPT_FILENAME}
      fi
    fi
  fi

  show_maintenance_banner
  sleep 5
  cd ${CURRDIR}
  ./${SCRIPT_FILENAME}
  #exit 1
}

start_stop_restart_invidious() {
  # chk_permissions
  echo ""
  echo "Do you want to start, stop or restart Invidious?"
  echo "   1) Start"
  echo "   2) Stop"
  echo "   3) Restart"
  echo ""

  while [[ $SERVICE_ACTION != "1" && $SERVICE_ACTION != "2" && $SERVICE_ACTION != "3" ]]; do
    read -p "Select an option [1-3]: " SERVICE_ACTION
  done

  case $SERVICE_ACTION in
    1)
      SERVICE_ACTION=start
      ;;
    2)
      SERVICE_ACTION=stop
      ;;
    3)
      SERVICE_ACTION=restart
      ;;
  esac

  while true; do
    cd ${REPO_DIR}
    # Restart Invidious
    echo -e "${ORANGE}${ARROW} ${SERVICE_ACTION} Invidious...${NC}"
    ${SUDO} systemctl ${SERVICE_ACTION} ${SERVICE_NAME}
    echo -e "${GREEN}${DONE} done.${NC}"
    ${SUDO} systemctl status ${SERVICE_NAME} --no-pager

    show_status_banner() {

      header

      echo ""
      echo ""
      echo ""
      echo "Thank you for using the ${SCRIPT_NAME} script."
      echo ""
      echo ""
      echo ""
      echo -e "${GREEN}${DONE} Invidious ${SERVICE_ACTION} done.${NC}"
      echo ""
      echo ""
      echo ""
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
    }

    show_status_banner
    sleep 5
    cd ${CURRDIR}
    ./${SCRIPT_FILENAME}
  done
}

uninstall_invidious() {
  # chk_permissions

  # Set db backup path
  PgDbBakPath="/home/backup/$USER_NAME"
  # Get dbname
  RM_PSQLDB=$(get_dbname "${IN_CONFIG}")
  # Let's go
  while [[ $RM_PostgreSQLDB !=  "y" && $RM_PostgreSQLDB != "n" ]]; do
    read -p "       Remove database for Invidious ? [y/n]: " -e RM_PostgreSQLDB
    if [[ ! $RM_PostgreSQLDB !=  "y" ]]; then
      echo -e "       ${ORANGE}${WARNING} (( A backup will be placed in ${ARROW} $PgDbBakPath ))${NC}"
      echo -e "       Your Invidious database name: $RM_PSQLDB"
    fi
    if [[ ! $RM_PostgreSQLDB !=  "y" ]]; then
      while [[ $RM_RE_PostgreSQLDB !=  "y" && $RM_RE_PostgreSQLDB != "n" ]]; do
        echo -e "       ${ORANGE}${WARNING} (( If yes, only data will be dropped ))${NC}"
        read -p "       Do you intend to reinstall?: " RM_RE_PostgreSQLDB
      done
    fi
  done

  while [[ $RM_PACKAGES !=  "y" && $RM_PACKAGES != "n" ]]; do
    read -p "       Remove Packages ? [y/n]: " -e RM_PACKAGES
  done

  if [[ $RM_PACKAGES = "y" ]]; then
    while [[ $RM_PURGE !=  "y" && $RM_PURGE != "n" ]]; do
      read -p "       Purge Package configuration files ? [y/n]: " -e RM_PURGE
    done
  fi

  while [[ $RM_FILES !=  "y" && $RM_FILES != "n" ]]; do
    echo -e "       ${ORANGE}${WARNING} (( This option will remove ${ARROW} ${REPO_DIR} ))${NC}"
    read -p "       Remove files ? [y/n]: " -e RM_FILES
    if [[ "$RM_FILES" = 'y' ]]; then
      while [[ $RM_USER !=  "y" && $RM_USER != "n" ]]; do
        echo -e "       ${RED}${WARNING} (( This option will remove ${ARROW} $USER_DIR ))${NC}"
        echo -e "       ${ORANGE}${WARNING} (( Not needed for reinstall ))${NC}"
        read -p "       Remove user ? [y/n]: " -e RM_USER
      done
    fi
  done

  # Let's allow the user to confirm that what they've typed in is correct:
  read -p "       Is that correct? [y/n]: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

  echo ""
  read -n1 -r -p "Invidious is ready to be uninstalled, press any key to continue..."
  echo ""

  # Remove PostgreSQL database if user answer is yes
  if [[ "$RM_PostgreSQLDB" = 'y' ]]; then
    # Stop and disable invidious
    ${SUDO} systemctl stop ${SERVICE_NAME}
    sleep 1
    ${SUDO} systemctl restart ${PGSQL_SERVICE}
    sleep 1
    # If directory is not created
    if [[ ! -d $PgDbBakPath ]]; then
      echo -e "${ORANGE}${ARROW} Backup Folder Not Found, adding folder${NC}"
      ${SUDO} mkdir -p $PgDbBakPath
    fi

    echo ""
    echo -e "${GREEN}${ARROW} Running database backup${NC}"
    echo ""

    ${SUDO} -i -u postgres pg_dump ${RM_PSQLDB} > ${PgDbBakPath}/${RM_PSQLDB}.sql
    sleep 2
    ${SUDO} chown -R 1000:1000 "/home/backup"

    if [[ "$RM_RE_PostgreSQLDB" != 'n' ]]; then
      echo ""
      echo -e "${RED}${ARROW} Dropping Invidious PostgreSQL data${NC}"
      echo ""
      ${SUDO} -i -u postgres psql -c "DROP OWNED BY kemal CASCADE;"
      echo ""
      echo -e "${ORANGE}${DONE} Data dropped and backed up to ${ARROW} ${PgDbBakPath}/${RM_PSQLDB}.sql ${NC}"
      echo ""
    fi

    if [[ "$RM_RE_PostgreSQLDB" != 'y' ]]; then
      echo ""
      echo -e "${RED}${ARROW} Dropping Invidious PostgreSQL database${NC}"
      echo ""
      ${SUDO} -i -u postgres psql -c "DROP DATABASE $RM_PSQLDB;"
      echo ""
      echo -e "${ORANGE}${DONE} Database dropped and backed up to ${ARROW} ${PgDbBakPath}/${RM_PSQLDB}.sql ${NC}"
      echo ""
      echo -e "${RED}${ARROW} Removing user kemal${NC}"
      ${SUDO} -i -u postgres psql -c "DROP ROLE IF EXISTS kemal;"
    fi
  fi

  # Reload Systemd
  ${SUDO} systemctl daemon-reload
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

    if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" || $(lsb_release -si) == "LinuxMint" ]]; then
      rm -r \
        /lib/systemd/system/${SERVICE_NAME} \
        /etc/apt/sources.list.d/crystal.list
    elif [[ $(lsb_release -si) == "CentOS" ]]; then
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
    ${SUDO} systemctl stop ${SERVICE_NAME}
    sleep 1
    ${SUDO} systemctl restart ${PGSQL_SERVICE}
    sleep 1
    ${SUDO} systemctl daemon-reload
    sleep 1
    grep $USER_NAME /etc/passwd >/dev/null 2>&1

    if [ $? -eq 0 ] ; then
      echo ""
      echo -e "${ORANGE}${ARROW} User $USER_NAME Found, removing user and files${NC}"
      echo ""
      if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" || $(lsb_release -si) == "LinuxMint" ]]; then
        ${SUDO} deluser --remove-home $USER_NAME
      fi
      if [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
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
  sleep 3
  cd ${CURRDIR}
  ./${SCRIPT_FILENAME}
  #exit
}

# Start Script
chk_permissions
show_banner

while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" && $OPTION != "5" && $OPTION != "6" && $OPTION != "7" && $OPTION != "8" && $OPTION != "9" && $OPTION != "10" ]]; do
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
