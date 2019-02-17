# Invidious-Updater (And Installer)

```
                  ######################################################################
                  ####                    Invidious Update.sh                       ####
                  ####            Automatic update script for Invidio.us            ####
                  ####                   Maintained by @tmiland                     ####
                  ####                       version: 1.2.2                         ####
                  ######################################################################
```

## Script to install and update [Invidious](https://github.com/omarroth/invidious)

* Install invidious
* Update git repo, rebuild and restart service
* Update the Script
* Install Invidious service
* Run database maintenance
* Run database migration
* Uninstall Invidious


## Screenshot
![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20at%2006-24-51.png)

## Installation

#### download and execute the script :
```bash
$ wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
$ chmod +x invidious_update.sh
$ su
$ ./invidious_update.sh
```
#### Or : 
 ```bash
$ cd /home/invidious
$ git clone https://github.com/tmiland/Invidious-Updater.git
$ cd Invidious-Updater
$ chmod +x invidious_update.sh
$ su
$ ./invidious_update.sh
```
#### Optionally
 ```bash
$ ln -s /home/invidious/Invidious-Updater/invidious_update.sh /usr/bin/invidious_update
$ invidious_update
```
## Usage

1. ### Install invidious
   
   * Select an option [1-8]: 1

   * Let's go through some configuration options.
   
   * "Do you want to install Invidious release or master?"
      *  1) release
      *  2) master

   * Select database name: invidious
   * Select database password: invidious
   * Enter the desired domain name: localhost
   * Are you going to use https only? [true/false]: false
     * You entered: 
     * branch: release/master
     * domain: localhost
     * https only: false
     * name: invidious
     * password: invidious

   * Choose your Imagemagick version :
     * 1) System's Imagemagick
       * (Currently installed version)
     * 2) Imagemagick 6 from source
     * 3) Imagemagick 7 from source


   * Invidious is ready to be installed, press any key to continue...

2. ### Update Invidious
   * Let's go through some configuration options.

   * Do you want to checkout Invidious release or master?
     * 1) release
     * 2) master
   * Select an option [1-2]: 1
   * You entered: 
     * branch: release
   * Invidious is ready to be updated, press any key to continue...

3. ### Update the Script
   * Downloads and executes the script from this repo with the latest version.

4. ### Install Invidious service
   * Setup Systemd Service

5. ### Run database maintenance
   * Database maintenance option [Database Information and Maintenance](https://github.com/omarroth/invidious/wiki/Database-Information-and-Maintenance)

6. ### Run database migration
   * Database migration option [migrate-scripts](https://github.com/omarroth/invidious/tree/master/config/migrate-scripts)

7. ### Uninstall Invidious
      * Uninstallation of Invidious, and everything installed during setup.
        * Remove PostgreSQL database for Invidious ? [y/n]
          * Enter Invidious PostgreSQL database name: invidious
          * Backup will be placed in /home/backup
        * Remove Packages ? [y/n]
        * Purge Package configuration files ? [y/n]
        * Remove files ? [y/n]: <-- ***This is required for reinstalling.***
        * Remove user ? [y/n]: <-- ***This is not required for reinstalling.***
        * Is that correct? [y/n]:
      * Invidious is ready to be uninstalled, press any key to continue...

8. ### Exit
   * Exits the script

## Testing
- [x] Tested extensively on Debian 9
- [x] Tested on Ubuntu 16.04

#### Latest install log - version: 1.1.6

[install log Debian 9](https://github.com/tmiland/Invidious-Updater/blob/master/log/install_log_debian.log)


## Issues

- None (hopefully) ;)

## Todo

- [ ] Add Imagemagick (source) to Uninstall options
- [ ] Add support to deploy in Docker

## Done

- [X] Add Uninstallation option 
  - Added in version 1.1.4
- [X] Rework the install prompts
    - Done in version 1.1.5
- [X] Add database migration option [migrate-scripts](https://github.com/omarroth/invidious/tree/master/config/migrate-scripts)
- [X] Add database maintenance option [Database Information and Maintenance](https://github.com/omarroth/invidious/wiki/Database-Information-and-Maintenance)
- [X] Add option to compile imagemagick from source [Issues with Captcha on Debian and Ubuntu](https://github.com/omarroth/invidious/wiki/Issues-with-Captcha-on-Debian-and-Ubuntu)
   - Added in version 1.1.6
   - Added support for Imagemagick 6 and 7, or keep current version.
   - The captcha clock is working with 6 and 7, not with default pkg.
- [X] Add Deb Packages

- Support for auto-update check
  - [X] For Script - Added in 1.1.7
  
- [X] Rewrite the update procedure - Done in 1.2.2

### Possible options
- Support for auto-update check
  - [ ] For Invidious

- [ ] Support for running own forks
- [ ] Support for database backup

## Compatibility and Requirements
* Debian 8 and later
* Ubuntu 16.04 and later

## Credits
- Code is mixed and and customized from these sources:
  * [Invidious](https://github.com/omarroth/invidious#linux)
  * [nginx-autoinstall](https://github.com/angristan/nginx-autoinstall)
  * [Git-Repo-Update](https://github.com/KillianKemps/Git-Repo-Update)
  * [ghacks user.js updater.sh](https://github.com/ghacksuserjs/ghacks-user.js/blob/master/updater.sh)

## Feedback and bug reports
- [create an issue](https://github.com/tmiland/Invidious-Updater/issues/new)

## Donations 
- [PayPal me](https://paypal.me/milanddata)
