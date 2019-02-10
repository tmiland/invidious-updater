#!/bin/bash

###########################################################
#               Invidious Update.sh                       #
#        Script to update or install Invidious            #
#                                                         #
#             Maintained by @tmiland                      #
#                                                         #
###########################################################

version='0.9'

# Colors used for printing
RED='\033[0;31m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Set username
USER_NAME=invidious
# Set userdir
USER_DIR="/home/invidious"

show_banner () {
  clear
  echo -e "${GREEN}\n"
  echo ' ######################################################################'
  echo ' ####                    Invidious Update.sh                       ####'
  echo ' ####            Automatic update script for Invidio.us            ####'
  echo ' ####                   Maintained by @tmiland                     ####'
  echo ' ####                        version: '${version}'                          ####'
  echo ' ######################################################################'
  echo -e "${NC}\n"
  echo "Welcome to the Invidious Update.sh script."
  echo ""
  echo "What do you want to do?"
  echo "   1) Install Invidious"
  echo "   2) Update Invidious"
  echo "   3) Update Script"
  echo "   4) Install Invidious service for systemd"
  echo "   5) Exit"
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
}

show_banner
while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" && $OPTION != "5" ]]; do
  read -p "Select an option [1-5]: " OPTION
done
case $OPTION in
  1) # Install Invidious
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    echo ""
    echo "Please tell me what you want to install."
    echo "If you select none, Invidious will be installed with its default setup."
    echo ""
    echo "Chose what to install :"

    while [[ $Repository != "y" && $Repository != "n" ]]; do
      read -p " Add invidious user and clone repository? [y/n]: " -e Repository
    done
    while [[ $PostgresSQL != "y" && $PostgresSQL != "n" ]]; do
      read -p " Setup PostgresSQL? [y/n]: " -e PostgresSQL
      if [[ "$PostgresSQL" = 'y' ]]; then
        # Here's where the user is going to enter the Invidious database password, as it appears in the GUI:
        read -p "Enter the desired password of your Invidious PostgreSQL database: " dbpass
        # Let's allow the user to confirm that what they've typed in is correct:
        echo "You entered: $dbpass"
        read -p "Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
      fi
    done
    while [[ $SetupInvidious != "y" && $SetupInvidious != "n" ]]; do
      read -p " Setup Invidious? [y/n]: " -e SetupInvidious
      if [[ "$SetupInvidious" = 'y' ]]; then
        # Here's where the user is going to enter the Invidious domain name, as it appears in the GUI:
        read -p "Enter the desired domain name of your Invidious instance: " domain
        # Let's allow the user to confirm that what they've typed in is correct:
        echo "You entered: $domain"
        read -p "Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
      fi
    done
    while [[ $SystemdService != "y" && $SystemdService != "n" ]]; do
      read -p " Setup Systemd Service? [y/n]: " -e SystemdService
    done
    echo ""
    read -n1 -r -p "Invidious is ready to be installed, press any key to continue..."
    echo ""
    ######################
    # Setup Dependencies
    ######################
    if [[ "$SetupInvidious" = 'y' && "$PostgresSQL" = 'y' ]]; then
      apt-get update
      apt install apt-transport-https git curl sudo -y
      if [[ ! -e /etc/apt/sources.list.d/crystal.list ]]; then
        #apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
        curl -sL "https://keybase.io/crystal/pgp_keys.asc" | sudo apt-key add -
        echo "deb https://dist.crystal-lang.org/apt crystal main" | sudo tee /etc/apt/sources.list.d/crystal.list
      fi
      apt-get update
      apt install crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev postgresql imagemagick libsqlite3-dev -y --allow-unauthenticated
    fi
    ######################
    # Setup Repository
    ######################
    if [[ "$Repository" = 'y' ]]; then
      # https://stackoverflow.com/a/51894266
      grep $USER_NAME /etc/passwd >/dev/null 2>&1
      if [ ! $? -eq 0 ] ; then
        echo "User Not Found, adding user"
        /usr/sbin/useradd -m $USER_NAME
      fi
      adduser $USER_NAME sudo
      # If directory is not created
      if [[ ! -d $USER_DIR ]]; then
        echo "Folder Not Found, adding folder"
        mkdir -p $USER_DIR
      fi
      if [[ ! -d $USER_DIR/invidious ]]; then
        cd $USER_DIR || exit 1
        echo "Downloading Invidious from GitHub"
        git clone https://github.com/omarroth/invidious
        chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
      fi
    fi
    ######################
    # Setup PostgresSQL
    ######################
    if [[ "$PostgresSQL" = 'y' ]]; then
      # Lets change the default password
      OLD="password: kemal"
      NEW="password: $dbpass"
      DPATH="$USER_DIR/invidious/config/config.yml"
      BPATH="$USER_DIR/backup/invidious"
      TFILE="/tmp/config.yml.tmp.$$"
      [ ! -d $BPATH ] && mkdir -p $BPATH || :
      for f in $DPATH
      do
        if [ -f $f -a -r $f ]; then
          /bin/cp -f $f $BPATH
          echo "Updating config.yml with new password"
          sed "s/$OLD/$NEW/g" "$f" > $TFILE && mv $TFILE "$f"
        else
          echo "Error: Cannot read $f"
        fi
      done
      /bin/rm $TFILE
      ######################
      # Done changing password
      # Source: https://www.cyberciti.biz/faq/unix-linux-replace-string-words-in-many-files/
      ######################
      psqluser="kemal"   # Database username
      psqlpass="$dbpass"  # Database password
      psqldb="invidious"   # Database name
      systemctl enable postgresql
      systemctl start postgresql

      echo "Creating user $psqluser with password $psqlpass"
      sudo -u postgres psql -c "CREATE USER $psqluser WITH PASSWORD '$psqlpass';"
      echo "Creating database $psqldb with owner $psqluser"
      sudo -u postgres psql -c "CREATE DATABASE $psqldb WITH OWNER $psqluser;"
      echo "Running channels.sql"
      sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/channels.sql
      echo "Running videos.sql"
      sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/videos.sql
      echo "Running channel_videos.sql"
      sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/channel_videos.sql
      echo "Running users.sql"
      sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/users.sql
      echo "Running nonces.sql"
      sudo -u postgres psql -d $psqldb -f $USER_DIR/invidious/config/sql/nonces.sql
      echo "Finished Database section"
    fi
    ######################
    # Setup Invidious
    ######################
    if [[ "$SetupInvidious" = 'y' ]]; then
      # Lets change the default password
      OLD="domain: invidio.us"
      NEW="domain: $domain"
      DPATH="$USER_DIR/invidious/config/config.yml"
      BPATH="$USER_DIR/backup/invidious"
      TFILE="/tmp/config.yml.tmp.$$"
      [ ! -d $BPATH ] && mkdir -p $BPATH || :
      for f in $DPATH
      do
        if [ -f $f -a -r $f ]; then
          /bin/cp -f $f $BPATH
          echo "Updating config.yml with new domain"
          sed "s/$OLD/$NEW/g" "$f" > $TFILE && mv $TFILE "$f"
        else
          echo "Error: Cannot read $f"
        fi
      done
      if [[ -e $TFILE ]]; then
        /bin/rm $TFILE
      else
        echo "Done updating config.yml"
      fi

      cd $USER_DIR/invidious || exit 1
      shards
      crystal build src/invidious.cr --release
      chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
    fi
    ######################
    # Setup Systemd Service
    ######################
    if [[ "$SystemdService" = 'y' && ! -e /lib/systemd/system/invidious.service ]]; then
      cd /lib/systemd/system/ || exit 1
      wget https://github.com/omarroth/invidious/raw/master/invidious.service
      # Enable invidious start at boot
      sudo systemctl enable invidious
      # Restart Invidious
      sudo systemctl restart invidious
    fi
    if ( systemctl -q is-active invidious.service)
    then
      echo -e "${GREEN}Invidious service has been successfully installed"
      sleep 5
    else
      echo -e "${RED}Invidious service installation failed."
      sleep 5
    fi
    show_install_banner () {
      clear
      echo -e "${GREEN}\n"
      echo ' ######################################################################'
      echo ' ####                    Invidious Update.sh                       ####'
      echo ' ####            Automatic update script for Invidio.us            ####'
      echo ' ####                   Maintained by @tmiland                     ####'
      echo ' ####                        version: '${version}'                          ####'
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
      cd $Dir
      git stash > $USER_DIR/invidious_tmp
      editedFiles=`cat $USER_DIR/invidious_tmp`
      chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious_tmp
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
      chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
      cd -
      printf "\n"
      echo -e "${GREEN} Done Updating $Dir ${NC}"
    }

    function rebuild {
      printf "\n-- Rebuilding $Dir\n"
      cd $Dir
      shards
      crystal build src/invidious.cr --release
      chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
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
    exit
    ;;
  3) # Update Script
    wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh -O invidious_update.sh
    chmod +x invidious_update.sh
    echo ""
    echo "Update done."
    sleep 2
    ./invidious_update.sh
    exit
    ;;
  4) # Install Invidious service for systemd
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    if [[ ! -e /lib/systemd/system/invidious.service ]]; then
      cd /lib/systemd/system/ || exit 1
      wget https://github.com/omarroth/invidious/raw/master/invidious.service
      # Enable invidious start at boot
      systemctl enable invidious
    fi
    echo ""
    echo "Invidious service done."
    sleep 5
    exit
    ;;
  5) # Exit
    echo -e "${ORANGE}Goodbye."
    exit
    ;;

esac
