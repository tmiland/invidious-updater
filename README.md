# Invidious-Updater

## Script to update [Invidious](https://github.com/omarroth/invidious) git repository


* Automatically update git repo, rebuild and restart service

## Installation

download and execute the script :
```bash
cd /path/to/invidious/repo
wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
chmod +x invidious_update.sh
./invidious_update.sh
```

## Usage
* -f FORCE YES (Force yes, update, rebuild and restart Invidious)
* -p Prune remote. (Deletes all stale remote-tracking branches)
* -l Latest release. (Fetch latest release from remote repo.)

## Compatibility
* x86, x64, arm*
* Debian 8 and later
* Ubuntu 16.04 and later
