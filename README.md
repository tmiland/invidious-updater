# Invidious-Updater (And Installer)

## Script to install and update [Invidious](https://github.com/omarroth/invidious)

* Install invidious
* Update git repo, rebuild and restart service
* Update the Script
* Install Invidious service for Systemd
* Run database maintenance
* Run database migration


## Screenshot
![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20at%2023-12-03.png)

## Installation

download and execute the script :
```bash
wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh \
chmod +x invidious_update.sh \
su \
./invidious_update.sh
```

## Usage

1. Install invidious
   * Add invidious user and clone repository [y/n]
   * Setup PostgresSQL [y/n]
   * Setup Invidious [y/n]
   * Setup Systemd Service [y/n]

2. Update Invidious
  * No arguments (Default) Will use branch "Master" and prompt user for each step.
  * -f FORCE YES (Force yes, update, rebuild and restart Invidious)
  * -p Prune remote. (Deletes all stale remote-tracking branches)
  * -l Latest release. (Fetch latest release from remote repo.)

3. Update the Script
  * Downloads and executes the script from this repo with the latest version.

4. Install Invidious service for Systemd
  * Setup Systemd Service

5. Exit
  * Exits the script

## Testing
- [x] Tested extensively on Debian 9

## Issues

- Captcha is not working, issue with [imagemagick](https://github.com/omarroth/invidious/wiki/Issues-with-Captcha-on-Debian-and-Ubuntu)

## Todo
- [ ] Rewrite the update procedure
- [ ] Add Uninstallation option
- [ ] Add database migration option [migrate-scripts](https://github.com/omarroth/invidious/tree/master/config/migrate-scripts)
- [ ] Add database maintenance option [Database Information and Maintenance](https://github.com/omarroth/invidious/wiki/Database-Information-and-Maintenance)
- [ ] Add option to compile imagemagick from source [Issues with Captcha on Debian and Ubuntu](https://github.com/omarroth/invidious/wiki/Issues-with-Captcha-on-Debian-and-Ubuntu)

## Compatibility and Requirements
* Debian 8 and later
* Ubuntu 16.04 and later

## Credits
- Code is mixed and and customized from these sources:
  * [Invidious](https://github.com/omarroth/invidious#linux)
  * [nginx-autoinstall](https://github.com/angristan/nginx-autoinstall)
  * [Git-Repo-Update](https://github.com/KillianKemps/Git-Repo-Update)
  * [ghacks user.js updater.sh](https://github.com/ghacksuserjs/ghacks-user.js/blob/master/updater.sh)

## Feedback
- [create an issue](https://github.com/tmiland/Invidious-Updater/issues/new)
