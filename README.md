# Invidious-Updater (And Installer)

```
                  ╔═══════════════════════════════════════════════════════════════════╗
                  ║                        Invidious Update.sh                        ║
                  ║               Automatic update script for Invidio.us              ║
                  ║                      Maintained by @tmiland                       ║
                  ║                          version: 1.3.7                           ║
                  ╚═══════════════════════════════════════════════════════════════════╝
```
[![GitHub release](https://img.shields.io/github/release/tmiland/Invidious-Updater.svg?style=for-the-badge)](https://github.com/tmiland/Invidious-Updater/releases)
[![licence](https://img.shields.io/github/license/tmiland/Invidious-Updater.svg?style=for-the-badge)](https://github.com/tmiland/Invidious-Updater/blob/master/LICENSE)
![Bash](https://img.shields.io/badge/Language-SH-4EAA25.svg?style=for-the-badge)

## Script to install and update [Invidious](https://github.com/omarroth/invidious)

* Install Invidious
* Update Invidious
* Deploy Invidious with Docker
* Install Invidious service
* Run database maintenance
* Start, Stop or Restart Invidious
* Uninstall Invidious

## Screenshots
![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/version_1.2.9.png)

| Debian | Ubuntu |
| ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Debian.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Debian.png) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Ubuntu.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Ubuntu.png) 

| CentOS | Fedora |
| ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/CentOS.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/CentOS.png) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Fedora.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Fedora.png)

## Installation

#### Download and execute the script:

```bash
$ wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
$ chmod +x invidious_update.sh
$ ./invidious_update.sh
```
#### Or :

 ```bash
$ cd /home/invidious
$ git clone https://github.com/tmiland/Invidious-Updater.git
$ cd Invidious-Updater
$ chmod +x invidious_update.sh
$ ./invidious_update.sh
```

#### Optionally

 ```bash
$ ln -s /home/invidious/Invidious-Updater/invidious_update.sh /usr/bin/invidious-updater
$ invidious-updater
```

***Note: you will be prompted to enter root password***

If root password is not set, type:

```bash
sudo passwd root
```


## Usage

1. Install invidious

[![asciicast](https://asciinema.org/a/NdRo8mFKvNNFsVGp5QbzqRvtK.svg)](https://asciinema.org/a/NdRo8mFKvNNFsVGp5QbzqRvtK?t=5)


2. Update Invidious

   * Let's go through some configuration options.

   * Do you want to checkout Invidious release or master?
     * 1) release
     * 2) master
   * Select an option [1-2]: 1
   * You entered: 
     * branch: release
   * Invidious is ready to be updated, press any key to continue...



3. Deploy Invidious with Docker

   * 1) Build and start cluster
   * 2) Start, Stop or Restart cluster
   * 3) Rebuild cluster
   * 4) Delete data and rebuild
   * 5) Install Docker CE

4. Install Invidious service

   * Setup Systemd Service

5. Run database maintenance

   * Database maintenance option [Database Information and Maintenance](https://github.com/omarroth/invidious/wiki/Database-Information-and-Maintenance)


6. Start, Stop or Restart Invidious

7. Uninstall Invidious

[![asciicast](https://asciinema.org/a/NexOg7FcaGVMLZ2iZwwiT4luo.svg)](https://asciinema.org/a/NexOg7FcaGVMLZ2iZwwiT4luo?t=5)

8. Exit

   * Exits the script

   ![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/exit.png)
   
## Testing

Tested and working on:

| Debian | Ubuntu | CentOS | Fedora |
| ------ | ------ | ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/debian.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/debian.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/ubuntu.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/ubuntu.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/cent-os.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/cent-os.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/fedora.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/fedora.svg?sanitize=true)

- [X] Tested extensively on Debian 9
  - [X] Docker option tested and working
- [X] Tested on Ubuntu 16.04
  - [X] Docker option tested, not working
- [X] Tested on Ubuntu 18.10
  - [X] Docker option tested and working
- [X] Tested on CentOS 7
  - [X] Docker option tested and working
- [X] Tested on Fedora 29
  - [X] Docker option tested and working
- [X] On Bash on Debian on Windows (in Gnome-Boxes)
  - [X] Systemd not working
  - [X] Docker option not working
  
  If you get permission issues, set selinux to permissive. 
  See how to here: [Disable SELinux or Set it to Permissive mode in Fedora 28 / 29, RHEL or CentOS](https://www.kaizenuslife.com/disable-or-set-selinux-permissive-in-fedora-rhel-or-cent-os/)

  #### ***Postgresql 11 will be installed by default in both Fedora and CentOS.***
  
#### Latest install log - version: 1.2.7

[install log Debian 9](https://github.com/tmiland/Invidious-Updater/blob/master/log/install_log_debian.log)

## Todo

On the todo list:

- [ ] Add Imagemagick (source) to Uninstall options

## Done

What's done:

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
  - Added in [1.2.3](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.3)
- [X] Added support for CentOS 7 
  - Added in [1.2.4](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.4) (Docker option not supported yet)
- [X] Add option for custom IP and Port 
  - Added in [1.2.5](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.5)
- [X] Add Docker support for CentOS 
  - Added in [1.2.5](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.5)
- [X] Add support for Fedora 
  - Added in [1.2.6](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.6)
- [X] Added prompt to install redhat-lsb/lsb-release if not installed.
- [X] Added support for Ubuntu 18.10
  - Added in [1.2.7](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.7)
- [X] Changed script update function
  - Changed in [1.2.8](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.8)
- [X] Added service and docker status indicators
  - Added in [1.2.9](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.2.9)
- [X] Changed update procedure to avoid "Detached HEAD state"
  - Changed in [1.3.0](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.3.0)
- [X] Added external_port to config.yml [Configuration](https://github.com/omarroth/invidious/wiki/Configuration)
    - Changed update check on first run to exclude notes (since curl might not be installed)
    - external_port will be set to 443 if https_only = true, else < blank > (assuming use of reverse proxy with https.)
    - Set default domain to invidio.us since option now is blank in config. (blank domain doesn't work on local instance)
    - Created IRC Channel on Freenode.net/#InvidiousUpdater
    - Changed in [1.3.1](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.3.1)
- [X] Ignore config.yml on install and update.
    - Changed in [1.3.2](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.3.2)
- [X] Fix to move config out of the way on Ubuntu 16.04 (git ignored changes in 1.3.2)
- [X] Added config backup
    - Changed in [1.3.3](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.3.3)
- [X] Replaced migration with Start, Stop or Restart
    - Changed in [1.3.4](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.3.4)
- [X] Support for database backup
  - Added in [1.3.5](https://github.com/tmiland/Invidious-Updater/releases/tag/v1.3.5)

### Possible options

Ideas:

- Support for auto-update check
  - [ ] For Invidious

## Compatibility and Requirements

* Debian 8 and later
* Ubuntu 16.04 and later
* CentOS 7
* Fedora 29
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
- [IRC Freenode: #InvidiousUpdater](irc://freenode.net/#InvidiousUpdater)

## Donations 
- [PayPal me](https://paypal.me/milanddata)
- [BTC] : 3MV69DmhzCqwUnbryeHrKDQxBaM724iJC2
- [BCH] : qznnyvpxym7a8he2ps9m6l44s373fecfnv86h2vwq2

## Web Hosting

Sign up for web hosting using this link, and receive $100 in credit over 60 days.

[DigitalOcean](https://m.do.co/c/f1f2b475fca0)

#### Disclaimer 

*** ***Use at own risk*** ***

### License

[![MIT License Image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MIT_logo.svg/220px-MIT_logo.svg.png)](https://github.com/tmiland/Invidious-Updater/blob/master/LICENSE)

[MIT License](https://github.com/tmiland/Invidious-Updater/blob/master/LICENSE)
