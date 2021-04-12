# Invidious-Updater (And Installer)

```
                  ╔═══════════════════════════════════════════════════════════════════╗
                  ║                        Invidious Update.sh                        ║
                  ║               Automatic update script for Invidious               ║
                  ║                      Maintained by @tmiland                       ║
                  ╚═══════════════════════════════════════════════════════════════════╝
```
[![GitHub release](https://img.shields.io/github/release/tmiland/Invidious-Updater.svg?style=for-the-badge)](https://github.com/tmiland/Invidious-Updater/releases)
[![licence](https://img.shields.io/github/license/tmiland/Invidious-Updater.svg?style=for-the-badge)](https://github.com/tmiland/Invidious-Updater/blob/master/LICENSE)
![Bash](https://img.shields.io/badge/Language-SH-4EAA25.svg?style=for-the-badge)

## Script to install and update [Invidious](https://github.com/iv-org/invidious)

```
1) Install Invidious          6) Start, Stop or Restart   
2) Update Invidious           7) Uninstall Invidious      
3) Deploy with Docker         8) Set up PostgreSQL Backup 
4) Add Swap Space             9) Install Nginx            
5) Run Database Maintenance  10) Exit                     
```

## Screenshots
![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/version_1.4.9.png)

| Debian | Ubuntu |
| ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Debian.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Debian.png) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Ubuntu.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Ubuntu.png) 

| CentOS | Fedora |
| ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/CentOS.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/CentOS.png) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Fedora.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Fedora.png)

| Arch | PureOS |
| ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Arch.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Arch.png) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/PureOS.png" height="140" width="280">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/PureOS.png)

## Recommendation

***It is recommended to use this script on a fresh installation to avoid unwanted complications.***
  * I recommend a Debian 10 Droplet on [DigitalOcean](https://m.do.co/c/f1f2b475fca0)

## Installation

#### Download and execute the script:

For latest release

```bash
curl -s https://api.github.com/repos/tmiland/Invidious-Updater/releases/latest \
| grep "browser_download_url.*sh" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
```

```bash
$ chmod +x invidious_update.sh
$ ./invidious_update.sh
```
Or directly

```bash
$ curl -sSL https://github.com/tmiland/Invidious-Updater/releases/latest/download/invidious_update.sh | bash
```

For master branch
```bash
$ wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
$ chmod +x invidious_update.sh
$ ./invidious_update.sh
```
### Repository

 ```shell
 $ sudo curl -SsL -o /etc/apt/sources.list.d/tmiland.list https://deb.tmiland.com/debian/tmiland.list
 ```

 ```shell
 $ curl -SsL https://deb.tmiland.com/debian/KEY.gpg | sudo apt-key add -
 ```

 ```shell
 $ sudo apt update
 ```
 
 ```shell
 $ sudo apt install invidious-updater
 ```
 
- Run script with ```invidious_update ```
 
- ***Only for Debian/Ubuntu/LinuxMint/PureOS***

#### Check for script update (Default "no")

 ```bash
 
 $ ./invidious_update.sh -u
 
 ```
 
 #### Update Invidious via Cron

**Select option 2 once to manually set GitHub Credentials**

```bash

$ /path/to/script/invidious_update.sh -c

```
Add job to cron:
```bash
$ crontab -e
```
```bash
@daily bash /path/to/script/invidious_update.sh -c > /dev/null 2>&1 # Automated Invidious Update
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

  ***Note: GitHub Credentials needs to be provided to keep the update from failing***
  (Credentials are stored in /root/.gitconfig)
  **This is required to stash & checkout a new branch which was implemented to prevent "Detached HEAD state".**
   
   * Invidious is ready to be updated, press any key to continue...



3. Deploy Invidious with Docker

   * 1) Build and start cluster
   * 2) Start, Stop or Restart cluster
   * 3) Rebuild cluster
   * 4) Delete data and rebuild
   * 5) Install Docker CE
   * 6) Run database maintenance

4. Add Swap Space

   * Easy option to add Swap Space from [external script](https://github.com/tmiland/swap-add/blob/master/swap-add.sh)
    Credit: [swap-add](https://github.com/nanqinlang-script/swap-add)

5. Run database maintenance

   * Database maintenance option [Database Information and Maintenance](https://github.com/omarroth/invidious/wiki/Database-Information-and-Maintenance)

   ***Also works with argument -m***

   ```bash
   $ /path/to/script/invidious_update.sh -m
   ```


6. Start, Stop or Restart Invidious

7. Uninstall Invidious

[![asciicast](https://asciinema.org/a/NexOg7FcaGVMLZ2iZwwiT4luo.svg)](https://asciinema.org/a/NexOg7FcaGVMLZ2iZwwiT4luo?t=5)

8. Set up PostgreSQL Backup
  
   * Set up [pgbackup - Automated PostgreSQL Backup on Linux](https://github.com/tmiland/pgbackup)

9. Install Nginx

10. Exit

   * Exits the script

   ![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/exit.png)
   
## Testing

Tested and working on:

| Debian | Ubuntu | CentOS | Fedora | Arch | PureOS |
| ------ | ------ | ------ | ------ | ------ | ------ |
| [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/debian.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/debian.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/ubuntu.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/ubuntu.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/cent-os.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/cent-os.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/fedora.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/fedora.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/arch.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/arch.svg?sanitize=true) | [<img src="https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/pureos.svg?sanitize=true" height="128" width="128">](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/os_icons/pureos.svg?sanitize=true)

- [X] Tested extensively on Debian 9/10
  - [X] Docker option tested and working
- [X] Tested on Ubuntu 16.04
  - [X] Docker option tested, not working
- [X] Tested on Ubuntu 18.10
  - [X] Docker option tested and working
- [X] Tested on CentOS 8
  - [ ] Docker option tested and working
- [X] Tested on Fedora 33
  - [ ] Docker option tested and working
- [X] On Bash on Debian on Windows (in Gnome-Boxes)
  - [X] Systemd not working
  - [X] Docker option not working
- [X] Tested on Linux Mint.
  - See [#15](https://github.com/tmiland/Invidious-Updater/issues/15)
- [X] Tested on Arch Linux
  - [X] Docker option tested and working
  
  ~~If you get permission issues, set selinux to permissive. 
  See how to here: [How do I enable or disable SELinux ?](https://fedoraproject.org/wiki/SELinux_FAQ#How_do_I_enable_or_disable_SELinux_.3F)~~
  #### SELinux will be set to permissive on Fedora 33 and CentOS 8

  ~~***Postgresql 11 will be installed by default in both Fedora and CentOS. (If not already installed)***~~
  Postgresql will be default from repo on Fedora 33 and CentOS 8
  
#### Latest install log - version: 1.4.4

[install log Debian 10](https://github.com/tmiland/Invidious-Updater/blob/master/log/install_log_debian.log)

## Changelog

See [Changelog](https://github.com/tmiland/Invidious-Updater/blob/master/CHANGELOG.md)

## Compatibility and Requirements

* Debian 8 and later
* Ubuntu 16.04 and later
* PureOS (Not tested)
* CentOS 8
* Fedora 33
  * Docker support
    - [OS requirements](https://docs.docker.com/install/linux/docker-ce/fedora/)
* Arch Linux

## Credits
- Code is mixed and customized from these sources:
  * [Invidious](https://github.com/omarroth/invidious#linux)
  * [nginx-autoinstall](https://github.com/angristan/nginx-autoinstall)
  * [Git-Repo-Update](https://github.com/KillianKemps/Git-Repo-Update)
  * [ghacks user.js updater.sh](https://github.com/ghacksuserjs/ghacks-user.js/blob/master/updater.sh)
  * Plus many more.

## Feature request and bug reports
- [Bug report](https://github.com/tmiland/Invidious-Updater/issues/new?assignees=tmiland&labels=bug&template=bug_report.md&title=Bug-report:)
- [Feature request](https://github.com/tmiland/Invidious-Updater/issues/new?assignees=tmiland&labels=enhancement&template=feature_request.md&title=Feature-request:)
- [IRC Freenode: #InvidiousUpdater](irc://freenode.net/#InvidiousUpdater)

## Donations 
- [PayPal me](https://paypal.me/milanddata)
- [BTC] : 33mjmoPxqfXnWNsvy8gvMZrrcG3gEa3YDM

## Web Hosting

Sign up for web hosting using this link, and receive $100 in credit over 60 days.

[DigitalOcean](https://m.do.co/c/f1f2b475fca0)

#### Disclaimer 

*** ***Use at own risk*** ***

### License

[![MIT License Image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MIT_logo.svg/220px-MIT_logo.svg.png)](https://github.com/tmiland/Invidious-Updater/blob/master/LICENSE)

[MIT License](https://github.com/tmiland/Invidious-Updater/blob/master/LICENSE)
