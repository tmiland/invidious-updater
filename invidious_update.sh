#!/usr/bin/env bash

###########################################################
# Script to update Invidious git repository               #
# Rebuild and restart Invidious                           #
#                                                         #
# version: 0.6                                            #
# Author: Tommy Miland                                    #
# Original Script: Git-Repo-Update by Killian Kemps       #
# Contributors: Pascal Duez                               #
###########################################################
# Set default branch
branch=master
# Set repo Dir (Place script in same root folder as repo)
repo_dir=invidious

# Service name
service_name=invidious.service
# Stop here

repo=`ls -d ~/$repo_dir`

# Store user argument to force all repo update
force_yes=false

# Colors used for printing
RED='\033[0;31m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_banner () {
  clear
  echo -e "${GREEN}\n"
  echo ' ######################################################################'
  echo ' ####                                                              ####'
  echo ' ####                    Invidious Update.sh                       ####'
  echo ' ####     Automatic update script for Invidious - Invidio.us       ####'
  echo ' ####                   Maintained by @tmiland                     ####'
  echo ' ####                       version: 0.6                           ####'
  echo ' ####                                                              ####'
  echo ' ######################################################################'
  echo -e "${NC}\n"
  echo "Welcome to the Invidious Update.sh script."
  echo ""
  echo "What do you want to do?"
  echo "   1) Update Invidious"
  echo "   2) Update the script"
  echo "   3) Exit"
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
}

show_banner
while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" ]]; do
  read -p "Select an option [1-3]: " OPTION
done
case $OPTION in
  1) # Update Invidious

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
      cd $Dir
      git stash > ~/invidious_tmp
      editedFiles=`cat ~/invidious_tmp`
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
      sleep 2
      sudo systemctl status $service_name
      printf "\n"
      echo -e "${GREEN} Invidious has been restarted ${NC}"
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
    ;;
  2) # Update the script
    wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh -O invidious_update.sh
    chmod +x invidious_update.sh
    echo ""
    echo "Update done."
    sleep 2
    ./invidious_update.sh
    exit
    ;;
  3) # Exit
    echo -e "${ORANGE}Goodbye."
    exit
    ;;

esac
