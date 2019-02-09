#!/usr/bin/env bash

###########################################################
# Script to update Invidious git repository               #
# Rebuild and restart Invidious                           #
#                                                         #
# version: 0.5                                            #
# Author: Tommy Miland                                    #
# Original Script: Git-Repo-Update by Killian Kemps       #
# Contributors: Pascal Duez                               #
# ghacks-user.js updater for macOS and Linux              #
###########################################################
# Set default branch
branch=master
# Set repo Dir (Place script in same root folder as repo)
repo_dir=invidious
# Service name
service_name=invidious.service
# Stop here

repo=`ls -d ~/$repo_dir`
tmpdir=`ls -d ~/tmp/invidious_update`

# Store user argument to force all repo update
force_yes=false
update_script='check'

# Colors used for printing
RED='\033[0;31m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

show_banner () {
  echo -e "${GREEN}\n"
  echo ' ######################################################################'
  echo ' ####                                                              ####'
  echo ' ####                    Invidious Update.sh                       ####'
  echo ' ####     Automatic update script for Invidious - Invidio.us       ####'
  echo ' ####                   Maintained by @tmiland                     ####'
  echo ' ####                                                              ####'
  echo ' ######################################################################'
  echo -e "${NC}\n"
  echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
}

#########################
#      Arguments        #
#########################

usage() {
  echo -e "${BLUE}\nUsage: $0 [-f] [-p] [-l] \n${NC}" 1>&2  # Echo usage string to standard error
  echo 'Arguments:'
  echo -e "\t-f FORCE YES,\t Force yes and update, rebuild and restart Invidious"
  echo -e "\t-p,\t\t Prune remote. Deletes all stale remote-tracking branches"  
  echo -e "\t-l, \t\t Latest release. Fetch latest release from remote repo."
  echo -e
  exit 1
}

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

###################################
#   Update invidious_update.sh    #
###################################

# Returns the version number of a updater.sh file
get_updater_version () {
  echo $(sed -n '5 s/.*[[:blank:]]\([[:digit:]]*\.[[:digit:]]*\)/\1/p' "$1")
}

# Update invidious_update.sh
# Default: Check for update, if available, ask user if they want to execute it

update_updater () {
  if [ $update_script = 'no' ]; then
    return 0 # User signified not to check for updates
  fi

  declare -r tmpfile=$(download_file 'https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/invidious_update.sh')

  if [[ $(get_updater_version "~/invidious_update.sh") < $(get_updater_version "${tmpfile}") ]]; then
    if [ $update_script = 'check' ]; then
      echo -e "There is a newer version of invidious_update.sh available. ${RED}Update and execute Y/N?${NC}"
      read -p "" -n 1 -r
      echo -e "\n\n"
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        return 0 # Update available, but user chooses not to update
      fi
    fi
  else
    return 0 # No update available
  fi
  mv "${tmpfile}" "~/invidious_update.sh"
  chmod u+x "~/invidious_update.sh"
  "~/invidious_update.sh" "$@" -d
  exit 1
}

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
  cd $Dir
  git stash > $tmpdir
  editedFiles=`cat $tmpdir`
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
  cd -
  printf "\n"
  echo -e "${GREEN} Done Updating $Dir ${NC}"
}

function rebuild {
  printf "\n-- Rebuilding $Dir\n"
  cd $Dir
  shards
  crystal build src/invidious.cr --release
  cd -
  printf "\n"
  echo -e "${GREEN} Done Rebuilding $Dir ${NC}"
}

function restart {
    printf "\n-- restarting Invidious\n"
    sudo systemctl restart $service_name
    sleep 5
    sudo systemctl status $service_name
    printf "\n"
    echo -e "${GREEN} Invidious has been restarted ${NC}"
}

while true; do
  # Update without prompt if yes forced
  if [ "$force_yes" = true ] ; then
    update_updater
    break;
    # Otherwise prompt user asking to invidious_update.sh
  else
  read -p "Do you wish to update invidious_update.sh? [y/n/q]?" answer
  case $answer in
    [Yy]* ) update_updater
      break ;;

    [Nn]* ) exit ;;

    * ) echo "Enter Y, N or Q, please." ;;
  esac
fi
done

for Dir in $repo
do
  while true
  do
    # Check if the folder is a git repo
    if [[ -d "${Dir}/.git" ]]; then

      # Update without prompt if yes forced
      if [ "$force_yes" = true ] ; then
        show_banner
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
done
while true; do
  # Update without prompt if yes forced
  if [ "$force_yes" = true ] ; then
    restart
    break;
    # Otherwise prompt user asking to restart
  else
  read -p "Do you wish to restart Invidious? [y/n/q]?" answer
  case $answer in
    [Yy]* ) restart
      break ;;

    [Nn]* ) exit ;;

    * ) echo "Enter Y, N or Q, please." ;;
  esac
fi
done
