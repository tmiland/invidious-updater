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
UPDATE_SCRIPT='check'
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
if ! lsb_release -si >/dev/null 2>&1; then
  if [[ -f /etc/debian_version ]]; then
    DISTRO=$(cat /etc/issue.net)
  elif [[ -f /etc/redhat-release ]]; then
    DISTRO=$(cat /etc/redhat-release)
  fi

  case "$DISTRO" in
    Debian*)
      PKGCMD="apt-get"
      LSB=lsb-release
      ;;
    Ubuntu*)
      PKGCMD="apt"
      LSB=lsb-release
      ;;
    CentOS*)
      PKGCMD="yum"
      LSB=redhat-lsb
      ;;
    Fedora*)
      PKGCMD="dnf"
      LSB=redhat-lsb
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
      # Make sure that the script runs with root permissions
      if [[ "$EUID" != 0 ]]; then
        echo -e "${RED}${ERROR} This action needs root permissions.${NC} Please enter your root password...";
        su -s "$(which bash)" -c "${PKGCMD} install -y ${LSB}"
      else
        echo -e "${RED}${ERROR} Error: could not install ${LSB}!${NC}"
      fi
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
if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  # ImageMagick package name
  IMAGICKPKG=imagemagick
  SUDO="sudo"
  UPDATE="apt-get -o Dpkg::Progress-Fancy="1" update -qq"
  INSTALL="apt-get -o Dpkg::Progress-Fancy="1" install -qq"
  UNINSTALL="apt-get -o Dpkg::Progress-Fancy="1" remove -qq"
  PURGE="apt-get purge -o Dpkg::Progress-Fancy="1" -qq"
  CLEAN="apt-get clean && apt-get autoremove -qq"
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
  UPDATE="yum update -q"
  INSTALL="yum install -y -q"
  UNINSTALL="yum remove -y -q"
  PURGE="yum purge -y -q"
  CLEAN="yum clean all -y -q"
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
  UPDATE="dnf update -q"
  INSTALL="dnf install -y -q"
  UNINSTALL="dnf remove -y -q"
  PURGE="dnf purge -y -q"
  CLEAN="dnf clean all -y -q"
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
else
  echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
  exit 1;
fi
##
# Make sure that the script runs with root permissions
##
chk_permissions () {
  if [[ "$EUID" != 0 ]]; then
    echo -e "${RED}${ERROR} This action needs root permissions.${NC} Please enter your root password...";
    cd "$CURRDIR"
    su -s "$(which bash)" -c "./$SCRIPT_FILENAME"
    cd - > /dev/null

    exit 0;
  fi
}
########################################################
## Update invidious_update.sh                         ##
## Source: ghacks-user.js updater for macOS and Linux ##
########################################################
##
# Download method priority: curl -> wget
##
DOWNLOAD_METHOD=''
if [[ $(command -v 'curl') ]]; then
  DOWNLOAD_METHOD='curl'
elif [[ $(command -v 'wget') ]]; then
  DOWNLOAD_METHOD='wget'
else
  echo -e "${RED}${ERROR} This script requires curl or wget.\nProcess aborted${NC}"
  exit 0
fi
##
# Download files
##
download_file () {
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
##
# Open files
##
open_file () { #expects one argument: file_path

  if [ "$(uname)" == 'Darwin' ]; then
    open "$1"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    xdg-open "$1"
  else
    echo -e "${RED}${ERROR} Error: Sorry, opening files is not supported for your OS.${NC}"
  fi
}
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
##
# Returns the version number of invidious_update.sh file on line 14
##
get_updater_version () {
  echo $(sed -n '14 s/[^0-9.]*\([0-9.]*\).*/\1/p' "$1")
}
##
# Show service status - @FalconStats
##
show_status () {

  declare -a services=(
    "invidious"
    "postgresql"
  )
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
##
# Show Docker Status
##
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
##
# BANNERS
##
##
# Header
##
header () {
  echo -e "${GREEN}\n"
  echo ' ╔═══════════════════════════════════════════════════════════════════╗'
  echo ' ║                        '${SCRIPT_NAME}'                        ║'
  echo ' ║               Automatic update script for Invidio.us              ║'
  echo ' ║                      Maintained by @tmiland                       ║'
  echo ' ║                          version: '${version}'                           ║'
  echo ' ╚═══════════════════════════════════════════════════════════════════╝'
  echo -e "${NC}"
}
# Update banner
##
show_update_banner () {
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
##
# Preinstall banner
##
show_preinstall_banner () {
  clear
  header
  echo "Thank you for using the ${SCRIPT_NAME} script."
  echo ""
  echo ""
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
}
##
# Install banner
##
show_install_banner () {
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
##
# Systemd install banner
##
show_systemd_install_banner () {
  #clear
  header
  echo "Thank you for using the ${SCRIPT_NAME} script."
  echo ""
  echo "Invidious systemd install done."
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
}
##
# Maintenance banner
##
show_maintenance_banner () {
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
##
# Banner
##
show_banner () {
  #clear
  header
  echo "Welcome to the ${SCRIPT_NAME} script."
  echo ""
  echo "What do you want to do?"
  echo ""
  echo "  1) Install Invidious          5) Run Database Maintenance "
  echo "  2) Update Invidious           6) Run Database Migration   "
  echo "  3) Deploy with Docker         7) Uninstall Invidious      "
  echo "  4) Install Invidious service  8) Exit                     "
  echo "${SHOW_STATUS} ${SHOW_DOCKER_STATUS}"
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n ${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
}
##
# Exit Script
##
exit_script () {
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
   If you like this script, buy me a coffee ☕

   ${GREEN}${DONE}${NC} ${BBLUE}Paypal${NC} ${ARROW} ${ORANGE}https://paypal.me/milanddata${NC}
   ${GREEN}${DONE}${NC} ${BBLUE}BTC${NC}    ${ARROW} ${ORANGE}3MV69DmhzCqwUnbryeHrKDQxBaM724iJC2${NC}
   ${GREEN}${DONE}${NC} ${BBLUE}BCH${NC}    ${ARROW} ${ORANGE}qznnyvpxym7a8he2ps9m6l44s373fecfnv86h2vwq2${NC}
  "
  echo -e "Documentation for this script is available here: ${ORANGE}\n${ARROW} https://github.com/tmiland/Invidious-Updater${NC}\n"
  echo -e "${ORANGE}${ARROW} Goodbye.${NC} ☺"
  echo ""
  exit
}
##
# Update invidious_update.sh
##
# Default: Check for update, if available, ask user if they want to execute it
update_updater () {
  if [ $UPDATE_SCRIPT = 'no' ]; then
    return 0 # User signified not to check for updates
  fi
  echo -e "${GREEN}${ARROW} Checking for updates...${NC}"
  # Get tmpfile from github
  declare -r tmpfile=$(download_file "$LATEST_RELEASE")
  # Do the work
  # New function, fetch latest release from GitHub
  if [[ $(get_updater_version "${SCRIPT_DIR}/$SCRIPT_FILENAME") < "${RELEASE_TAG}" ]]; then
    #if [[ $(get_updater_version "${SCRIPT_DIR}/${SCRIPT_FILENAME}") < $(get_updater_version "${tmpfile}") ]]; then
    #LV=$(get_updater_version "${tmpfile}")
    if [ $UPDATE_SCRIPT = 'check' ]; then
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
    rm "${tmpfile}"
    return 0 # No update available
  fi
}
##
# Ask user to update yes/no
##
if [ $# != 0 ]; then
  while getopts ":ud" opt; do
    case $opt in
      u)
        UPDATE_SCRIPT='yes'
        ;;
      d)
        UPDATE_SCRIPT='no'
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
##
# Check which ImageMagick version is installed
##
chk_imagickpkg () {

  if [[ $(lsb_release -si) == "Debian" || $(lsb_release -si) == "Ubuntu" ]]; then
    apt -qq list $IMAGICKPKG 2>/dev/null
  elif [[ $(lsb_release -si) == "CentOS" || $(lsb_release -si) == "Fedora" ]]; then
    if [[ $(identify -version 2>/dev/null) ]]; then
      identify -version
    else
      echo -e "${ORANGE}${ERROR} ImageMagick is not installed.${NC}"
    fi
  else
    echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
    exit 1;
  fi
}
##
# Check Git repo
##
chk_git_repo () {
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
##
# Set permissions
##
set_permissions () {
  ${SUDO} chown -R $USER_NAME:$USER_NAME $USER_DIR
  ${SUDO} chmod -R 755 $USER_DIR
  #${SUDO} chmod 664 ${REPO_DIR}/config/config.yml
  #${SUDO} chmod 755 ${REPO_DIR}/invidious
}
##
# Update config
##
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
      echo -e "${GREEN}${ARROW} Updating config.yml with new info...${NC}"
      sed "s/$OLDPASS/$NEWPASS/g; s/$OLDDBNAME/$NEWDBNAME/g; s/$OLDDOMAIN/$NEWDOMAIN/g; s/$OLDHTTPS/$NEWHTTPS/g" "$f" > $TFILE &&
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

  ######################
  # Done updating config.yml with new info!
  # Source: https://www.cyberciti.biz/faq/unix-linux-replace-string-words-in-many-files/
  ######################
}
##
# Systemd install
##
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
    echo -e "${GREEN}${DONE} Invidious service has been successfully installed!${NC}"
    ${SUDO} systemctl status ${SERVICE_NAME} --no-pager
    sleep 5
  else
    echo -e "${RED}${ERROR} Invidious service installation failed...${NC}"
    sleep 5
  fi
}
##
# Get Crystal
##
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
    echo -e "${RED}${ERROR} Error: Sorry, your OS is not supported.${NC}"
    exit 1;
  fi
}
##
# Checkout Master branch
##
GetMaster () {
  master=$(git rev-list --max-count=1 --abbrev-commit HEAD)
  # Checkout master
  git checkout $master
  #git pull
  #for i in `git rev-list --abbrev-commit $master..HEAD` ; do file=${REPO_DIR}/config/migrate-scripts/migrate-db-$i.sh ; [ -f $file ] && $file ; done
}
##
# Checkout Release Tag
##
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
##
# Rebuild Invidious
##
rebuild () {
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
##
# Restart Invidious
##
restart () {
  printf "\n-- restarting Invidious\n"
  ${SUDO} systemctl restart $SERVICE_NAME
  sleep 2
  ${SUDO} systemctl status $SERVICE_NAME --no-pager
  printf "\n"
  echo -e "${GREEN}${DONE} Invidious has been restarted ${NC}"
  sleep 3
}
##
# Get dbname from config file (used in db maintenance and uninstallation)
##
get_dbname () {
  echo $(sed -n 's/.*dbname *: *\([^ ]*.*\)/\1/p' "$1")
}
