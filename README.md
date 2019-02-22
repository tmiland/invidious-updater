# Invidious-Updater (And Installer)

```
                  ╔═══════════════════════════════════════════════════════════════════╗
                  ║                        Invidious Update.sh                        ║
                  ║               Automatic update script for Invidio.us              ║
                  ║                      Maintained by @tmiland                       ║
                  ║                          version: 1.2.5                           ║
                  ╚═══════════════════════════════════════════════════════════════════╝
```

## Script to install and update [Invidious](https://github.com/omarroth/invidious)

* Install Invidious
* Update Invidious
* Deploy Invidious with Docker
* Install Invidious service
* Run database maintenance
* Run database migration
* Uninstall Invidious


## Screenshots
![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20at%2018-10-05.png)

| Debian | CentOS |
| ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20from%202019-02-20%2017-14-20.png" height="180" width="320">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20from%202019-02-20%2017-14-20.png) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20from%202019-02-20%2017-09-25.png" height="180" width="320">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20from%202019-02-20%2017-09-25.png) |

(click to expand)

## Installation

<details><summary>Download and execute the script:</summary><p>

```bash
$ wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
$ chmod +x invidious_update.sh
$ su -
## OR ##
$ sudo -i
$ ./invidious_update.sh
```
#### Or : 
 ```bash
$ cd /home/invidious
$ git clone https://github.com/tmiland/Invidious-Updater.git
$ cd Invidious-Updater
$ chmod +x invidious_update.sh
$ su -
## OR ##
$ sudo -i
$ ./invidious_update.sh
```
#### Optionally
 ```bash
$ ln -s /home/invidious/Invidious-Updater/invidious_update.sh /usr/bin/invidious-updater
$ invidious-updater
```

</p></details>

## Usage
<details><summary>1. Install invidious</summary><p>
   
   * Select an option [1-8]: 1

   * Let's go through some configuration options.
   
   * Do you want to install Invidious release or master?
     * 1) release
     * 2) master

   Select an option [1-2]: 2
   * Do you want to enter advanced options? [y/n]: y
   * (Selecting "no" will load default values)
     * Enter the desired domain name:invidio.us
     * Enter the desired ip adress:10.0.2.15
     * Enter the desired port number:3003
     * Select database name:invidious
     * Select database password:invidious123
     * Are you going to use https only? [y/n]: n
   * You entered: 

      * branch     : master
      * domain     : invidio.us
      * ip adress  : 10.0.2.15
      * port       : 3003
      * dbname     : invidious
      * dbpass     : invidious123
      * https only : false

   * Choose your Imagemagick version :
     * 1) System's Imagemagick
       * (Currently installed version)
     * 2) Imagemagick 6 from source
     * 3) Imagemagick 7 from source


   * Invidious is ready to be installed, press any key to continue...
</p></details>

<details><summary>2. Update Invidious</summary><p>

   * Let's go through some configuration options.

   * Do you want to checkout Invidious release or master?
     * 1) release
     * 2) master
   * Select an option [1-2]: 1
   * You entered: 
     * branch: release
   * Invidious is ready to be updated, press any key to continue...

</p></details>

<details><summary>3. Deploy Invidious with Docker</summary><p>

   * 1) Build and start cluster
   * 2) Start, Stop or Restart cluster
   * 3) Rebuild cluster
   * 4) Delete data and rebuild
   * 5) Install Docker CE

</p></details>

<details><summary>4. Install Invidious service</summary><p>

   * Setup Systemd Service

</p></details>

<details><summary>5. Run database maintenance</summary><p>

   * Database maintenance option [Database Information and Maintenance](https://github.com/omarroth/invidious/wiki/Database-Information-and-Maintenance)

</p></details>

<details><summary>6. Run database migration</summary><p>

   * Database migration option [migrate-scripts](https://github.com/omarroth/invidious/tree/master/config/migrate-scripts)

</p></details>

<details><summary>7. Uninstall Invidious</summary><p>

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

</p></details>

<details><summary>8. Exit</summary><p>

   * Exits the script
   
   </p></details>

## Testing

<details><summary>Tested on:</summary><p>

- [X] Tested extensively on Debian 9
  - [X] Docker option tested and working
- [X] Tested on Ubuntu 16.04
  - [X] Docker option tested, not working
- [ ] Tested on Ubuntu 18.04
- [X] Tested on CentOS 7
  - [X] Docker option tested and working
- [X] Tested on Fedora 29
  - [X] Docker option tested and working
  
#### Latest install log - version: 1.1.6

[install log Debian 9](https://github.com/tmiland/Invidious-Updater/blob/master/log/install_log_debian.log)

</p></details>

## Todo

<details><summary>On the todo list:</summary><p>

- [ ] Add Imagemagick (source) to Uninstall options

</p></details>

## Done

<details><summary>What's done:</summary><p>

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
  - [X] For Script 
  - Added in 1.1.7
- [X] Rewrite the update procedure 
  - Done in 1.2.2
- [X] Add support to deploy in Docker 
  - Added in Added in [1.2.3](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.3)
- [X] Added support for CentOS 7 
  - Added in [1.2.4](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.4) (Docker option not supported yet)
- [X] Add option for custom IP and Port 
  - Added in [1.2.5](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.5)
- [X] Add Docker support for CentOS 
  - Added in [1.2.5](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.5)
- [X] Add support for Fedora 
  - Added in [1.2.6](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.6)

  </p></details>

### Possible options

<details><summary>Ideas:</summary><p>

- Support for auto-update check
  - [ ] For Invidious

- [ ] Support for running own forks
- [ ] Support for database backup

</p></details>

## Compatibility and Requirements

* Debian 8 and later
* Ubuntu 16.04 and later
* CentOS 7
  * Requirements: `yum install redhat-lsb` 
* Fedora 29
  * Requirements: `dnf install redhat-lsb`
  * Docker support
    - [OS requirements](https://docs.docker.com/install/linux/docker-ce/fedora/)

## Credits
- Code is mixed and and customized from these sources:
  * [Invidious](https://github.com/omarroth/invidious#linux)
  * [nginx-autoinstall](https://github.com/angristan/nginx-autoinstall)
  * [Git-Repo-Update](https://github.com/KillianKemps/Git-Repo-Update)
  * [ghacks user.js updater.sh](https://github.com/ghacksuserjs/ghacks-user.js/blob/master/updater.sh)

## Feature request and bug reports
- [Bug report](https://github.com/tmiland/Invidious-Updater/issues/new?assignees=tmiland&labels=bug&template=bug_report.md&title=Bug-report:)
- [Feature request](https://github.com/tmiland/Invidious-Updater/issues/new?assignees=tmiland&labels=enhancement&template=feature_request.md&title=Feature-request:)

## Donations 
- [PayPal me](https://paypal.me/milanddata)
- [BTC] : 3MV69DmhzCqwUnbryeHrKDQxBaM724iJC2
- [BCH] : qznnyvpxym7a8he2ps9m6l44s373fecfnv86h2vwq2
