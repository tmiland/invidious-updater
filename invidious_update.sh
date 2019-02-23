#!/usr/bin/env bash


## Author: Tommy Miland (@tmiland) - Copyright (c) 2019


######################################################################
####                    Invidious Update.sh                       ####
####            Automatic update script for Invidio.us            ####
####            Script to update or install Invidious             ####
####                   Maintained by @tmiland                     ####
######################################################################

version='1.2.6' # Must stay on line 14 for updater to fetch the numbers

#------------------------------------------------------------------------------------#
#                                                                                    #
#   MIT License                                                                      #
#                                                                                    #
#   Copyright (c) 2019 Tommy Miland                                                  #
#                                                                                    #
#   Permission is hereby granted, free of charge, to any person obtaining a copy     #
#   of this software and associated documentation files (the "Software"), to deal    #
#   in the Software without restriction, including without limitation the rights     #
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell        #
#   copies of the Software, and to permit persons to whom the Software is            #
#   furnished to do so, subject to the following conditions:                         #
#                                                                                    #
#   The above copyright notice and this permission notice shall be included in all   #
#   copies or substantial portions of the Software.                                  #
#                                                                                    #
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR       #
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,         #
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      #
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER           #
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,    #
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE    #
#   SOFTWARE.                                                                        #
#                                                                                    #
#------------------------------------------------------------------------------------#

# Detect absolute and full path as well as filename of this script
cd "$(dirname $0)"
CURRDIR=$(pwd)
SCRIPT_NAME=$(basename $0)
cd - > /dev/null
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
SCRIPT_DIR=$(dirname "${sfp}")

# Colors used for printing
RED='\033[0;31m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
# Set update check
UPDATE='check'
# Set repo update check
REPO_UPDATE='check'
# Set username
USER_NAME=invidious
# Set userdir
USER_DIR="/home/invidious"
# Set repo Dir
REPO_DIR=$USER_DIR/invidious
# Master branch
IN_MASTER=master
# Release tag
IN_RELEASE=release
# Service name
SERVICE_NAME=invidious.service
# Default branch
IN_BRANCH=master
# Default domain
domain=invidio.us
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
# ImageMagick 6 version
IMAGICK_VER=6.9.10-28
# ImageMagick 7 version
IMAGICK_SEVEN_VER=7.0.8-28
# Docker Compose version
Docker_Compose_Ver=1.23.2
# Distro support
SUDO=""
UPDATE=""
INSTALL=""
UNINSTALL=""
PURGE=""
CLEAN=""
PKGCHK=""
PGSQL_SERVICE=""
if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
  # ImageMagick package name
  IMAGICKPKG=imagemagick
  SUDO="sudo"
  UPDATE="apt-get update"
  INSTALL="apt-get install -y"
  UNINSTALL="apt-get remove -y"
  PURGE="apt-get purge -y"
  CLEAN="apt-get clean && apt-get autoremove -y"
  PKGCHK="dpkg -s"
  # Pre-install packages
  PRE_INSTALL_PKGS="apt-transport-https git curl sudo"
  # Install packages
  INSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev postgresql libsqlite3-dev"
  #Uninstall packages
  UNINSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev libsqlite3-dev"
  # Build-dep packages
  BUILD_DEP_PKGS="build-essential ca-certificates wget libpcre3 libpcre3-dev autoconf unzip automake libtool tar zlib1g-dev uuid-dev lsb-release make"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql.service"
elif [[ $(lsb_release -si) == "CentOS" ]]; then
  # ImageMagick package name
  IMAGICKPKG=ImageMagick
  SUDO="sudo"
  UPDATE="yum update"
  INSTALL="yum install -y"
  UNINSTALL="yum remove -y"
  PURGE="yum purge -y"
  CLEAN="yum clean all -y"
  PKGCHK="rpm --quiet --query"
  # Pre-install packages
  PRE_INSTALL_PKGS="epel-release git curl sudo"
  # Install packages
  INSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-devel sqlite-devel"
  #Uninstall packages
  UNINSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-devel sqlite-devel"
  # Build-dep packages
  BUILD_DEP_PKGS="ImageMagick-devel"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql-11.service"
elif [[ $(lsb_release -si) == "Fedora" ]]; then
  SUDO="sudo"
  UPDATE="dnf update"
  INSTALL="dnf install -y"
  UNINSTALL="dnf remove -y"
  PURGE="dnf purge -y"
  CLEAN="dnf clean all -y"
  PKGCHK="rpm --quiet --query"
  # Pre-install packages
  PRE_INSTALL_PKGS="git curl sudo"
  # Install packages
  INSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-devel sqlite-devel"
  #Uninstall packages
  UNINSTALL_PKGS="crystal openssl-devel libxml2-devel libyaml-devel gmp-devel readline-devel librsvg2-devel sqlite-devel"
  # Build-dep packages
  BUILD_DEP_PKGS="ImageMagick-devel"
  # PostgreSQL Service
  PGSQL_SERVICE="postgresql-11.service"
  #elif [[ $(lsb_release -si) == "Darwin" ]]; then
  #SUDO="sudo"
  #UPDATE="brew update"
  #INSTALL="brew install -y"
  #UNINSTALL="brew remove -y"
  #PURGE="brew purge -y"
  #CLEAN="brew clean && brew autoremove -y"
  #PKGCHK=""
  #elif [[ $(lsb_release -si) == "Arch" ]]; then
  #SUDO="sudo"
  #UPDATE="pacman -Syu"
  #INSTALL="pacman -S"
  #UNINSTALL="pacman -R"
  #PURGE="pacman -Rs"
  #CLEAN="pacman -Sc"
  #PKGCHK="pacman -Qi"
else
  echo -e "${RED}Error: Sorry, your OS is not supported.${NC}"
  exit 1;
fi
header () {
  echo -e "${GREEN}\n"
  echo ' ╔═══════════════════════════════════════════════════════════════════╗'
  echo ' ║                        Invidious Update.sh                        ║'
  echo ' ║               Automatic update script for Invidio.us              ║'
  echo ' ║                      Maintained by @tmiland                       ║'
  echo ' ║                          version: '${version}'                           ║'
  echo ' ╚═══════════════════════════════════════════════════════════════════╝'
  echo -e "${NC}"
}
# Set permissions
set_permissions () {
  ${SUDO} chown -R $USER_NAME:$USER_NAME $USER_DIR
  ${SUDO} chmod -R 755 $USER_DIR
  #${SUDO} chmod 664 ${REPO_DIR}/config/config.yml
  #${SUDO} chmod 755 ${REPO_DIR}/invidious
}
# Get Crystal
get_crystal () {
  if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
    if [[ ! -e /etc/apt/sources.list.d/crystal.list ]]; then
      #apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
      curl -sL "https://keybase.io/crystal/pgp_keys.asc" | ${SUDO} apt-key add -
      echo "deb https://dist.crystal-lang.org/apt crystal main" | ${SUDO} tee /etc/apt/sources.list.d/crystal.list
    fi
  elif [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
    if [[ ! -e /etc/yum.repos.d/crystal.repo ]]; then
      curl https://dist.crystal-lang.org/rpm/setup.sh | ${SUDO} bash
    fi
  elif [[ $(lsb_release -si) == "Darwin" ]]; then
    exit 1;
  elif [[ $(lsb_release -si) == "Arch" ]]; then
    exit 1;
  else
    echo -e "${RED}Error: Sorry, your OS is not supported.${NC}"
    exit 1;
  fi
}
# Checkout Master branch
GetMaster () {
  master=$(git rev-list --max-count=1 --abbrev-commit HEAD)
  # Checkout master
  git checkout $master
  #git pull
  #for i in `git rev-list --abbrev-commit $master..HEAD` ; do file=${REPO_DIR}/config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ; done
}
# Checkout Release Tag
GetRelease () {
  # Get new tags from remote
  git fetch --tags
  # Get latest tag name
  latestVersion=$(git describe --tags `git rev-list --tags --max-count=1`)
  # Checkout latest release tag
  git checkout $latestVersion
  #git pull
  #for i in `git rev-list --abbrev-commit $currentVersion..HEAD` ; do file=${REPO_DIR}/config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ; done
}
# Rebuild Invidious
rebuild () {
  printf "\n-- Rebuilding ${REPO_DIR}\n"
  cd ${REPO_DIR} || exit 1
  shards
  crystal build src/invidious.cr --release
  #sudo chown -R 1000:$USER_NAME $USER_DIR
  cd -
  printf "\n"
  echo -e "${GREEN} Done Rebuilding ${REPO_DIR} ${NC}"
  sleep 3
}
# Restart Invidious
restart () {
  printf "\n-- restarting Invidious\n"
  ${SUDO} systemctl restart $SERVICE_NAME
  sleep 2
  ${SUDO} systemctl status $SERVICE_NAME --no-pager
  printf "\n"
  echo -e "${GREEN} Invidious has been restarted ${NC}"
  sleep 3
}
# Download method priority: curl -> wget
DOWNLOAD_METHOD=''
if [[ $(command -v 'curl') ]]; then
  DOWNLOAD_METHOD='curl'
elif [[ $(command -v 'wget') ]]; then
  DOWNLOAD_METHOD='wget'
else
  echo -e "${RED}This script requires curl or wget.\nProcess aborted${NC}"
  exit 0
fi
#########################
#     File Handling     #
#########################
# Download files
download_file () {
  declare -r url=$1
  declare -r tf=$(mktemp)
  local dlcmd=''

  if [ $DOWNLOAD_METHOD = 'curl' ]; then
    dlcmd="curl -o $tf"
  else
    dlcmd="wget -O $tf"
  fi

  $dlcmd "${url}" &>/dev/null && echo "$tf" || echo '' # return the temp-filename (or empty string on error)
}
# Open files
open_file () { #expects one argument: file_path

  if [ "$(uname)" == 'Darwin' ]; then
    open "$1"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    xdg-open "$1"
  else
    echo -e "${RED}Error: Sorry, opening files is not supported for your OS.${NC}"
  fi
}
########################################################
## Update invidious_update.sh                         ##
## Source: ghacks-user.js updater for macOS and Linux ##
########################################################
# Returns the version number of invidious_update.sh file on line 14
get_updater_version () {
  echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "$1")
}
# Get dbname from config file (used in db maintenance and uninstallation)
get_dbname () {
  echo $(sed -n 's/.*dbname *: *\([^ ]*.*\)/\1/p' "$1")
}

# Update banner
show_update_banner () {
  clear
  header
  echo "Welcome to the Invidious Update.sh script."
  echo ""
  echo "There is a newer version of Invidious Update.sh available."
  echo ""
  echo ""
  echo ""
  echo -e "    ${GREEN}New version:${NC} "${LV}" "
  echo ""
  echo ""
  echo ""
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
}
# Update invidious_update.sh
# Default: Check for update, if available, ask user if they want to execute it
update_updater () {

  # Get tmpfile from github
  declare -r tmpfile=$(download_file 'https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/invidious_update.sh')
  # Do the work
  if [[ $(get_updater_version "${SCRIPT_DIR}/invidious_update.sh") < $(get_updater_version "${tmpfile}") ]]; then
    LV=$(get_updater_version "${tmpfile}")
    if [ $UPDATE = 'check' ]; then
      show_update_banner
      echo -e "${RED}Do you want to update [Y/N?]${NC}"
      read -p "" -n 1 -r
      echo -e "\n\n"
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        mv "${tmpfile}" "${SCRIPT_DIR}/invidious_update.sh"
        ${SUDO} chmod u+x "${SCRIPT_DIR}/invidious_update.sh"
        "${SCRIPT_DIR}/invidious_update.sh" "$@" -d
        exit 1 # Update available, user chooses to update
      fi
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        show_banner
        return 1 # Update available, but user chooses not to update
      fi
    fi
  else
    return 0 # No update available
  fi
}

# Ask user to update yes/no
if [ $# != 0 ]; then
  while getopts ":ud" opt; do
    case $opt in
      u)
        UPDATE='yes'
        ;;
      d)
        UPDATE='no'
        ;;
      \?)
        echo -e "${RED}\n Error! Invalid option: -$OPTARG${NC}" >&2
        usage
        ;;
      :)
        echo -e "${RED}Error! Option -$OPTARG requires an argument.${NC}" >&2
        exit 1
        ;;
    esac
  done
fi

update_updater $@
cd "$CURRDIR"

show_banner () {
  #clear
  header
  echo "Welcome to the Invidious Update.sh script."
  echo ""
  echo "What do you want to do?"
  echo "   1) Install Invidious"
  echo "   2) Update Invidious"
  echo "   3) Deploy with Docker"
  echo "   4) Install Invidious service"
  echo "   5) Run Database Maintenance"
  echo "   6) Run Database Migration"
  echo "   7) Uninstall Invidious"
  echo "   8) Exit"
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
}

show_banner

while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" && $OPTION != "5" && $OPTION != "6" && $OPTION != "7" && $OPTION != "8" ]]; do
  read -p "Select an option [1-8]: " OPTION
done

case $OPTION in
  1) # Install Invidious
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "${RED}Sorry, you need to run this as root${NC}"
      exit 1
    fi

    # Check which ImageMagick version is installed
    chk_imagickpkg () {

      if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
        apt -qq list $IMAGICKPKG 2>/dev/null
      elif [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
        if [[ $(identify -version 2>/dev/null) ]]; then
          identify -version
        else
          echo -e "${ORANGE}ImageMagick is not installed.${NC}"
        fi
      else
        echo -e "${RED}Error: Sorry, your OS is not supported.${NC}"
        exit 1;
      fi
    }

    chk_git_repo () {
      # Check if the folder is a git repo
      if [[ -d "${REPO_DIR}/.git" ]]; then
        echo ""
        echo -e "${RED}Looks like Invidious is already installed!${NC}"
        echo ""
        echo -e "${ORANGE}If you want to reinstall, please choose option 7 to Uninstall Invidious first!${NC}"
        echo ""
        sleep 3
        cd ${CURRDIR}
        ./${SCRIPT_NAME}
        #exit 1
      fi
    }

    chk_git_repo

    show_preinstall_banner () {
      clear
      header
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo ""
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }

    show_preinstall_banner

    echo ""
    echo "Let's go through some configuration options."
    echo ""
    echo "Do you want to install Invidious release or master?"
    echo "   1) $IN_RELEASE"
    echo "   2) $IN_MASTER"
    echo ""
    while [[ $IN_BRANCH != "1" && $IN_BRANCH != "2" ]]; do
      read -p "Select an option [1-2]: " IN_BRANCH
    done
    case $IN_BRANCH in
      1)
        IN_BRANCH=$IN_RELEASE
        ;;
      2)
        IN_BRANCH=$IN_MASTER
        ;;
    esac

    # Let the user enter advanced options:
    while [[ $advanced_options != "y" && $advanced_options != "n" ]]; do
      read -p "Do you want to enter advanced options? [y/n]: " advanced_options
    done

    while :;
    do
      case $advanced_options in
        [Yy]* )
          read -p "       Enter the desired domain name:" domain
          read -p "       Enter the desired ip adress:" ip
          read -p "       Enter the desired port number:" port
          read -p "       Select database name:" psqldb
          read -p "       Select database password:" psqlpass
          ;;
        [Nn]* ) break ;;
      esac
      shift

      while [[ $https_only != "y" && $https_only != "n" ]]; do
        read -p "Are you going to use https only? [y/n]: " https_only
      done

      case $https_only in
        [Yy]* )
          https_only=true
          break ;;
        [Nn]* )
          https_only=false
          break ;;
      esac
    done

    echo -e "${GREEN}\n"
    echo -e "You entered: \n"
    echo -e "  branch     : $IN_BRANCH"
    echo -e "  domain     : $domain"
    echo -e "  ip adress  : $ip"
    echo -e "  port       : $port"
    echo -e "  dbname     : $psqldb"
    echo -e "  dbpass     : $psqlpass"
    echo -e "  https only : $https_only"
    echo -e "${NC}"
    echo ""
    echo "Choose your Imagemagick version :"
    echo -e "   1) System's Imagemagick\n "
    echo -e "   ($(chk_imagickpkg)) \n"
    echo    "   2) Imagemagick $IMAGICK_VER from source"
    echo    "   3) Imagemagick $IMAGICK_SEVEN_VER from source"
    echo ""
    while [[ $IMAGICK != "1" && $IMAGICK != "2" && $IMAGICK != "3" ]]; do
      read -p "Select an option [1-3]: " IMAGICK
    done

    case $IMAGICK in
      2)
        IMAGEMAGICK=y
        ;;
      3)
        IMAGEMAGICK_SEVEN=y
        ;;
    esac

    echo ""
    read -n1 -r -p "Invidious is ready to be installed, press any key to continue..."
    echo ""

    ######################
    # Setup Dependencies
    ######################
    if ! ${PKGCHK} $PRE_INSTALL_PKGS >/dev/null 2>&1; then
      ${UPDATE}
      for i in $PRE_INSTALL_PKGS; do
        ${INSTALL} $i  # || exit 1
      done
    fi

    get_crystal

    if ! ${PKGCHK} $INSTALL_PKGS >/dev/null 2>&1; then
      ${SUDO} ${UPDATE}
      for i in $INSTALL_PKGS; do
        ${SUDO} ${INSTALL} $i  # || exit 1 #--allow-unauthenticated
      done
    fi

    #################
    # ImageMagick 6
    ################
    if [[ "$IMAGEMAGICK" = 'y' ]]; then

      if ! ${PKGCHK} $BUILD_DEP_PKGS >/dev/null 2>&1; then
        for i in $BUILD_DEP_PKGS; do
          ${INSTALL} $i  # || exit 1
        done
      fi

      if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
        ${SUDO} ${PURGE} imagemagick
        ${SUDO} ${CLEAN}
      elif [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
        ${SUDO} yum groupinstall "Development Tools"
      else
        echo -e "${RED}Error: Sorry, your OS is not supported.${NC}"
        exit 1;
      fi

      cd /tmp || exit 1
      wget https://github.com/ImageMagick/ImageMagick6/archive/${IMAGICK_VER}.tar.gz
      tar -xvf ${IMAGICK_VER}.tar.gz
      cd ImageMagick6-${IMAGICK_VER}

      ./configure \
        --with-rsvg

      make
      ${SUDO} make install

      ${SUDO} ldconfig /usr/local/lib

      identify -version
      sleep 5

      rm -r /tmp/ImageMagick6-${IMAGICK_VER}
      rm -r /tmp/${IMAGICK_VER}.tar.gz

    fi
    #################
    # ImageMagick 7
    ################
    if [[ "$IMAGEMAGICK_SEVEN" = 'y' ]]; then
      if ! ${PKGCHK} $BUILD_DEP_PKGS >/dev/null 2>&1; then
        for i in $BUILD_DEP_PKGS; do
          ${INSTALL} $i
        done
      fi

      if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
        ${SUDO} ${PURGE} imagemagick
        ${SUDO} ${CLEAN}
      elif [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
        ${SUDO} yum groupinstall "Development Tools"
      else
        echo -e "${RED}Error: Sorry, your OS is not supported.${NC}"
        exit 1;
      fi

      cd /tmp || exit 1
      wget https://www.imagemagick.org/download/ImageMagick-${IMAGICK_SEVEN_VER}.tar.gz
      tar -xvf ImageMagick-${IMAGICK_SEVEN_VER}.tar.gz
      cd ImageMagick-${IMAGICK_SEVEN_VER}

      ./configure \
        --with-rsvg \

      make
      ${SUDO} make install

      ${SUDO} ldconfig /usr/local/lib

      identify -version
      sleep 5
      
      rm -r /tmp/ImageMagick-${IMAGICK_SEVEN_VER}
      rm -r /tmp/ImageMagick-${IMAGICK_SEVEN_VER}.tar.gz

    fi

    if [[ $IMAGEMAGICK_SEVEN != "y" && $IMAGEMAGICK != "y" ]]; then
      if ! ${PKGCHK} $BUILD_DEP_PKGS >/dev/null 2>&1; then
        if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
          ${SUDO} ${INSTALL} imagemagick
        elif [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
          ${SUDO} ${INSTALL} ImageMagick
        else
          echo -e "${RED}Error: Sorry, your OS is not supported.${NC}"
          exit 1;
        fi
      fi
    fi

    ######################
    # Setup Repository
    ######################
    # https://stackoverflow.com/a/51894266
    grep $USER_NAME /etc/passwd >/dev/null 2>&1
    if [ ! $? -eq 0 ] ; then
      echo -e "${ORANGE}User $USER_NAME Not Found, adding user${NC}"
      ${SUDO} useradd -m $USER_NAME
    fi

    # If directory is not created
    if [[ ! -d $USER_DIR ]]; then
      echo -e "${ORANGE}Folder Not Found, adding folder${NC}"
      mkdir -p $USER_DIR
    fi

    set_permissions

    echo -e "${GREEN}Downloading Invidious from GitHub${NC}"
    #sudo -i -u $USER_NAME
    cd $USER_DIR || exit 1
    sudo -i -u invidious \
      git clone https://github.com/omarroth/invidious
    cd ${REPO_DIR} || exit 1
    # Checkout
    if [[ ! "$IN_BRANCH" = 'master' ]]; then
      GetRelease
      git pull
    fi

    if [[ ! "$IN_BRANCH" = 'release' ]]; then
      GetMaster
      git pull
    fi

    set_permissions

    cd -

    if [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
      
      if [[ $(lsb_release -si) == "CentOS" ]]; then
        ${SUDO} ${INSTALL} https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-centos11-11-2.noarch.rpm
      fi

      if [[ $(lsb_release -si) == "Fedora" ]]; then
        ${SUDO} rpm -Uvh "https://download.postgresql.org/pub/repos/yum/11/fedora/fedora-$(lsb_release -sr)-x86_64/pgdg-fedora11-11-2.noarch.rpm"
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

    ${SUDO} systemctl enable ${PGSQL_SERVICE}
    sleep 1
    ${SUDO} systemctl restart ${PGSQL_SERVICE}
    sleep 1
    # Create users and set privileges
    echo "Creating user kemal with password $psqlpass"
    ${SUDO} -u postgres psql -c "CREATE USER kemal WITH PASSWORD '$psqlpass';"
    echo "Creating database $psqldb with owner kemal"
    ${SUDO} -u postgres psql -c "CREATE DATABASE $psqldb WITH OWNER kemal;"
    echo "Grant all on database $psqldb to user kemal"
    ${SUDO} -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO kemal;"
    # Import db files
    echo "Running channels.sql"
    ${SUDO} -i -u postgres psql -d $psqldb -f ${REPO_DIR}/config/sql/channels.sql
    echo "Running videos.sql"
    ${SUDO} -i -u postgres psql -d $psqldb -f ${REPO_DIR}/config/sql/videos.sql
    echo "Running channel_videos.sql"
    ${SUDO} -i -u postgres psql -d $psqldb -f ${REPO_DIR}/config/sql/channel_videos.sql
    echo "Running users.sql"
    ${SUDO} -i -u postgres psql -d $psqldb -f ${REPO_DIR}/config/sql/users.sql
    if [[ -e ${REPO_DIR}/config/sql/session_ids.sql ]]; then
      echo "Running session_ids.sql"
      ${SUDO} -i -u postgres psql -d $psqldb -f ${REPO_DIR}/config/sql/session_ids.sql
    fi
    echo "Running nonces.sql"
    ${SUDO} -i -u postgres psql -d $psqldb -f ${REPO_DIR}/config/sql/nonces.sql
    echo "Finished Database section"

    update_config () {
      ######################
      # Update config.yml with new info from user input
      ######################
      BAKPATH="/home/backup/$USER_NAME/config"
      # Lets change the default password
      OLDPASS="password: kemal"
      NEWPASS="password: $psqlpass"
      # Lets change the default database name
      OLDDBNAME="dbname: invidious"
      NEWDBNAME="dbname: $psqldb"
      # Lets change the default domain
      OLDDOMAIN="domain: invidio.us"
      NEWDOMAIN="domain: $domain"
      # Lets change https_only value
      OLDHTTPS="https_only: false"
      NEWHTTPS="https_only: $https_only"
      DPATH="${REPO_DIR}/config/config.yml"
      BPATH="$BAKPATH"
      TFILE="/tmp/config.yml"
      [ ! -d $BPATH ] && mkdir -p $BPATH || :
      for f in $DPATH
      do
        if [ -f $f -a -r $f ]; then
          /bin/cp -f $f $BPATH
          echo -e "${GREEN}Updating config.yml with new info...${NC}"
          sed "s/$OLDPASS/$NEWPASS/g; s/$OLDDBNAME/$NEWDBNAME/g; s/$OLDDOMAIN/$NEWDOMAIN/g; s/$OLDHTTPS/$NEWHTTPS/g" "$f" > $TFILE &&
          mv $TFILE "$f"
        else
          echo -e "${RED}Error: Cannot read $f"
        fi
      done

      if [[ -e $TFILE ]]; then
        /bin/rm $TFILE
      else
        echo -e "${GREEN}Done updating config.yml with new info!${NC}"
      fi

      ######################
      # Done updating config.yml with new info!
      # Source: https://www.cyberciti.biz/faq/unix-linux-replace-string-words-in-many-files/
      ######################
    }

    update_config

    # Crystal complaining about permissions on CentOS and somewhat Debian
    # So before we build, make sure permissions are set.
    set_permissions
    ######################
    cd ${REPO_DIR} || exit 1
    #sudo -i -u invidious \
      shards
    crystal build src/invidious.cr --release
    # Not figured out why yet, so let's set permissions after as well...
    set_permissions

    systemd_install () {
      ######################
      # Setup Systemd Service
      ######################
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
        echo -e "${GREEN}Invidious service has been successfully installed!${NC}"
        ${SUDO} systemctl status ${SERVICE_NAME} --no-pager
        sleep 5
      else
        echo -e "${RED}Invidious service installation failed...${NC}"
        sleep 5
      fi
    }

    systemd_install

    show_install_banner () {
      #clear
      header
      echo ""
      echo ""
      echo ""
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo ""
      echo ""
      echo "Invidious install done. Now visit http://${ip}:${port}"
      echo ""
      echo ""
      echo ""
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }

    show_install_banner

    sleep 5
    cd ${CURRDIR}
    ./${SCRIPT_NAME}
    #exit
    ;;
  2) # Update Invidious
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi

    echo ""
    echo "Let's go through some configuration options."
    echo ""
    echo "Do you want to checkout Invidious release or master?"
    echo "   1) $IN_RELEASE"
    echo "   2) $IN_MASTER"
    echo ""
    while [[ $IN_BRANCH != "1" && $IN_BRANCH != "2" ]]; do
      read -p "Select an option [1-2]: " IN_BRANCH
    done
    case $IN_BRANCH in
      1)
        IN_BRANCH=$IN_RELEASE
        ;;
      2)
        IN_BRANCH=$IN_MASTER
        ;;
    esac
    # Let's allow the user to confirm that what they've typed in is correct:
    echo -e "${GREEN}\n"
    echo -e "You entered: \n"
    echo -e "     branch: $IN_BRANCH"
    echo -e "${NC}"
    echo ""
    read -n1 -r -p "Invidious is ready to be updated, press any key to continue..."
    echo ""
    echo -e "${GREEN}Pulling Invidious from GitHub${NC}"
    #sudo -i -u $USER_NAME
    #cd $USER_DIR || exit 1
    cd ${REPO_DIR} || exit 1
    # Checkout
    if [[ ! "$IN_BRANCH" = 'master' ]]; then
      GetRelease
      git pull
    fi

    if [[ ! "$IN_BRANCH" = 'release' ]]; then
      GetMaster
      git pull
    fi

    rebuild

    ${SUDO} chown -R $USER_NAME:$USER_NAME ${REPO_DIR}
    #cd -

    restart

    sleep 3
    cd ${CURRDIR}
    ./${SCRIPT_NAME}
    #exit
    ;;
  3) # Deploy with Docker

    #if [[ $(lsb_release -si) == "CentOS" ]]; then
    #  echo -e "${RED}DOCKER OPTION NOT SUPPORTED FOR CENTOS YET!${NC}"
    #  exit 1;
    #fi
    # Check if not Debian/Ubuntu
    # if [[ ! $(lsb_release -si) == "Debian" && ! $(lsb_release -si) == "Ubuntu" ]]
    # then
    #   echo -e "${RED}SORRY, DOCKER OPTION NOT SUPPORTED FOR YOUR OS YET!${NC}"
    #   exit 1
    # fi
    docker_repo_chk () {
      # Check if the folder is a git repo
      if [[ ! -d "${REPO_DIR}/.git" ]]; then
        #if (systemctl -q is-active invidious.service) && -d "${REPO_DIR}/.git" then
        echo ""
        echo -e "${RED}Looks like Invidious is not installed!${NC}"
        echo ""
        read -p "Do you want to download Invidious? [y/n/q]?" answer
        echo ""

        case $answer in
          [Yy]* )
            echo -e "${GREEN}Seting up Dependencies${NC}"
            if ! ${PKGCHK} $PRE_INSTALL_PKGS >/dev/null 2>&1; then
              ${UPDATE}
              for i in $PRE_INSTALL_PKGS; do
                ${INSTALL} $i  # || exit 1
              done
            fi

            echo ""
            echo "Do you want to install Invidious release or master?"
            echo "   1) $IN_RELEASE"
            echo "   2) $IN_MASTER"
            echo ""

            while [[ $IN_BRANCH != "1" && $IN_BRANCH != "2" ]]; do
              read -p "Select an option [1-2]: " IN_BRANCH
            done

            case $IN_BRANCH in
              1)
                IN_BRANCH=$IN_RELEASE
                ;;
              2)
                IN_BRANCH=$IN_MASTER
                ;;
            esac

            mkdir -p $USER_DIR

            echo -e "${GREEN}Downloading Invidious from GitHub${NC}"

            cd $USER_DIR || exit 1

            git clone https://github.com/omarroth/invidious

            cd ${REPO_DIR} || exit 1
            # Checkout
            if [[ ! "$IN_BRANCH" = 'master' ]]; then
              GetRelease
              git pull
            fi
            if [[ ! "$IN_BRANCH" = 'release' ]]; then
              GetMaster
              git pull
            fi
            #cd -
            #./${SCRIPT_NAME}
            ;;
          [Nn]* )
            sleep 3
            cd ${CURRDIR}
            ./${SCRIPT_NAME}
            ;;
          * ) echo "Enter Y, N or Q, please." ;;
        esac
      fi
    }

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

        while [[ $BUILD_DOCKER !=  "y" && $BUILD_DOCKER != "n" ]]; do
          read -p "   Build and start cluster? [y/n]: " -e BUILD_DOCKER
        done

        docker_repo_chk

        if ${PKGCHK} docker-ce docker-ce-cli >/dev/null 2>&1; then
          if [[ $BUILD_DOCKER = "y" ]]; then
            cd ${REPO_DIR}
            docker-compose up -d
            echo -e "${GREEN}Deployment done.${NC}"
            sleep 5
            cd ${CURRDIR}
            ./${SCRIPT_NAME}
            #exit 0
          fi

          if [[ $BUILD_DOCKER = "n" ]]; then
            cd ${CURRDIR}
            ./${SCRIPT_NAME}
          fi
        else
          echo -e "${RED}Docker is not installed, please choose option 5)${NC}"
        fi
        exit
        ;;
      2) # Start, Stop or Restart Invidious

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
          ./${SCRIPT_NAME}
        done
        exit
        ;;
      3) # Rebuild cluster

        while [[ $REBUILD_DOCKER !=  "y" && $REBUILD_DOCKER != "n" ]]; do
          read -p "       Rebuild cluster ? [y/n]: " -e REBUILD_DOCKER
        done

        docker_repo_chk

        if ${PKGCHK} docker-ce docker-ce-cli >/dev/null 2>&1; then
          if [[ $REBUILD_DOCKER = "y" ]]; then
            cd ${REPO_DIR}
            docker-compose build
            echo -e "${GREEN}Rebuild done.${NC}"
            sleep 5
            cd ${CURRDIR}
            ./${SCRIPT_NAME}
          fi

          if [[ $REBUILD_DOCKER = "n" ]]; then
            cd ${CURRDIR}
            ./${SCRIPT_NAME}
          fi
        else
          echo -e "${RED}Docker is not installed, please choose option 5)${NC}"
        fi
        exit
        ;;
      4) # Delete data and rebuild

        while [[ $DEL_REBUILD_DOCKER !=  "y" && $DEL_REBUILD_DOCKER != "n" ]]; do
          read -p "       Delete data and rebuild Docker? [y/n]: " -e DEL_REBUILD_DOCKER
        done

        docker_repo_chk

        if ${PKGCHK} docker-ce docker-ce-cli >/dev/null 2>&1; then
          if [[ $DEL_REBUILD_DOCKER = "y" ]]; then
            cd ${REPO_DIR}
            docker-compose down
            docker volume rm invidious_postgresdata
            sleep 5
            docker-compose build
            echo -e "${GREEN}Data deleted and Rebuild done.${NC}"
            sleep 5
            cd ${CURRDIR}
            ./${SCRIPT_NAME}
          fi
          if [[ $DEL_REBUILD_DOCKER = "n" ]]; then
            cd ${CURRDIR}
            ./${SCRIPT_NAME}
          fi
        else
          echo -e "${RED}Docker is not installed, please choose option 5)${NC}"
        fi
        exit
        ;;
      5) # Install Docker CE

        echo ""
        echo "This will install Docker CE."
        echo ""
        echo "Do you want to install Docker stable or nightly?"
        echo "   1) Stable $DOCKER_STABLE_VER"
        echo "   2) Nightly $DOCKER_NIGHTLY_VER"
        echo "   2) Test $DOCKER_NIGHTLY_VER"
        echo ""

        while [[ $DOCKER_VER != "1" && $DOCKER_VER != "2" && $DOCKER_VER != "3" ]]; do
          read -p "Select an option [1-3]: " DOCKER_VER
        done

        case $DOCKER_VER in
          1)
            DOCKER_VER=stable
            ;;
          2)
            DOCKER_VER=nightly
            ;;
          3)
            DOCKER_VER=test
            ;;
        esac

        echo ""
        read -n1 -r -p "Docker is ready to be installed, press any key to continue..."
        echo ""
        # Update the apt package index:
        ${SUDO} ${UPDATE}
        if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
          #Install packages to allow apt to use a repository over HTTPS:
          ${SUDO} ${INSTALL} \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg2 \
            software-properties-common
          # Add Docker’s official GPG key:
          curl -fsSL https://download.docker.com/linux/debian/gpg | ${SUDO} apt-key add -
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
        else
          echo -e "${RED}Error: Sorry, your OS is not supported.${NC}"
          exit 1;
        fi

        # We're almost done !
        echo "Docker Installation done."

        while [[ $Docker_Compose !=  "y" && $Docker_Compose != "n" ]]; do
          read -p "       Install Docker Compose ? [y/n]: " -e Docker_Compose
        done

        if [[ "$Docker_Compose" = 'y' ]]; then
          # download the latest version of Docker Compose:
          ${SUDO} curl -L "https://github.com/docker/compose/releases/download/${Docker_Compose_Ver}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          sleep 5
          # Apply executable permissions to the binary:
          ${SUDO} chmod +x /usr/local/bin/docker-compose
          # Create a symbolic link to /usr/bin
          ${SUDO} ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        fi
        # We're done !
        echo "Docker Installation done."
    esac
    exit
    ;;
  4) # Install Invidious service
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    ######################
    # Setup Systemd Service
    ######################
    if ( ! systemctl -q is-active ${SERVICE_NAME})
    then
      cp ${REPO_DIR}/${SERVICE_NAME} /lib/systemd/system/${SERVICE_NAME}
      # Enable invidious start at boot
      ${SUDO} systemctl enable ${SERVICE_NAME}
      # Reload Systemd
      ${SUDO} systemctl daemon-reload
      # Restart Invidious
      ${SUDO} systemctl start ${SERVICE_NAME}
    fi

    if ( systemctl -q is-active ${SERVICE_NAME})
    then
      echo -e "${GREEN}Invidious service has been successfully installed!${NC}"
      ${SUDO} systemctl status ${SERVICE_NAME} --no-pager
      sleep 5
    else
      echo -e "${RED}Invidious service installation failed...${NC}"
      sleep 5
    fi

    show_systemd_install_banner () {
      #clear
      header
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo "Invidious systemd install done. Now visit http://localhost:3000"
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }

    show_systemd_install_banner

    sleep 3
    cd ${CURRDIR}
    ./${SCRIPT_NAME}
    #exit 1
    ;;
  5) # Database maintenance
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi

    read -p "Are you sure you want to run Database Maintenance? Enter [y/n]: " answer

    if [[ ! "$answer" = 'n' ]]; then
      psqldb=$(get_dbname "${REPO_DIR}/config/config.yml")
      # Let's allow the user to confirm that what they've typed in is correct:
      echo ""
      echo "Your Invidious database name: $psqldb"
      echo ""
      read -p "Is that correct? Enter [y/n]: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

      if [[ "$answer" = 'y' ]]; then
        if ( systemctl -q is-active ${PGSQL_SERVICE})
        then
          echo -e "${RED}stopping Invidious..."
          ${SUDO} systemctl stop ${SERVICE_NAME}
          sleep 3
          echo "Running Maintenance on $psqldb"
          echo "Deleting expired tokens"
          ${SUDO} -i -u postgres psql $psqldb -c "DELETE FROM nonces * WHERE expire < current_timestamp;"
          sleep 1
          echo "Truncating videos table."
          ${SUDO} -i -u postgres psql $psqldb -c "TRUNCATE TABLE videos;"
          sleep 1
          echo "Vacuuming $psqldb."
          ${SUDO} -i -u postgres vacuumdb --dbname=$psqldb --analyze --verbose --table 'videos'
          sleep 1
          echo "Reindexing $psqldb."
          ${SUDO} -i -u postgres reindexdb --dbname=$psqldb
          sleep 3
          echo -e "${GREEN}Maintenance on $psqldb done."
          # Restart postgresql
          echo -e "${GREEN}Restarting postgresql..."
          ${SUDO} systemctl restart ${PGSQL_SERVICE}
          echo -e "${GREEN}Restarting postgresql done."
          ${SUDO} systemctl status ${PGSQL_SERVICE} --no-pager
          sleep 5
          # Restart Invidious
          echo -e "${GREEN}Restarting Invidious..."
          ${SUDO} systemctl restart ${SERVICE_NAME}
          echo -e "${GREEN}Restarting Invidious done."
          ${SUDO} systemctl status ${SERVICE_NAME} --no-pager
          sleep 1
        else
          echo -e "${RED}Database Maintenance failed. Is PostgreSQL running?"
          # Try to restart postgresql
          echo -e "${GREEN}trying to start postgresql..."
          ${SUDO} systemctl start ${PGSQL_SERVICE}
          echo -e "${GREEN}Postgresql started successfully"
          ${SUDO} systemctl status ${PGSQL_SERVICE} --no-pager
          sleep 5
          echo -e "${ORANGE}Restarting script. Please try again..."
          sleep 5
          cd ${CURRDIR}
          ./${SCRIPT_NAME}
        fi
      fi
    fi
    show_maintenance_banner () {
      #clear
      header
      echo ""
      echo ""
      echo ""
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo ""
      echo ""
      echo "Invidious maintenance done. Now visit http://localhost:3000"
      echo ""
      echo ""
      echo ""
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }
    show_maintenance_banner
    sleep 5
    cd ${CURRDIR}
    ./${SCRIPT_NAME}
    #exit 1
    ;;
  6) # Database migration
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi

    read -p "Are you sure you want to migrate the PostgreSQL database? " answer
    echo "You entered: $answer"

    if [[ "$answer" = 'y' ]]; then
      if ( systemctl -q is-active ${PGSQL_SERVICE})
      then
        echo -e "${ORANGE}stopping Invidious...${NC}"
        ${SUDO} systemctl stop ${SERVICE_NAME}
        echo "Running Migration..."
        cd ${REPO_DIR} || exit 1
        currentVersion=$(git rev-list --max-count=1 --abbrev-commit HEAD)
        latestVersion=$(git describe --tags `git rev-list --tags --max-count=1`)
        git checkout $latestVersion
        for i in `git rev-list --abbrev-commit $currentVersion..HEAD` ;
        do
          file=./config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ;
        done

        cd -
        echo -e "${GREEN}Migration Done ${NC}"
        # Restart Invidious
        echo -e "${GREEN}Restarting Invidious...${NC}"
        ${SUDO} systemctl restart ${SERVICE_NAME}
        echo -e "${GREEN}Restarting Invidious done.${NC}"
        ${SUDO} systemctl status ${SERVICE_NAME} --no-pager
        sleep 1
        # Restart postgresql
        echo -e "${GREEN}Restarting postgresql...${NC}"
        ${SUDO} systemctl restart ${PGSQL_SERVICE}
        echo -e "${GREEN}Restarting postgresql done.${NC}"
        ${SUDO} systemctl status ${PGSQL_SERVICE} --no-pager
        sleep 5
      else
        echo -e "${RED}Database Migration failed. Is PostgreSQL running?${NC}"
        # Restart postgresql
        echo -e "${GREEN}trying to start postgresql...${NC}"
        ${SUDO} systemctl start ${PGSQL_SERVICE}
        echo -e "${GREEN}Postgresql started successfully${NC}"
        ${SUDO} systemctl status ${PGSQL_SERVICE} --no-pager
        sleep 5
        echo -e "${ORANGE}Restarting script. Please try again...${NC}"
        sleep 5
        cd ${CURRDIR}
        ./${SCRIPT_NAME}
        #exit
      fi
    fi
    show_migration_banner () {

      header

      echo ""
      echo ""
      echo ""
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo ""
      echo ""
      echo "Invidious migration done. Now visit http://localhost:3000"
      echo ""
      echo ""
      echo ""
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }

    show_migration_banner

    sleep 3
    cd ${CURRDIR}
    ./${SCRIPT_NAME}
    #exit 1
    ;;
  7) # Uninstall Invidious
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    # Set db backup path
    PgDbBakPath="/home/backup/$USER_NAME"
    # Get dbname
    RM_PSQLDB=$(get_dbname "${REPO_DIR}/config/config.yml")
    # Let's go
    while [[ $RM_PostgreSQLDB !=  "y" && $RM_PostgreSQLDB != "n" ]]; do
      read -p "       Remove database for Invidious ? [y/n]: " -e RM_PostgreSQLDB
      if [[ ! $RM_PostgreSQLDB !=  "y" ]]; then
        echo -e "       ${ORANGE}(( A backup will be placed in $PgDbBakPath ))${NC}"
        echo -e "       Your Invidious database name: $RM_PSQLDB"
      fi
      if [[ ! $RM_PostgreSQLDB !=  "y" ]]; then
        while [[ $RM_RE_PostgreSQLDB !=  "y" && $RM_RE_PostgreSQLDB != "n" ]]; do
          echo -e "       ${ORANGE}(( If yes, only data will be dropped ))${NC}"
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
      echo -e "       ${ORANGE}(( This option will remove ${REPO_DIR} ))${NC}"
      read -p "       Remove files ? [y/n]: " -e RM_FILES
      if [[ "$RM_FILES" = 'y' ]]; then
        while [[ $RM_USER !=  "y" && $RM_USER != "n" ]]; do
          echo -e "       ${RED}(( This option will remove $USER_DIR ))${NC}"
          echo -e "       ${ORANGE}(( Not needed for reinstall ))${NC}"
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
        echo -e "${ORANGE}Backup Folder Not Found, adding folder${NC}"
        ${SUDO} mkdir -p $PgDbBakPath
      fi

      echo ""
      echo -e "${GREEN}Running database backup${NC}"
      echo ""

      ${SUDO} -i -u postgres pg_dump ${RM_PSQLDB} > ${PgDbBakPath}/${RM_PSQLDB}.sql
      sleep 2
      ${SUDO} chown -R 1000:1000 "/home/backup"

      if [[ "$RM_RE_PostgreSQLDB" != 'n' ]]; then
        echo ""
        echo -e "${RED}Dropping Invidious PostgreSQL data${NC}"
        echo ""
        ${SUDO} -i -u postgres psql -c "DROP OWNED BY kemal CASCADE;"
        echo ""
        echo -e "${ORANGE}Data dropped and backed up to ${PgDbBakPath}/${RM_PSQLDB}.sql ${NC}"
        echo ""
      fi

      if [[ "$RM_RE_PostgreSQLDB" != 'y' ]]; then
        echo ""
        echo -e "${RED}Dropping Invidious PostgreSQL database${NC}"
        echo ""
        ${SUDO} -i -u postgres psql -c "DROP DATABASE $RM_PSQLDB;"
        echo ""
        echo -e "${ORANGE}Database dropped and backed up to ${PgDbBakPath}/${RM_PSQLDB}.sql ${NC}"
        echo ""
        echo "Removing user kemal"
        ${SUDO} -i -u postgres psql -c "DROP ROLE IF EXISTS kemal;"
      fi
    fi

    # Reload Systemd
    ${SUDO} systemctl daemon-reload
    # Remove packages installed during installation
    if [[ "$RM_PACKAGES" = 'y' ]]; then
      echo ""
      echo -e "${ORANGE}Removing packages installed during installation."
      echo ""
      echo -e "Note: PostgreSQL will not be removed due to unwanted complications${NC}"
      echo ""

      if ${PKGCHK} $UNINSTALL_PKGS >/dev/null 2>&1; then
        for i in $UNINSTALL_PKGS; do
          echo ""
          echo -e "removing packages."
          echo ""
          ${UNINSTALL} $i
        done
      fi
      echo ""
      echo -e "${GREEN}done."
      echo ""
    fi

    # Remove conf files
    if [[ "$RM_PURGE" = 'y' ]]; then
      # Removing invidious files and modules files
      echo ""
      echo -e "${ORANGE}Removing invidious files and modules files.${NC}"
      echo ""

      if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
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
          echo -e "purging packages."
          echo ""
          ${PURGE} $i
        done
      fi

      echo ""
      echo -e "cleaning up."
      echo ""
      ${CLEAN}
      echo ""
      echo -e "${GREEN}done.${NC}"
      echo ""
    fi

    if [[ "$RM_FILES" = 'y' ]]; then
      # If directory is present, remove
      if [[ -d ${REPO_DIR} ]]; then
        echo -e "${ORANGE}Folder Found, removing folder${NC}"
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
        echo -e "${ORANGE}User $USER_NAME Found, removing user and files${NC}"
        echo ""
        if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
          deluser --remove-home $USER_NAME
        fi
        if [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
          /usr/sbin/userdel -r $USER_NAME
        fi
      fi
    fi
    # We're done !
    echo ""
    echo -e "${GREEN}Un-installation done.${NC}"
    echo ""
    sleep 3
    cd ${CURRDIR}
    ./${SCRIPT_NAME}
    #exit
    ;;
  8) # Exit
    echo ""
    echo -e "${ORANGE}Goodbye.${NC}"
    echo ""
    exit
    ;;
esac
