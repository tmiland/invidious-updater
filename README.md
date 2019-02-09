# Invidious-Updater

## Script to update [Invidious](https://github.com/omarroth/invidious) git repository

* Automatically update git repo, rebuild and restart service

## Screenshot
![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20at%2016-18-02.png)

## Installation

download and execute the script :
```bash
cd /home/invidious
wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
chmod +x invidious_update.sh
./invidious_update.sh
```

## Usage
1. Update Invidious
  * ###### No arguments (Default) Will use branch "Master" and prompt user for each step.
  * ###### -f FORCE YES (Force yes, update, rebuild and restart Invidious)
  * ###### -p Prune remote. (Deletes all stale remote-tracking branches)
  * ###### -l Latest release. (Fetch latest release from remote repo.)
2. Update the Script
  * ###### Downloads and executes the script from this repo.
3. Exit
  * ###### Exits the script

## Compatibility
* x86, x64, arm*
* Debian 8 and later
* Ubuntu 16.04 and later

## Requirements
* [Invidious](https://github.com/omarroth/invidious#linux)
