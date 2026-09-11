# Invidious-Updater (And Installer)

[![GitHub release](https://img.shields.io/github/release/tmiland/Invidious-Updater.svg?style=for-the-badge)](https://github.com/tmiland/Invidious-Updater/releases) [![licence](https://img.shields.io/github/license/tmiland/Invidious-Updater.svg?style=for-the-badge)](https://tmiland.github.io/invidious-updater/LICENSE) ![Bash](https://img.shields.io/badge/Language-SH-4EAA25.svg?style=for-the-badge)


**Full write-up on the blog:** https://tmiland.com/invidious-updater/
## Script to install and update [Invidious](https://github.com/iv-org/invidious)

```bash
1) Install Invidious          6) Start, Stop or Restart
2) Update Invidious           7) Uninstall Invidious
3) Deploy with Docker         8) Set up PostgreSQL Backup
4) Add Swap Space             9) Install Nginx
5) Run Database Maintenance  10) Install Invidious Companion
                             11) Exit"
```

## Usage
```bash
Usage:  invidious_update.sh [options]

  If called without arguments, installs Invidious.

  --help                   |-h      Display this help and exit
  --install-invidious      |-i      Install Invidious
  --cron-update            |-c      Update Invidious with cron
  --database-maintenance   |-m      Database Maintenance
  --install-log            |-l      Activate logging
  --install-inv-companion  |-iic    Install Invidious Companion
```
### Installation
To install Invidious:
***Note: you will be prompted to enter root password***

If root password is not set, type:

```bash
sudo passwd root
```
Log in as root
```bash
su root
```
- Latest release
  ```bash
  curl -sSL https://github.com/tmiland/Invidious-Updater/releases/latest/download/invidious_update.sh > invidious_update.sh && \
  chmod +x invidious_update.sh && \
  ./invidious_update.sh -i
  ```
- Master
  ```bash
  curl -sSL https://tmiland.github.io/invidious-updater/invidious_update.sh > invidious_update.sh && \
  chmod +x invidious_update.sh && \
  ./invidious_update.sh -i
  ```

[Invidious-Installer](https://github.com/tmiland/invidious-installer) is sourced in the install option.

To install this script:
See [Install.md](./INSTALL.md)

![invidious_update](https://tmiland.github.io/invidious-updater/img/invidious_update.gif)

### Tested on

| Debian | Ubuntu |
| ------ | ------ |
| [<img src="https://tmiland.github.io/invidious-updater/img/Debian_12.png" height="140" width="280">](https://tmiland.github.io/invidious-updater/img/Debian_12.png) | [<img src="https://tmiland.github.io/invidious-updater/img/Ubuntu_24.png" height="140" width="280">](https://tmiland.github.io/invidious-updater/img/Ubuntu_24.png)

| Fedora | Arch |
| ------ | ------ |
| [<img src="https://tmiland.github.io/invidious-updater/img/Fedora_40.png" height="140" width="280">](https://tmiland.github.io/invidious-updater/img/Fedora_40.png) | [<img src="https://tmiland.github.io/invidious-updater/img/Arch.png" height="140" width="280">](https://tmiland.github.io/invidious-updater/img/Arch.png)

| Linux Mint | PureOS |
| ------ | ------ |
| [<img src="https://tmiland.github.io/invidious-updater/img/Mint_22.png" height="140" width="280">](https://tmiland.github.io/invidious-updater/img/Mint_22.png) | [<img src="https://tmiland.github.io/invidious-updater/img/PureOS.png" height="140" width="280">](https://tmiland.github.io/invidious-updater/img/PureOS.png)

## Recommendation

***It is recommended to use this script on a fresh installation to avoid unwanted complications.***

## Testing

Tested and working on Debian 12, Ubuntu 24, Linux Mint 22, Fedora 40,
Arch Linux and PureOS (see [Install.md](./INSTALL.md) for the APT repo +
cron setup). Docker deploy tested on Debian, Fedora, Arch and Mint —
see [#15](https://github.com/tmiland/Invidious-Updater/issues/15).

#### SELinux will be set to permissive on Fedora

Postgresql will be default from repo on Fedora.

## Changelog

See [Changelog](https://tmiland.github.io/invidious-updater/CHANGELOG.md)

## Compatibility and Requirements

- Debian 11 and later
- Ubuntu 22.04 and later
- Linux Mint 21 and later
- PureOS
- Fedora 40 and later
  - Docker support
    - [OS requirements](https://docs.docker.com/install/linux/docker-ce/fedora/)
- Arch Linux

Unattended installs can pre-seed answers via environment variables
(`DOMAIN`, `IP`, `PORT`, `PSQLDB`, `PSQLPASS`, `HTTPS_ONLY`,
`EXTERNAL_PORT`, `ADMINS`, `SWAP_OPTIONS`) — see the CI workflow for an
example. Docker deploys use the production `docker-compose.yml` in this
repo (independent from upstream's dev-only compose file); Invidious
Companion is included. Automated updates via cron are documented in
[Install.md](./INSTALL.md).

## Credits
- Code is mixed and customized from these sources:
  - [Invidious](https://github.com/iv-org/invidious)
  - [Invidious companion](https://github.com/iv-org/invidious-companion)
  - [nginx-autoinstall](https://github.com/angristan/nginx-autoinstall)
  - [Git-Repo-Update](https://github.com/KillianKemps/Git-Repo-Update)
  - [ghacks user.js updater.sh](https://github.com/ghacksuserjs/ghacks-user.js/blob/master/updater.sh)
  - Plus many more.

## Feature request and bug reports
- [Bug report](https://github.com/tmiland/Invidious-Updater/issues/new?assignees=tmiland&labels=bug&template=bug_report.md&title=Bug-report:)
- [Feature request](https://github.com/tmiland/Invidious-Updater/issues/new?assignees=tmiland&labels=enhancement&template=feature_request.md&title=Feature-request:)

## Donations
<a href="https://coindrop.to/tmiland" target="_blank"><img src="https://coindrop.to/embed-button.png" style="border-radius: 10px; height: 57px !important;width: 229px !important;" alt="Coindrop.to me"></img></a>

#### Disclaimer 

*** ***Use at own risk*** ***

### License

[![MIT License Image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/MIT_logo.svg/220px-MIT_logo.svg.png)](https://tmiland.github.io/invidious-updater/LICENSE)

[MIT License](https://tmiland.github.io/invidious-updater/LICENSE)
