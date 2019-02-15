#!/bin/bash
readonly CURRDIR=$(pwd)
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
readonly SCRIPT_DIR=$(dirname "${sfp}")

## Author: Tommy Miland (@tmiland)
######################################################################
####                    Invidious Update.sh                       ####
####            Automatic update script for Invidio.us            ####
####            Script to update or install Invidious             ####
####                   Maintained by @tmiland                     ####
######################################################################
version='1.1.7'
# Colors used for printing
RED='\033[0;31m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

UPDATE='check'
# Set username
USER_NAME=invidious

# Set userdir
USER_DIR="/home/invidious"

# Set default Database info
#psqluser=kemal
#psqlpass=kemal
#psqldb=invidious

PRE_INSTALL_PKGS="apt-transport-https git curl sudo"

INSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev postgresql libsqlite3-dev"

UNINSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev libsqlite3-dev" # Don't touch postgresql

BUILD_DEP_PKGS="build-essential ca-certificates wget libpcre3 libpcre3-dev autoconf unzip automake libtool tar zlib1g-dev uuid-dev lsb-release make"

IMAGICK_VER=6.9.10-27
IMAGICK_SEVEN_VER=7.0.8-27

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

# Returns the version number of a invidious_update.sh file
get_updater_version () {
  echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "$1")
}

show_update_banner () {
  clear
  echo -e "${GREEN}\n"
  echo ' ######################################################################'
  echo ' ####                    Invidious Update.sh                       ####'
  echo ' ####            Automatic update script for Invidio.us            ####'
  echo ' ####                   Maintained by @tmiland                     ####'
  echo ' ####                        version: '${version}'                        ####'
  echo ' ######################################################################'
  echo -e "${NC}\n"
  echo "Welcome to the Invidious Update.sh script."
  echo ""
  echo "There is a newer version of Invidious Update.sh available."
  echo ""
  echo ""
  echo ""
  echo -e "    ${GREEN}New version:${NC} ${LATEST_VER}"
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

  declare -r tmpfile=$(download_file 'https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/invidious_update.sh')

  LATEST_VER=$(get_updater_version "${tmpfile}") < $(get_updater_version "${SCRIPT_DIR}/invidious_update.sh");

  if [[ $(get_updater_version "${SCRIPT_DIR}/invidious_update.sh") < $(get_updater_version "${tmpfile}") ]]; then
    if [ $UPDATE = 'check' ]; then
      show_update_banner
      echo -e "${RED}Update and execute [Y/N?]${NC}"
      read -p "" -n 1 -r
      echo -e "\n\n"
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        return 0 # Update available, but user chooses not to update
      fi
    fi
  else
    return 0 # No update available
  fi
  mv "${tmpfile}" "${SCRIPT_DIR}/invidious_update.sh"
  chmod +x "${SCRIPT_DIR}/invidious_update.sh"
  "${SCRIPT_DIR}/invidious_update.sh" "$@" -d
  echo ""
  echo -e "${GREEN}Update done.${NC}"
  echo ""
  sleep 3
  return 0
}

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
  echo -e "${GREEN}\n"
  echo ' ######################################################################'
  echo ' ####                    Invidious Update.sh                       ####'
  echo ' ####            Automatic update script for Invidio.us            ####'
  echo ' ####                   Maintained by @tmiland                     ####'
  echo ' ####                        version: '${version}'                        ####'
  echo ' ######################################################################'
  echo -e "${NC}\n"
  echo "Welcome to the Invidious Update.sh script."
  echo ""
  echo "What do you want to do?"
  echo "   1) Install Invidious"
  echo "   2) Update Invidious"
  echo "   3) Update Script"
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

    IN_MASTER=master

    IN_RELEASE=release

    IMAGICKPKG=imagemagick

    function chk_imagickpkg {
      if ! dpkg -s $IMAGICKPKG >/dev/null 2>&1; then
        apt -qq list $IMAGICKPKG
      else
        identify -version
      fi
    }

    # Check if the folder is a git repo and systemdservice is installed
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
    show_preinstall_banner () {
      clear
      echo -e "${GREEN}\n"
      echo ' ######################################################################'
      echo ' ####                    Invidious Update.sh                       ####'
      echo ' ####            Automatic update script for Invidio.us            ####'
      echo ' ####                   Maintained by @tmiland                     ####'
      echo ' ####                        version: '${version}'                        ####'
      echo ' ######################################################################'
      echo -e "${NC}\n"
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
    read -p "       Are you going to use https only? [true/false]:" https_only
    # Let's allow the user to confirm that what they've typed in is correct:
    echo -e "${GREEN}\n"
    echo -e "You entered: \n"
    echo -e "     branch: $IN_BRANCH"
    echo -e "     domain: $domain"
    echo -e " https only: $https_only"
    echo -e "       name: $psqldb"
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
    apt-get update  # || exit 1

    if ! dpkg -s $PRE_INSTALL_PKGS >/dev/null 2>&1; then
      for i in $PRE_INSTALL_PKGS; do
        apt install -y $i  # || exit 1
      done
    fi
    if [[ ! -e /etc/apt/sources.list.d/crystal.list ]]; then
      #apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
      curl -sL "https://keybase.io/crystal/pgp_keys.asc" | sudo apt-key add -
      echo "deb https://dist.crystal-lang.org/apt crystal main" | sudo tee /etc/apt/sources.list.d/crystal.list
    fi
    sudo apt-get update  # || exit 1 # postgresql-9.6 postgresql-client-9.6 postgresql-contrib-9.6 # Don't touch PostgreSQL
    #INSTALL_PKGS="crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev postgresql imagemagick libsqlite3-dev"
    if ! dpkg -s $INSTALL_PKGS >/dev/null 2>&1; then
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

    function GetMaster {
      master=$(git rev-list --max-count=1 --abbrev-commit HEAD)
      # Checkout master
      git checkout $master
    }

    function GetRelease {
      # Get new tags from remote
      git fetch --tags
      # Get latest tag name
      releaseTag=$(git describe --tags `git rev-list --tags --max-count=1`)
      # Checkout latest release tag
      git checkout $releaseTag
    }

    if [[ ! -d $USER_DIR/invidious ]]; then
      cd $USER_DIR || exit 1
      echo -e "${GREEN}Downloading Invidious from GitHub${NC}"
      sudo -i -u invidious \
        git clone https://github.com/omarroth/invidious
      # Make sure we are running a stable release
      cd $USER_DIR/invidious || exit 1
      # Set user permissions (just in case)
      #sudo chown -R 1000:$USER_NAME $USER_DIR
      # Checkout
      if [[ ! "$IN_BRANCH" = 'master' ]]; then
        GetRelease
      fi
    else
      GetMaster
      cd -
    fi
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
    #echo "Grant all on database $psqldb to user kemal"
    #sudo -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO kemal;"
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
    # Lets change the default user
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
      echo -e "${GREEN}\n"
      echo ' ######################################################################'
      echo ' ####                    Invidious Update.sh                       ####'
      echo ' ####            Automatic update script for Invidio.us            ####'
      echo ' ####                   Maintained by @tmiland                     ####'
      echo ' ####                        version: '${version}'                        ####'
      echo ' ######################################################################'
      echo -e "${NC}\n"
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
    # Set default branch
    branch=master

    # Set repo Dir (Place script in same root folder as repo)
    repo_dir=$USER_DIR/invidious

    # Service name
    service_name=invidious.service
    # Stop here

    repo=`ls -d $repo_dir`

    # Store user argument to force all repo update
    force_yes=false
    usage() {
      echo -e "${BLUE}\nUsage: $0 [-f] [-p] [-l] \n${NC}" 1>&2  # Echo usage string to standard error
      echo 'Arguments:'
      echo -e "\t-f FORCE YES,\t Force yes and update, rebuild and restart Invidious"
      echo -e "\t-p,\t\t Prune remote. Deletes all stale remote-tracking branches"
      echo -e "\t-l, \t\t Latest release. Fetch latest release from remote repo."
      echo -e
      exit 1
    }

    while :;
    do
      case $1
          in
        -f|--force-yes) force_yes=true ;;
        -p|--prune-remote) prune_remote=true ;;
        -l|--latest-release) latest_release=true ;;
        -?*)
          printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
          usage
          ;;
        *) break
      esac
      shift
    done

    # Get latest release - https://stackoverflow.com/a/22857288
    function latest {
      # Get new tags from remote
      git fetch --tags
      # Get latest tag name
      latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
      # Checkout latest tag
      git checkout $latestTag
    }

    function update {
      printf "\n-- Updating $Dir"
      cd $Dir || exit 1
      git stash > $USER_DIR/invidious_tmp
      editedFiles=`cat $USER_DIR/invidious_tmp`
      #sudo chown -R 1000:$USER_NAME $USER_DIR/invidious_tmp
      printf "\n"
      echo $editedFiles
      git fetch;
      LOCAL=$(git rev-parse HEAD);
      REMOTE=$(git rev-parse @{u});
      if [ $LOCAL != $REMOTE ] ; then
        git pull --rebase
      fi
      if [ "$prune_remote" = true ] ; then
        git remote update --prune
      fi
      if [ "$latest_release" = true ] ; then
        latest
      fi
      git checkout $branch
      if [[ $editedFiles != *"No local changes to save"* ]]
      then
        git stash pop
      fi
      #sudo chown -R 1000:$USER_NAME $USER_DIR
      cd -
      printf "\n"
      echo -e "${GREEN} Done Updating $Dir ${NC}"
      sleep 3
    }

    function rebuild {
      printf "\n-- Rebuilding $Dir\n"
      cd $Dir || exit 1
      shards
      crystal build src/invidious.cr --release
      #sudo chown -R 1000:$USER_NAME $USER_DIR
      cd -
      printf "\n"
      echo -e "${GREEN} Done Rebuilding $Dir ${NC}"
      sleep 3
    }

    function restart {
      printf "\n-- restarting Invidious\n"
      sudo systemctl restart $service_name
      sleep 2
      sudo systemctl status $service_name --no-pager
      printf "\n"
      echo -e "${GREEN} Invidious has been restarted ${NC}"
      sleep 3
    }

    for Dir in $repo
    do
      while true
      do
        # Check if the folder is a git repo
        if [[ -d "${Dir}/.git" ]]; then

          # Update without prompt if yes forced
          if [ "$force_yes" = true ] ; then
            update
            break;
            # Otherwise prompt user asking for repo update
          else
            show_banner
            read -p "Do you wish to update $Dir? [y/n/q] " answer

            case $answer in
              [yY]* ) update
                break ;;

              [nN]* ) break ;;

              [qQ]* ) exit ;;

              * )  echo "Enter Y, N or Q, please." ;;
            esac
          fi
        else
          break
        fi
      done

      while true; do
        # Update without prompt if yes forced
        if [ "$force_yes" = true ] ; then
          rebuild
          break;
          # Otherwise prompt user asking to rebuild
        else
          show_banner
          read -p "Do you wish to rebuild $Dir? [y/n/q]?" answer

          case $answer in
            [Yy]* ) rebuild
              break ;;

            [Nn]* ) break ;;

            [qQ]* ) exit ;;

            * ) echo "Enter Y, N or Q, please." ;;
          esac
        fi
      done

      while true; do
        # Update without prompt if yes forced
        if [ "$force_yes" = true ] ; then
          restart
          break;
          # Otherwise prompt user asking to restart
        else
          show_banner
          read -p "Do you wish to restart Invidious? [y/n/q]?" answer
          case $answer in
            [Yy]* ) restart
              break ;;

            [Nn]* ) exit ;;

            * ) echo "Enter Y, N or Q, please." ;;
          esac
        fi
      done
    done
    exit
    ;;
  3) # Update Script
    wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh -O invidious_update.sh
    chmod +x invidious_update.sh
    echo ""
    echo -e "${GREEN}Update done.${NC}"
    echo ""
    sleep 2
    ./invidious_update.sh
    exit
    ;;
  4) # Install Invidious service for systemd
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
      echo -e "${GREEN}\n"
      echo ' ######################################################################'
      echo ' ####                    Invidious Update.sh                       ####'
      echo ' ####            Automatic update script for Invidio.us            ####'
      echo ' ####                   Maintained by @tmiland                     ####'
      echo ' ####                        version: '${version}'                        ####'
      echo ' ######################################################################'
      echo -e "${NC}\n"
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
      echo -e "${GREEN}\n"
      echo ' ######################################################################'
      echo ' ####                    Invidious Update.sh                       ####'
      echo ' ####            Automatic update script for Invidio.us            ####'
      echo ' ####                   Maintained by @tmiland                     ####'
      echo ' ####                        version: '${version}'                        ####'
      echo ' ######################################################################'
      echo -e "${NC}\n"
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
      echo -e "${GREEN}\n"
      echo ' ######################################################################'
      echo ' ####                    Invidious Update.sh                       ####'
      echo ' ####            Automatic update script for Invidio.us            ####'
      echo ' ####                   Maintained by @tmiland                     ####'
      echo ' ####                        version: '${version}'                        ####'
      echo ' ######################################################################'
      echo -e "${NC}\n"
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
        read -p "       Enter Invidious PostgreSQL database name: " RM_PSQLDB
        echo -e "       ${ORANGE}(( A backup will be placed in $PgDbBakPath ))${NC}"
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
    while [[ $RM_USER !=  "y" && $RM_USER != "n" ]]; do
      read -p "       Remove user and files ? [y/n]: " -e RM_USER
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
      echo ""
      echo -e "${RED}Dropping Invidious PostgreSQL database${NC}"
      echo ""
      sudo -u postgres psql -c "DROP DATABASE $RM_PSQLDB;"
      echo ""
      echo -e "${ORANGE}Database dropped and backed up to ${PgDbBakPath}/${RM_PSQLDB}.sql ${NC}"
      echo ""
      echo "Removing user kemal"
      sudo -u postgres psql -c "DROP ROLE IF EXISTS kemal;"
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

    if [[ "$RM_PACKAGES" = 'y' ]]; then
      # Remove packages installed during installation
      echo ""
      echo -e "${ORANGE}Removing packages installed during installation.\n"
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
        deluser --remove-home $USER_NAME #&&
        #delgroup $USER_NAME
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
    echo -e "${ORANGE}In 3..2..1...${NC}"
    echo ""
    sleep 3
    echo ""
    echo -e "${ORANGE}Goodbye.${NC}"
    echo ""
    exit
    ;;

esac
