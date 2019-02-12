#!/bin/bash

###########################################################
#               Invidious Update.sh                       #
#        Script to update or install Invidious            #
#                                                         #
#             Maintained by @tmiland                      #
#                                                         #
###########################################################

version='1.1.2'

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

# Set default Database info
#psqluser=kemal
#psqlpass=kemal
#psqldb=invidious

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
  echo "   4) Install Invidious service for systemd"
  echo "   5) Run Database Maintenance"
  echo "   6) Run Database Migration"
  echo "   7) Exit"
  echo ""
  echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
}

show_banner
while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" && $OPTION != "5" && $OPTION != "6" && $OPTION != "7" ]]; do
  read -p "Select an option [1-7]: " OPTION
done
case $OPTION in
  1) # Install Invidious
    if [[ "$EUID" -ne 0 ]]; then
      echo -e "Sorry, you need to run this as root"
      exit 1
    fi
    echo ""
    echo -e "${BLUE}Let's go through some configuration options.${NC}"
    echo ""
    # Here's where the user is going to enter the Invidious database user, as it appears in the GUI:
    read -p "Enter the desired user of your Invidious PostgreSQL database: " psqluser
    # Here's where the user is going to enter the Invidious database password, as it appears in the GUI:
    read -p "Enter the desired password of your Invidious PostgreSQL database: " psqlpass
    # Here's where the user is going to enter the Invidious database name, as it appears in the GUI:
    read -p "Enter the desired database name of your Invidious PostgreSQL database: " psqldb
    # Let's allow the user to confirm that what they've typed in is correct:
    echo "You entered: user: $psqluser password: $psqlpass name: $psqldb"
    read -p "Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    # Here's where the user is going to enter the Invidious domain name, as it appears in the GUI:
    read -p "Enter the desired domain name of your Invidious instance: " domain
    # Here's where the user is going to enter the Invidious https only settings, as it appears in the GUI:
    read -p "Are you going to serve your Invidious instance on https only? Type true or false: " https_only
    # Let's allow the user to confirm that what they've typed in is correct:
    echo "You entered: Domain: $domain https only: $https_only"
    read -p "Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    echo ""
    read -n1 -r -p "Invidious is ready to be installed, press any key to continue..."
    echo ""
    ######################
    # Setup Dependencies
    ######################
    apt-get update
    apt install apt-transport-https git curl sudo -y
    if [[ ! -e /etc/apt/sources.list.d/crystal.list ]]; then
      #apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
      curl -sL "https://keybase.io/crystal/pgp_keys.asc" | sudo apt-key add -
      echo "deb https://dist.crystal-lang.org/apt crystal main" | sudo tee /etc/apt/sources.list.d/crystal.list
    fi
    apt-get update
    apt install crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev librsvg2-dev postgresql imagemagick libsqlite3-dev -y --allow-unauthenticated
    ######################
    # Setup Repository
    ######################
    # https://stackoverflow.com/a/51894266
    grep $USER_NAME /etc/passwd >/dev/null 2>&1
    if [ ! $? -eq 0 ] ; then
      echo -e "${ORANGE}User Not Found, adding user${NC}"
      /usr/sbin/useradd -m $USER_NAME
    fi
    adduser $USER_NAME sudo
    # If directory is not created
    if [[ ! -d $USER_DIR ]]; then
      echo -e "${ORANGE}Folder Not Found, adding folder${NC}"
      mkdir -p $USER_DIR
    fi
    if [[ ! -d $USER_DIR/invidious ]]; then
      cd $USER_DIR || exit 1
      echo -e "${GREEN}Downloading Invidious from GitHub${NC}"
      git clone https://github.com/omarroth/invidious
      chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
    fi
    systemctl enable postgresql
    systemctl start postgresql
    # Create users and set privileges
    echo "Creating user kemal with password $psqlpass"
    sudo -u postgres psql -c "CREATE USER kemal WITH PASSWORD '$psqlpass';"
    echo "Creating user $psqluser with password $psqlpass"
    sudo -u postgres psql -c "CREATE USER $psqluser WITH PASSWORD '$psqlpass';"
    echo "Creating user $USER_NAME with password $psqlpass"
    sudo -u postgres psql -c "CREATE USER $USER_NAME WITH PASSWORD '$psqlpass';"
    echo "Creating database $psqldb with owner kemal"
    sudo -u postgres psql -c "CREATE DATABASE $psqldb WITH OWNER kemal;"
    echo "Grant all on database $psqldb to user $psqluser"
    sudo -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO $psqluser;"
    echo "Grant all on database $psqldb to user $USER_NAME"
    sudo -u postgres psql -c "GRANT ALL ON DATABASE $psqldb TO $USER_NAME;"
    # Import db files
    echo "Running channels.sql"
    sudo -u $USER_NAME psql -d $psqldb -f $USER_DIR/invidious/config/sql/channels.sql
    echo "Running videos.sql"
    sudo -u $USER_NAME psql -d $psqldb -f $USER_DIR/invidious/config/sql/videos.sql
    echo "Running channel_videos.sql"
    sudo -u $USER_NAME psql -d $psqldb -f $USER_DIR/invidious/config/sql/channel_videos.sql
    echo "Running users.sql"
    sudo -u $USER_NAME psql -d $psqldb -f $USER_DIR/invidious/config/sql/users.sql
    echo "Running session_ids.sql"
    sudo -u $USER_NAME psql -d $psqldb -f $USER_DIR/invidious/config/sql/session_ids.sql
    echo "Running nonces.sql"
    sudo -u $USER_NAME psql -d $psqldb -f $USER_DIR/invidious/config/sql/nonces.sql
    echo "Finished Database section"
    ######################
    # Update config.yml with new info from user input
    ######################
    # Lets change the default user
    OLDUSER="user: kemal"
    NEWUSER="user: $psqluser"
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
    BPATH="$USER_DIR/backup/invidious"
    TFILE="/tmp/config.yml"
    [ ! -d $BPATH ] && mkdir -p $BPATH || :
    for f in $DPATH
    do
      if [ -f $f -a -r $f ]; then
        /bin/cp -f $f $BPATH
        echo -e "${GREEN}Updating config.yml with new info...${NC}"
        sed "s/$OLDUSER/$NEWUSER/g; s/$OLDPASS/$NEWPASS/g; s/$OLDDBNAME/$NEWDBNAME/g; s/$OLDDOMAIN/$NEWDOMAIN/g; s/$OLDHTTPS/$NEWHTTPS/g" "$f" > $TFILE &&
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
    shards
    crystal build src/invidious.cr --release
    chown -R $USER_NAME:$USER_NAME $USER_DIR/invidious
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
      sudo systemctl status invidious
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
      sleep 3
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
    read -p "Are you sure you want to run Database Maintenance the PostgreSQL database? " answer
    echo "You entered: $answer"
    # Here's where the user is going to enter the Invidious database name, as it appears in the GUI:
    read -p "Enter database name of your Invidious PostgreSQL database: " psqldb
    # Let's allow the user to confirm that what they've typed in is correct:
    echo "You entered: $psqldb"
    read -p "Is that correct? Enter y or n: " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    if [[ "$answer" = 'y' ]]; then
      if ( systemctl -q is-active postgresql.service)
      then
        echo -e "${RED}stopping Invidious..."
        sudo systemctl stop invidious
        echo "Running Maintenance on $psqldb"
        sudo -u invidious psql $psqldb -c "DELETE FROM nonces * WHERE expire < current_timestamp;"
        sudo -u invidious psql $psqldb -c "TRUNCATE TABLE videos;"
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
        # Restart postgresql
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
    show_maintenance_banner () {
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
      echo "Invidious maintenance done. Now visit http://localhost:3000"
      echo ""
      echo -e "Documentation for this script is available here: ${ORANGE}\n https://github.com/tmiland/Invidious-Updater${NC}\n"
    }
    show_maintenance_banner
    sleep 5
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
        cd $USER_DIR/invidious
        for script in ./config/migrate-scripts/*.sh
        do
          sudo -u $USER_NAME bash "$script"
        done
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
  7) # Exit
    echo -e "${ORANGE}In 3..2..1...${NC}"
    sleep 3
    echo -e "${ORANGE}Goodbye.${NC}"
    exit
    ;;

esac
