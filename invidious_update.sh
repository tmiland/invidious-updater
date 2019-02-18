#!/bin/bash

CURRDIR=$(pwd)
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
SCRIPT_DIR=$(dirname "${sfp}")
## Author: Tommy Miland (@tmiland) - Copyright (c) 2019
######################################################################
####                    Invidious Update.sh                       ####
####            Automatic update script for Invidio.us            ####
####            Script to update or install Invidious             ####
####                   Maintained by @tmiland                     ####
######################################################################
version='1.2.3' # Must stay on line 14 for updater to fetch the numbers

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
# Set username
USER_NAME=invidious
# Set userdir
USER_DIR="/home/invidious"
# Master branch
IN_MASTER=master
# Release tag
IN_RELEASE=release
# Service name
SERVICE_NAME=invidious.service
# ImageMagick package name
IMAGICKPKG=imagemagick
# Pre-install packages
PRE_INSTALL_PKGS="apt-transport-https git curl sudo"
# Install packages
INSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev postgresql libsqlite3-dev"
#Uninstall packages
UNINSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev libsqlite3-dev"
# Build-dep packages
BUILD_DEP_PKGS="build-essential ca-certificates wget libpcre3 libpcre3-dev autoconf unzip automake libtool tar zlib1g-dev uuid-dev lsb-release make"
# ImageMagick 6 version
IMAGICK_VER=6.9.10-27
# ImageMagick 7 version
IMAGICK_SEVEN_VER=7.0.8-27
# Checkout Master branch
function GetMaster {
  master=$(git rev-list --max-count=1 --abbrev-commit HEAD)
  # Checkout master
  git checkout $master
  git pull
  #for i in `git rev-list --abbrev-commit $master..HEAD` ; do file=$USER_DIR/invidious/config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ; done
}
# Checkout Release Tag
function GetRelease {
  # Get new tags from remote
  git fetch --tags
  # Get latest tag name
  latestVersion=$(git describe --tags `git rev-list --tags --max-count=1`)
  # Checkout latest release tag
  git checkout $latestVersion
  git pull
  #for i in `git rev-list --abbrev-commit $currentVersion..HEAD` ; do file=$USER_DIR/invidious/config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ; done
}
# Rebuild Invidious
function rebuild {
  printf "\n-- Rebuilding $USER_DIR/invidious\n"
  cd $USER_DIR/invidious || exit 1
  shards
  crystal build src/invidious.cr --release
  #sudo chown -R 1000:$USER_NAME $USER_DIR
  cd -
  printf "\n"
  echo -e "${GREEN} Done Rebuilding $USER_DIR/invidious ${NC}"
  sleep 3
}
# Restart Invidious
function restart {
  printf "\n-- restarting Invidious\n"
  sudo systemctl restart $SERVICE_NAME
  sleep 2
  sudo systemctl status $SERVICE_NAME --no-pager
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
################################################
## Update invidious_update.sh                 ##
## ghacks-user.js updater for macOS and Linux ##
################################################
# Returns the version number of a invidious_update.sh file on line 14
get_updater_version () {
  echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "$1")
}
header () {
  echo -e "${GREEN}\n"
  echo ' ######################################################################'
  echo ' ####                    Invidious Update.sh                       ####'
  echo ' ####            Automatic update script for Invidio.us            ####'
  echo ' ####                   Maintained by @tmiland                     ####'
  echo ' ####                       version: '${version}'                         ####'
  echo ' ######################################################################'
  echo -e "${NC}\n"
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
  if [ $UPDATE = 'no' ]; then
    return 0 # User signified not to check for updates
  fi
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
        chmod +x "${SCRIPT_DIR}/invidious_update.sh"
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
  clear
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
    # Check if Debian/Ubuntu
    if [[ ! $(lsb_release -si) == "Debian" && ! $(lsb_release -si) == "Ubuntu" ]]
    then
      echo -e "${RED}Sorry, This script only runs on Debian/Ubuntu${NC}"
      exit 1
    fi
    # Check which ImageMagick version is installed
    function chk_imagickpkg {
      if ! dpkg -s $IMAGICKPKG >/dev/null 2>&1; then
        apt -qq list $IMAGICKPKG
      else
        identify -version
      fi
    }
    chk_git_repo () {
      # Check if the folder is a git repo
      if [[ -d "$USER_DIR/invidious/.git" ]]; then
        #if (systemctl -q is-active invidious.service) && -d "$USER_DIR/invidious/.git" then
        echo ""
        echo -e "${RED}Looks like Invidious is already installed!${NC}"
        echo ""
        echo -e "${ORANGE}If you want to reinstall, please choose option 7 to Uninstall Invidious first!${NC}"
        echo ""
        sleep 3
        ./invidious_update.sh
        exit 1
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
    #read -p "Enter the desired branch of your Invidious installation: " branch
    # Here's where the user is going to enter the Invidious database user, as it appears in the GUI:
    #read -p "Enter the desired user of your Invidious PostgreSQL database: " psqluser
    # Here's where the user is going to enter the Invidious database name, as it appears in the GUI:
    read -p "       Select database name:" psqldb
    # Here's where the user is going to enter the Invidious database password, as it appears in the GUI:
    read -p "       Select database password:" psqlpass
    # Let's allow the user to confirm that what they've typed in is correct:
    #echo "You entered: password: $psqlpass name: $psqldb"
    #read -p "Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    # Here's where the user is going to enter the Invidious domain name, as it appears in the GUI:
    read -p "       Enter the desired domain name:" domain
    # Here's where the user is going to enter the Invidious https only settings, as it appears in the GUI:
    while [[ $https_only != "y" && $https_only != "n" ]]; do
      read -p "Are you going to use https only? [y/n]: " https_only
    done
    case $https_only in
      y)
        https_only=true
        ;;
      n)
        https_only=false
        ;;
    esac
    # Let's allow the user to confirm that what they've typed in is correct:
    echo -e "${GREEN}\n"
    echo -e "You entered: \n"
    echo -e "     branch: $IN_BRANCH"
    echo -e "     domain: $domain"
    echo -e " https only: $https_only"
    echo -e "     dbname: $psqldb"
    echo -e "   password: $psqlpass"
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
    #read -p "Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    echo ""
    read -n1 -r -p "Invidious is ready to be installed, press any key to continue..."
    echo ""
    ######################
    # Setup Dependencies
    ######################
    if ! dpkg -s $PRE_INSTALL_PKGS >/dev/null 2>&1; then
      apt-get update
      for i in $PRE_INSTALL_PKGS; do
        apt install -y $i  # || exit 1
      done
    fi
    if [[ ! -e /etc/apt/sources.list.d/crystal.list ]]; then
      #apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
      curl -sL "https://keybase.io/crystal/pgp_keys.asc" | sudo apt-key add -
      echo "deb https://dist.crystal-lang.org/apt crystal main" | sudo tee /etc/apt/sources.list.d/crystal.list
    fi
    # || exit 1 # postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6 # Don't touch PostgreSQL
    #INSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev postgresql imagemagick libsqlite3-dev"
    if ! dpkg -s $INSTALL_PKGS >/dev/null 2>&1; then
      sudo apt-get update
      for i in $INSTALL_PKGS; do
        sudo apt install -y $i  # || exit 1 #--allow-unauthenticated
      done
    fi
    #################
    # ImageMagick 6
    ################
    if [[ "$IMAGEMAGICK" = 'y' ]]; then

      if ! dpkg -s $BUILD_DEP_PKGS >/dev/null 2>&1; then
        for i in $BUILD_DEP_PKGS; do
          apt install -y $i  # || exit 1
        done
      fi
      sudo apt purge imagemagick -y
      sudo apt autoremove

      cd /tmp || exit 1
      wget https://github.com/ImageMagick/ImageMagick6/archive/${IMAGICK_VER}.tar.gz
      tar -xvf ${IMAGICK_VER}.tar.gz
      cd ImageMagick6-${IMAGICK_VER}

      ./configure \
        --with-rsvg

      make
      sudo make install

      sudo ldconfig /usr/local/lib

      identify -version
      sleep 5
      #if [[ -e /usr/bin/convert ]]; then
      #  cp /usr/bin/convert /usr/bin/convert.bak
      #  rm -r /usr/bin/convert
      #  sudo ln -s /usr/local/bin/convert /usr/bin/convert
      #fi
      rm -r /tmp/ImageMagick6-${IMAGICK_VER}
      rm -r /tmp/${IMAGICK_VER}.tar.gz

    fi
    #################
    # ImageMagick 7
    ################
    if [[ "$IMAGEMAGICK_SEVEN" = 'y' ]]; then
      if ! dpkg -s $BUILD_DEP_PKGS >/dev/null 2>&1; then
        for i in $BUILD_DEP_PKGS; do
          apt install -y $i
        done
      fi
      sudo apt purge imagemagick -y
      sudo apt autoremove

      cd /tmp || exit 1
      wget https://www.imagemagick.org/download/ImageMagick-${IMAGICK_SEVEN_VER}.tar.gz
      tar -xvf ImageMagick-${IMAGICK_SEVEN_VER}.tar.gz
      cd ImageMagick-${IMAGICK_SEVEN_VER}

      ./configure \
        --with-rsvg \
        #PREFIX          = /usr/local \
        #EXEC-PREFIX     = /usr/local

      make
      sudo make install

      sudo ldconfig /usr/local/lib

      identify -version
      sleep 5
      rm -r /tmp/ImageMagick-${IMAGICK_SEVEN_VER}
      rm -r /tmp/ImageMagick-${IMAGICK_SEVEN_VER}.tar.gz

    fi

    if [[ $IMAGEMAGICK_SEVEN != "y" && $IMAGEMAGICK != "y" ]]; then
      sudo apt install -y imagemagick
    fi
    ######################
    # Add user postgres if not already present
    ######################
    #grep postgres /etc/passwd >/dev/null 2>&1
    #if [ ! $? -eq 0 ] ; then
    #   echo -e "${ORANGE}User postgres not found, adding user${NC}"
    #  /usr/sbin/useradd -m postgres \
      #    rm -r /home/postgres
    #fi
    #sudo pg_createcluster -- start 9.6 main \
      #  sudo chown root.postgres /var/log/postgresql \
      #  sudo chmod g+wx /var/log/postgresql
    ######################
    # Setup Repository
    ######################
    # https://stackoverflow.com/a/51894266
    grep $USER_NAME /etc/passwd >/dev/null 2>&1
    if [ ! $? -eq 0 ] ; then
      echo -e "${ORANGE}User $USER_NAME Not Found, adding user${NC}"
      #/usr/sbin/useradd -m $USER_NAME
      sudo useradd -m $USER_NAME
    fi
    # If directory is not created
    if [[ ! -d $USER_DIR ]]; then
      echo -e "${ORANGE}Folder Not Found, adding folder${NC}"
      mkdir -p $USER_DIR
    fi

    #if [[ ! -d $USER_DIR/invidious ]]; then
    echo -e "${GREEN}Downloading Invidious from GitHub${NC}"
    #sudo -i -u $USER_NAME
    cd $USER_DIR || exit 1
    git clone https://github.com/omarroth/invidious
    # Set user permissions (just in case)
    sudo chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
    sudo chmod -R 755 $USER_DIR/invidious/config/sql/*.sql
    cd $USER_DIR/invidious || exit 1
    # Checkout
    if [[ ! "$IN_BRANCH" = 'master' ]]; then
      GetRelease
    fi
    if [[ ! "$IN_BRANCH" = 'release' ]]; then
      GetMaster
    fi
    cd -
    #fi
    systemctl enable postgresql
    sleep 1
    systemctl start postgresql
    sleep 1
    # Create users and set privileges
    #echo "Creating user postgres with no password"
    #sudo -u postgres psql -c "CREATE USER postgres;"
    #echo "Grant all on database postgres to user postgres"
    #sudo -u postgres psql -c "GRANT ALL ON DATABASE postgres TO postgres;"
    echo "Creating user kemal with password $psqlpass"
    sudo -u postgres psql -c "CREATE USER kemal WITH PASSWORD '$psqlpass';"
    #echo "Creating user $psqluser with password $psqlpass"
    #sudo -u postgres psql -c "CREATE USER $psqluser WITH PASSWORD '$psqlpass';"
    #echo "Creating user $USER_NAME with password $psqlpass"
    #sudo -u postgres psql -c "CREATE USER $USER_NAME WITH PASSWORD '$psqlpass';"
    echo "Creating database $psqldb with owner kemal"
    sudo -u postgres psql -c "CREATE DATABASE $psqldb WITH OWNER kemal;"
    echo "Grant all on database $psqldb to user kemal"
    sudo -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO kemal;"
    #echo "Grant all on database $psqldb to user $psqluser"
    #sudo -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO $psqluser;"
    #echo "Grant all on database $psqldb to user $USER_NAME"
    #sudo -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO $USER_NAME;"
    # Import db files
    echo "Running channels.sql"
    sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/channels.sql
    echo "Running videos.sql"
    sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/videos.sql
    echo "Running channel_videos.sql"
    sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/channel_videos.sql
    echo "Running users.sql"
    sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/users.sql
    if [[ -e $USER_DIR/invidious/config/sql/session_ids.sql ]]; then
      echo "Running session_ids.sql"
      sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/session_ids.sql
    fi
    echo "Running nonces.sql"
    sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/nonces.sql
    echo "Finished Database section"
    ######################
    # Update config.yml with new info from user input
    ######################
    # Lets change the default user # Not a good idea... Invidious uses 'kemal'. Left for reference
    #OLDUSER="user: kemal"
    #NEWUSER="user: $psqluser"
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
    DPATH="$USER_DIR/invidious/config/config.yml"
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
    cd $USER_DIR/invidious || exit 1
    #sudo -i -u invidious \
      shards
    crystal build src/invidious.cr --release
    sudo chown -R $USER_NAME:$USER_NAME $USER_DIR
    ######################
    # Setup Systemd Service
    ######################
    cp $USER_DIR/invidious/invidious.service /lib/systemd/system/invidious.service
    #wget https://github.com/omarroth/invidious/raw/master/invidious.service
    # Enable invidious start at boot
    sudo systemctl enable invidious
    # Reload Systemd
    sudo systemctl daemon-reload
    # Restart Invidious
    sudo systemctl start invidious
    if ( systemctl -q is-active invidious.service)
    then
      echo -e "${GREEN}Invidious service has been successfully installed!${NC}"
      sudo systemctl status invidious --no-pager
      sleep 5
    else
      echo -e "${RED}Invidious service installation failed...${NC}"
      sleep 5
    fi
    show_install_banner () {
      #clear
      header
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo "Invidious install done. Now visit http://localhost:3000"
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }
    show_install_banner
    sleep 5
    exit
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
    cd $USER_DIR/invidious || exit 1
    # Checkout
    if [[ ! "$IN_BRANCH" = 'master' ]]; then
      GetRelease
    fi
    if [[ ! "$IN_BRANCH" = 'release' ]]; then
      GetMaster
    fi
    rebuild
    sudo chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
    #cd -
    restart
    exit
    ;;
  3) # Deploy with Docker
    docker_repo_chk () {
      # Check if the folder is a git repo
      if [[ ! -d "$USER_DIR/invidious/.git" ]]; then
        #if (systemctl -q is-active invidious.service) && -d "$USER_DIR/invidious/.git" then
        echo ""
        echo -e "${RED}Looks like Invidious is not installed!${NC}"
        echo ""
        read -p "Do you want to download Invidious? [y/n/q]?" answer
        echo ""
        case $answer in
          [Yy]* )
            echo -e "${GREEN}Seting up Dependencies${NC}"
            if ! dpkg -s $PRE_INSTALL_PKGS >/dev/null 2>&1; then
              apt-get update
              for i in $PRE_INSTALL_PKGS; do
                apt install -y $i  # || exit 1
              done
            fi
            mkdir -p $USER_DIR
            cd $USER_DIR || exit 1
            echo -e "${GREEN}Downloading Invidious from GitHub${NC}"
            git clone https://github.com/omarroth/invidious
            sleep 3
            cd -
            ./invidious_update.sh
            ;;
          [Nn]* )
            sleep 3
            cd -
            ./invidious_update.sh
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
    echo "   1) Build and start cluster:"
    echo "   2) Rebuild cluster"
    echo "   3) Delete data and rebuild"
    echo "   4) Install Docker CE"
    echo ""
    while [[ $DOCKER_OPTION !=  "1" && $DOCKER_OPTION != "2" && $DOCKER_OPTION != "3" && $DOCKER_OPTION != "4" ]]; do
      read -p "Select an option [1-4]: " DOCKER_OPTION
    done
    case $DOCKER_OPTION in
      1) # Build and start cluster
        while [[ $BUILD_DOCKER !=  "y" && $BUILD_DOCKER != "n" ]]; do
          read -p "   Build and start cluster? [y/n]: " -e BUILD_DOCKER
        done
        docker_repo_chk
        if dpkg -s docker-ce docker-ce-cli >/dev/null 2>&1; then
          if [[ $BUILD_DOCKER = "y" ]]; then
            echo -e "${BLUE}(( Press ctrl+c to exit ))${NC}"
            cd $USER_DIR/invidious
            docker-compose up >/dev/null
            echo -e "${GREEN}Deployment done.${NC}"
            sleep 5
            cd -
            ./invidious_update.sh
            #exit
          fi
          if [[ $BUILD_DOCKER = "n" ]]; then
            cd -
            ./invidious_update.sh
          fi
        else
          echo -e "${RED}Docker is not installed, please choose option 4)${NC}"
        fi
        exit
        ;;
      2) # Rebuild cluster
        while [[ $REBUILD_DOCKER !=  "y" && $REBUILD_DOCKER != "n" ]]; do
          read -p "       Rebuild cluster ? [y/n]: " -e REBUILD_DOCKER
        done
        docker_repo_chk
        if dpkg -s docker-ce docker-ce-cli >/dev/null 2>&1; then
          if [[ $REBUILD_DOCKER = "y" ]]; then
            cd $USER_DIR/invidious
            docker-compose build
            echo -e "${GREEN}Rebuild done.${NC}"
            sleep 5
            cd -
            ./invidious_update.sh
          fi
          if [[ $REBUILD_DOCKER = "n" ]]; then
            cd -
            ./invidious_update.sh
          fi
        else
          echo -e "${RED}Docker is not installed, please choose option 4)${NC}"
        fi
        exit
        ;;
      3) # Delete data and rebuild
        while [[ $DEL_REBUILD_DOCKER !=  "y" && $DEL_REBUILD_DOCKER != "n" ]]; do
          read -p "       Delete data and rebuild Docker? [y/n]: " -e DEL_REBUILD_DOCKER
        done
        docker_repo_chk
        if dpkg -s docker-ce docker-ce-cli >/dev/null 2>&1; then
          if [[ $DEL_REBUILD_DOCKER = "y" ]]; then
            cd $USER_DIR/invidious
            docker volume rm invidious_postgresdata
            sleep 5
            docker-compose build
            echo -e "${GREEN}Data deleted and Rebuild done.${NC}"
            sleep 5
            cd -
            ./invidious_update.sh
          fi
          if [[ $DEL_REBUILD_DOCKER = "n" ]]; then
            cd -
            ./invidious_update.sh
          fi
        else
          echo -e "${RED}Docker is not installed, please choose option 4)${NC}"
        fi
        exit
        ;;
      4) # Install Docker CE
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
        sudo apt-get update
        #Install packages to allow apt to use a repository over HTTPS:
        sudo apt-get install \
          apt-transport-https \
          ca-certificates \
          curl \
          gnupg2 \
          software-properties-common -y
        # Add Docker’s official GPG key:
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
        # Verify that you now have the key with the fingerprint 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, by searching for the last 8 characters of the fingerprint.
        sudo apt-key fingerprint 0EBFCD88

        sudo add-apt-repository \
          "deb [arch=amd64] https://download.docker.com/linux/debian \
            $(lsb_release -cs) \
          ${DOCKER_VER}"
        # Update the apt package index:
        sudo apt-get update
        # Install the latest version of Docker CE and containerd
        sudo apt-get install docker-ce docker-ce-cli containerd.io -y
        # Verify that Docker CE is installed correctly by running the hello-world image.
        sudo docker run hello-world
        # We're almost done !
        echo "Docker Installation done."
        while [[ $Docker_Compose !=  "y" && $Docker_Compose != "n" ]]; do
          read -p "       Install Docker Compose ? [y/n]: " -e Docker_Compose
        done
        if [[ "$Docker_Compose" = 'y' ]]; then
          # download the latest version of Docker Compose:
          sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          sleep 5
          # Apply executable permissions to the binary:
          sudo chmod +x /usr/local/bin/docker-compose
          # Create a symbolic link to /usr/bin
          sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
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
    if ( ! systemctl -q is-active invidious.service)
    then
      cp $USER_DIR/invidious/invidious.service /lib/systemd/system/invidious.service
      #wget https://github.com/omarroth/invidious/raw/master/invidious.service
      # Enable invidious start at boot
      sudo systemctl enable invidious
      # Reload Systemd
      sudo systemctl daemon-reload
      # Restart Invidious
      sudo systemctl start invidious
    fi
    if ( systemctl -q is-active invidious.service)
    then
      echo -e "${GREEN}Invidious service has been successfully installed!${NC}"
      sudo systemctl status invidious --no-pager
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
    sleep 5
    exit
    ;;
  5) # Database maintenance
    #psqldb="invidious"   # Database name
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    read -p "Are you sure you want to run Database Maintenance? Enter [y/n]: " answer
    #echo "You entered: $answer"
    if [[ ! "$answer" = 'n' ]]; then
      # Here's where the user is going to enter the Invidious database name, as it appears in the GUI:
      read -p "Enter database name of your Invidious PostgreSQL database: " psqldb
      # Let's allow the user to confirm that what they've typed in is correct:
      echo ""
      echo "You entered: $psqldb"
      echo ""
      read -p "Is that correct? Enter [y/n]: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
      if [[ "$answer" = 'y' ]]; then
        if ( systemctl -q is-active postgresql.service)
        then
          echo -e "${RED}stopping Invidious..."
          sudo systemctl stop invidious
          sleep 3
          echo "Running Maintenance on $psqldb"
          sudo -u postgres psql $psqldb -c "DELETE FROM nonces * WHERE expire < current_timestamp;"
          sudo -u postgres psql $psqldb -c "TRUNCATE TABLE videos;"
          sleep 3
          echo -e "${GREEN}Maintenance on $psqldb done."
          # Restart Invidious
          echo -e "${GREEN}Restarting Invidious..."
          sudo systemctl restart invidious
          echo -e "${GREEN}Restarting Invidious done."
          sudo systemctl status invidious --no-pager
          sleep 1
          # Restart postgresql
          echo -e "${GREEN}Restarting postgresql..."
          sudo systemctl restart postgresql
          echo -e "${GREEN}Restarting postgresql done."
          sudo systemctl status postgresql --no-pager
          sleep 5
        else
          echo -e "${RED}Database Maintenance failed. Is PostgreSQL running?"
          # Try to restart postgresql
          echo -e "${GREEN}trying to start postgresql..."
          sudo systemctl start postgresql
          echo -e "${GREEN}Postgresql started successfully"
          sudo systemctl status postgresql --no-pager
          sleep 5
          echo -e "${ORANGE}Restarting script. Please try again..."
          sleep 5
          ./invidious_update.sh
          exit
        fi
      fi
    fi
    show_maintenance_banner () {
      #clear
      header
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo ""
      echo "Invidious maintenance done. Now visit http://localhost:3000"
      echo ""
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }
    show_maintenance_banner
    sleep 5
    ./invidious_update.sh
    exit
    ;;
  6) # Database migration
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    read -p "Are you sure you want to migrate the PostgreSQL database? " answer
    echo "You entered: $answer"

    if [[ "$answer" = 'y' ]]; then
      if ( systemctl -q is-active postgresql.service)
      then
        echo -e "${ORANGE}stopping Invidious...${NC}"
        sudo systemctl stop invidious
        echo "Running Migration..."
        cd $USER_DIR/invidious || exit 1
        currentVersion=$(git rev-list --max-count=1 --abbrev-commit HEAD)
        latestVersion=$(git describe --tags `git rev-list --tags --max-count=1`)
        git checkout $latestVersion
        for i in `git rev-list --abbrev-commit $currentVersion..HEAD` ;
        do
          file=./config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ;
        done
        #for script in ./config/migrate-scripts/*.sh
        #do
        #  sudo -u $USER_NAME bash "$script"
        #done
        cd -
        echo -e "${GREEN}Migration Done ${NC}"
        # Restart Invidious
        echo -e "${GREEN}Restarting Invidious...${NC}"
        sudo systemctl restart invidious
        echo -e "${GREEN}Restarting Invidious done.${NC}"
        sudo systemctl status invidious --no-pager
        sleep 1
        # Restart postgresql
        echo -e "${GREEN}Restarting postgresql...${NC}"
        sudo systemctl restart postgresql
        echo -e "${GREEN}Restarting postgresql done.${NC}"
        sudo systemctl status postgresql --no-pager
        sleep 5
      else
        echo -e "${RED}Database Migration failed. Is PostgreSQL running?${NC}"
        # Restart postgresql
        echo -e "${GREEN}trying to start postgresql...${NC}"
        sudo systemctl start postgresql
        echo -e "${GREEN}Postgresql started successfully${NC}"
        sudo systemctl status postgresql --no-pager
        sleep 5
        echo -e "${ORANGE}Restarting script. Please try again...${NC}"
        sleep 5
        ./invidious_update.sh
        exit
      fi
    fi
    show_migration_banner () {
      header
      echo "Thank you for using the Invidious Update.sh script."
      echo ""
      echo "Invidious migration done. Now visit http://localhost:3000"
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }
    show_migration_banner
    sleep 3
    exit
    ;;
  7) # Uninstall Invidious
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    # Set db backup path
    PgDbBakPath="/home/backup/$USER_NAME"
    # Let's go
    while [[ $RM_PostgreSQLDB !=  "y" && $RM_PostgreSQLDB != "n" ]]; do
      read -p "       Remove PostgreSQL database for Invidious ? [y/n]: " -e RM_PostgreSQLDB
      if [[ ! $RM_PostgreSQLDB !=  "y" ]]; then
        echo -e "       ${ORANGE}(( A backup will be placed in $PgDbBakPath ))${NC}"
        read -p "       Enter Invidious PostgreSQL database name: " RM_PSQLDB
      fi
      if [[ ! $RM_PostgreSQLDB !=  "y" ]]; then
        while [[ $RM_RE_PostgreSQLDB !=  "y" && $RM_RE_PostgreSQLDB != "n" ]]; do
          echo -e "       ${ORANGE}(( If yes, only data will be dropped ))${NC}"
          read -p "       Do you intend to reinstall?: " RM_RE_PostgreSQLDB
        done
      fi
      # Let's allow the user to confirm that what they've typed in is correct:
      #echo "          You entered: database name: $RM_PSQLDB"
      #read -p "       Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
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
      echo -e "       ${ORANGE}(( This option will remove $USER_DIR/invidious ))${NC}"
      read -p "       Remove files ? [y/n]: " -e RM_FILES
      if [[ "$RM_FILES" = 'y' ]]; then
        while [[ $RM_USER !=  "y" && $RM_USER != "n" ]]; do
          echo -e "       ${RED}(( This option will remove $USER_DIR ))"
          echo -e "       (( Not needed for reinstall ))${NC}"
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
      systemctl stop invidious
      sleep 1
      systemctl restart postgresql
      sleep 1
      #   pg_dump -U $username --format=c --file=$mydatabase.sqlc $dbname
      # If directory is not created
      if [[ ! -d $PgDbBakPath ]]; then
        echo -e "${ORANGE}Backup Folder Not Found, adding folder${NC}"
        sudo mkdir -p $PgDbBakPath
      fi
      #pg_dump --username=postgres \
        #        --no-password \
        #        --format=c \
        #        --file=$PgDbBakPath/$RM_PSQLDB.sql \
        #        --dbname=$RM_PSQLDB
      echo ""
      echo -e "${GREEN}Running database backup${NC}"
      echo ""
      #sudo -u postgres psql ${RM_PSQLDB} > ${PgDbBakPath}/${RM_PSQLDB}.sql || exit 1
      sudo -u postgres pg_dump ${RM_PSQLDB} > ${PgDbBakPath}/${RM_PSQLDB}.sql
      sleep 2
      sudo chown -R 1000:1000 "/home/backup"
      if [[ "$RM_RE_PostgreSQLDB" != 'n' ]]; then
        echo ""
        echo -e "${RED}Dropping Invidious PostgreSQL data${NC}"
        echo ""
        sudo -u postgres psql -c "DROP OWNED BY kemal CASCADE;"
        echo ""
        echo -e "${ORANGE}Data dropped and backed up to ${PgDbBakPath}/${RM_PSQLDB}.sql ${NC}"
        echo ""
      fi
      if [[ "$RM_RE_PostgreSQLDB" != 'y' ]]; then
        echo ""
        echo -e "${RED}Dropping Invidious PostgreSQL database${NC}"
        echo ""
        sudo -u postgres psql -c "DROP DATABASE $RM_PSQLDB;"
        echo ""
        echo -e "${ORANGE}Database dropped and backed up to ${PgDbBakPath}/${RM_PSQLDB}.sql ${NC}"
        echo ""
        echo "Removing user kemal"
        sudo -u postgres psql -c "DROP ROLE IF EXISTS kemal;"
      fi
      #systemctl stop postgresql
      #sleep 1
      #systemctl disable postgresql
      #sleep 1
      #pg_dropcluster --stop 9.6 main
      #sleep 1
      #/usr/sbin/userdel -r postgres \
        #groupdel postgres
      #rm -r \
        #  /usr/lib/postgresql \
        #  /etc/postgresql \
        #  /usr/share/postgresql \
        #  /usr/share/postgresql-common \
        #  /var/cache/postgresql \
        #  /var/log/postgresql \
        #  /run/postgresql \
        #  /etc/postgresql-common
    fi
    # Reload Systemd
    sudo systemctl daemon-reload
    # Remove packages installed during installation
    if [[ "$RM_PACKAGES" = 'y' ]]; then
      echo ""
      echo -e "${ORANGE}Removing packages installed during installation."
      echo ""
      echo -e "Note: PostgreSQL will not be removed due to unwanted complications${NC}"
      echo ""
      # postgresql postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6 # Dont touch PostgreSQL
      #UNINSTALL_PKGS="apt-transport-https git curl sudo remove crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev imagemagick libsqlite3-dev"
      if dpkg -s $UNINSTALL_PKGS >/dev/null 2>&1; then
        for i in $UNINSTALL_PKGS; do
          echo ""
          echo -e "removing packages."
          echo ""
          apt-get remove -y $i
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
      rm -r \
        /lib/systemd/system/invidious.service \
        /etc/apt/sources.list.d/crystal.list
      # postgresql postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6 # Don't touch PostgreSQL
      #PURGE_PKGS="apt-transport-https git curl sudo remove crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev imagemagick libsqlite3-dev"
      if dpkg -s $UNINSTALL_PKGS >/dev/null 2>&1; then
        for i in $UNINSTALL_PKGS; do
          echo ""
          echo -e "purging packages."
          echo ""
          apt-get purge -y $i
        done
      fi
      echo ""
      echo -e "cleaning up."
      echo ""
      apt-get clean
      apt-get autoremove
      echo ""
      echo -e "${GREEN}done.${NC}"
      echo ""
    fi
    if [[ "$RM_FILES" = 'y' ]]; then
      # If directory is present, remove
      if [[ -d $USER_DIR/invidious ]]; then
        echo -e "${ORANGE}Folder Found, removing folder${NC}"
        rm -r $USER_DIR/invidious
      fi
    fi
    # Remove user and settings
    if [[ "$RM_USER" = 'y' ]]; then
      # Stop and disable invidious
      systemctl stop invidious
      sleep 1
      systemctl restart postgresql
      sleep 1
      systemctl daemon-reload
      sleep 1
      grep $USER_NAME /etc/passwd >/dev/null 2>&1
      if [ $? -eq 0 ] ; then
        echo ""
        echo -e "${ORANGE}User $USER_NAME Found, removing user and files${NC}"
        echo ""
        #/usr/sbin/userdel -r $USER_NAME
        deluser --remove-home $USER_NAME
      fi
    fi
    # We're done !
    echo ""
    echo -e "${GREEN}Un-installation done.${NC}"
    echo ""
    exit
    ;;
  8) # Exit
    echo ""
    echo -e "${ORANGE}Goodbye.${NC}"
    echo ""
    exit
    ;;
esac
