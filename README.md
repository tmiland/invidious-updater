# Invidious-Updater (And Installer)

```
                  ╔═══════════════════════════════════════════════════════════════════╗
                  ║                        Invidious Update.sh                        ║
                  ║               Automatic update script for Invidio.us              ║
                  ║                      Maintained by @tmiland                       ║
                  ║                          version: 1.4.4                           ║
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

## Recommendation

***It is recommended to use this script on a fresh installation to avoid unwanted complications.***
  * I recommend a Debian 10 Droplet on [DigitalOcean](https://m.do.co/c/f1f2b475fca0)

## Installation

#### Download and execute the script:

For latest release
```bash
$ wget https://github.com/tmiland/Invidious-Updater/releases/download/v1.4.4/invidious_update.sh
$ chmod +x invidious_update.sh
$ ./invidious_update.sh
```

For master branch
```bash
$ wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
$ chmod +x invidious_update.sh
$ ./invidious_update.sh
```

#### Check for script update (Default "no")

 ```bash
 
 $ ./invidious_update.sh -u
 
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

- [X] Tested extensively on Debian 9/10
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
  
#### Latest install log - version: 1.4.4

[install log Debian 10](https://github.com/tmiland/Invidious-Updater/blob/master/log/install_log_debian.log)

## Todo

On the todo list:

- [X] Nothing to do.

## Changelog

See [Changelog](https://github.com/tmiland/Invidious-Updater/blob/master/CHANGELOG.md)

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
