# Invidious-Updater (And Installer)

```
                  ######################################################################
                  ####                    Invidious Update.sh                       ####
                  ####            Automatic update script for Invidio.us            ####
                  ####                   Maintained by @tmiland                     ####
                  ####                       version: 1.1.5                         ####
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
![screenshot](https://raw.githubusercontent.com/tmiland/Invidious-Updater/master/img/Screenshot%20at%2005-43-41.png)

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

   * Invidious is ready to be installed, press any key to continue...

2. ### Update Invidious (To be rewritten)
   * No arguments (Default) Will use branch "Master" and prompt user for each step.
   * -f FORCE YES (Force yes, update, rebuild and restart Invidious)
   * -p Prune remote. (Deletes all stale remote-tracking branches)
   * -l Latest release. (Fetch latest release from remote repo.)

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
        * Remove user and files ? [y/n]: <-- ***This is required for reinstalling.***
        * Is that correct? [y/n]:
      * Invidious is ready to be uninstalled, press any key to continue...

8. ### Exit
   * Exits the script

## Testing
- [x] Tested extensively on Debian 9

#### Latest install log - version: 1.1.4

<details><summary>*truncated* **click to view**</summary><p>


```text 
Select an option [1-8]: 1


 ######################################################################
 ####                    Invidious Update.sh                       ####
 ####            Automatic update script for Invidio.us            ####
 ####                   Maintained by @tmiland                     ####
 ####                        version: 1.1.4                        ####
 ######################################################################


Thank you for using the Invidious Update.sh script.

Let's go through some configuration options.

Documentation for this script is available here: 
 https://github.com/tmiland/Invidious-Updater

Enter the desired password of your Invidious PostgreSQL database: testing
Enter the desired database name of your Invidious PostgreSQL database: testing
You entered: password: testing name: testing
Is that correct? Enter y or n: y
Enter the desired domain name of your Invidious instance: localhost
Are you going to serve your Invidious instance on https only? Type true or false: false
You entered: Domain: localhost https only: false
Is that correct? Enter y or n: y

Invidious is ready to be installed, press any key to continue...

Ign:1 http://ftp.us.debian.org/debian stretch InRelease
Hit:2 http://ftp.us.debian.org/debian stretch Release
Reading package lists... Done
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  git-man libcurl3 liberror-perl rsync
Suggested packages:
  git-daemon-run | git-daemon-sysvinit git-doc git-el git-email git-gui gitk gitweb git-arch git-cvs
  git-mediawiki git-svn
The following NEW packages will be installed:
  apt-transport-https curl git git-man libcurl3 liberror-perl rsync sudo
0 upgraded, 8 newly installed, 0 to remove and 1 not upgraded.
Need to get 7,764 kB of archives.
After this operation, 36.2 MB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 liberror-perl all 0.17024-1 [26.9 kB]
Get:2 http://ftp.us.debian.org/debian stretch/main amd64 git-man all 1:2.11.0-3+deb9u4 [1,433 kB]
Get:3 http://ftp.us.debian.org/debian stretch/main amd64 git amd64 1:2.11.0-3+deb9u4 [4,167 kB]
Get:4 http://ftp.us.debian.org/debian stretch/main amd64 apt-transport-https amd64 1.4.9 [171 kB]
Get:5 http://ftp.us.debian.org/debian stretch/main amd64 libcurl3 amd64 7.52.1-5+deb9u8 [292 kB]
Get:6 http://ftp.us.debian.org/debian stretch/main amd64 curl amd64 7.52.1-5+deb9u8 [228 kB]
Get:7 http://ftp.us.debian.org/debian stretch/main amd64 rsync amd64 3.1.2-1+deb9u1 [393 kB]
Get:8 http://ftp.us.debian.org/debian stretch/main amd64 sudo amd64 1.8.19p1-2.1 [1,055 kB]
Fetched 7,764 kB in 3s (2,059 kB/s)
Selecting previously unselected package liberror-perl.
(Reading database ... 129409 files and directories currently installed.)
Preparing to unpack .../0-liberror-perl_0.17024-1_all.deb ...
Unpacking liberror-perl (0.17024-1) ...
Selecting previously unselected package git-man.
Preparing to unpack .../1-git-man_1%3a2.11.0-3+deb9u4_all.deb ...
Unpacking git-man (1:2.11.0-3+deb9u4) ...
Selecting previously unselected package git.
Preparing to unpack .../2-git_1%3a2.11.0-3+deb9u4_amd64.deb ...
Unpacking git (1:2.11.0-3+deb9u4) ...
Selecting previously unselected package apt-transport-https.
Preparing to unpack .../3-apt-transport-https_1.4.9_amd64.deb ...
Unpacking apt-transport-https (1.4.9) ...
Selecting previously unselected package libcurl3:amd64.
Preparing to unpack .../4-libcurl3_7.52.1-5+deb9u8_amd64.deb ...
Unpacking libcurl3:amd64 (7.52.1-5+deb9u8) ...
Selecting previously unselected package curl.
Preparing to unpack .../5-curl_7.52.1-5+deb9u8_amd64.deb ...
Unpacking curl (7.52.1-5+deb9u8) ...
Selecting previously unselected package rsync.
Preparing to unpack .../6-rsync_3.1.2-1+deb9u1_amd64.deb ...
Unpacking rsync (3.1.2-1+deb9u1) ...
Selecting previously unselected package sudo.
Preparing to unpack .../7-sudo_1.8.19p1-2.1_amd64.deb ...
Unpacking sudo (1.8.19p1-2.1) ...
Setting up git-man (1:2.11.0-3+deb9u4) ...
Setting up apt-transport-https (1.4.9) ...
Setting up sudo (1.8.19p1-2.1) ...
Setting up liberror-perl (0.17024-1) ...
Setting up libcurl3:amd64 (7.52.1-5+deb9u8) ...
Setting up rsync (3.1.2-1+deb9u1) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Processing triggers for systemd (232-25+deb9u6) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up git (1:2.11.0-3+deb9u4) ...
Setting up curl (7.52.1-5+deb9u8) ...
OK
deb https://dist.crystal-lang.org/apt crystal main
Ign:1 http://ftp.us.debian.org/debian stretch InRelease
Hit:2 http://ftp.us.debian.org/debian stretch Release
Get:4 https://dist.crystal-lang.org/apt crystal InRelease [2,496 B]
Get:5 https://dist.crystal-lang.org/apt crystal/main amd64 Packages [447 B]
Fetched 2,943 B in 1s (1,824 B/s)
Reading package lists... Done
Reading package lists... Done
Building dependency tree       
Reading state information... Done
apt-transport-https is already the newest version (1.4.9).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
git is already the newest version (1:2.11.0-3+deb9u4).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
curl is already the newest version (7.52.1-5+deb9u8).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
sudo is already the newest version (1.8.19p1-2.1).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
E: Unable to locate package remove
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  libevent-core-2.0-5 libevent-dev libevent-extra-2.0-5 libevent-openssl-2.0-5 libevent-pthreads-2.0-5
  libpcre16-3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libssl-dev libssl-doc pkg-config zlib1g-dev
Suggested packages:
  libxml2-dev libgmp-dev libyaml-dev libreadline-dev
The following NEW packages will be installed:
  crystal libevent-core-2.0-5 libevent-dev libevent-extra-2.0-5 libevent-openssl-2.0-5
  libevent-pthreads-2.0-5 libpcre16-3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libssl-dev libssl-doc
  pkg-config zlib1g-dev
0 upgraded, 14 newly installed, 0 to remove and 1 not upgraded.
Need to get 45.0 MB of archives.
After this operation, 201 MB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 libpcrecpp0v5 amd64 2:8.39-3 [151 kB]
Get:2 https://dist.crystal-lang.org/apt crystal/main amd64 crystal amd64 0.27.2-1 [39.8 MB]
Get:3 http://ftp.us.debian.org/debian stretch/main amd64 libevent-core-2.0-5 amd64 2.0.21-stable-3 [109 kB]
Get:4 http://ftp.us.debian.org/debian stretch/main amd64 libevent-extra-2.0-5 amd64 2.0.21-stable-3 [90.2 kB]
Get:5 http://ftp.us.debian.org/debian stretch/main amd64 libevent-pthreads-2.0-5 amd64 2.0.21-stable-3 [43.8 kB]
Get:6 http://ftp.us.debian.org/debian stretch/main amd64 libevent-openssl-2.0-5 amd64 2.0.21-stable-3 [49.8 kB]
Get:7 http://ftp.us.debian.org/debian stretch/main amd64 libevent-dev amd64 2.0.21-stable-3 [249 kB]
Get:8 http://ftp.us.debian.org/debian stretch/main amd64 libpcre16-3 amd64 2:8.39-3 [258 kB]
Get:9 http://ftp.us.debian.org/debian stretch/main amd64 libpcre32-3 amd64 2:8.39-3 [248 kB]
Get:10 http://ftp.us.debian.org/debian stretch/main amd64 libpcre3-dev amd64 2:8.39-3 [647 kB]
Get:11 http://ftp.us.debian.org/debian stretch/main amd64 libssl-dev amd64 1.1.0f-3+deb9u2 [1,575 kB]
Get:12 http://ftp.us.debian.org/debian stretch/main amd64 libssl-doc all 1.1.0f-3+deb9u2 [1,459 kB]
Get:13 http://ftp.us.debian.org/debian stretch/main amd64 pkg-config amd64 0.29-4+b1 [63.3 kB]
Get:14 http://ftp.us.debian.org/debian stretch/main amd64 zlib1g-dev amd64 1:1.2.8.dfsg-5 [205 kB]
Fetched 45.0 MB in 7s (5,743 kB/s)                                                                      
Selecting previously unselected package libpcrecpp0v5:amd64.
(Reading database ... 130443 files and directories currently installed.)
Preparing to unpack .../00-libpcrecpp0v5_2%3a8.39-3_amd64.deb ...
Unpacking libpcrecpp0v5:amd64 (2:8.39-3) ...
Selecting previously unselected package libevent-core-2.0-5:amd64.
Preparing to unpack .../01-libevent-core-2.0-5_2.0.21-stable-3_amd64.deb ...
Unpacking libevent-core-2.0-5:amd64 (2.0.21-stable-3) ...
Selecting previously unselected package libevent-extra-2.0-5:amd64.
Preparing to unpack .../02-libevent-extra-2.0-5_2.0.21-stable-3_amd64.deb ...
Unpacking libevent-extra-2.0-5:amd64 (2.0.21-stable-3) ...
Selecting previously unselected package libevent-pthreads-2.0-5:amd64.
Preparing to unpack .../03-libevent-pthreads-2.0-5_2.0.21-stable-3_amd64.deb ...
Unpacking libevent-pthreads-2.0-5:amd64 (2.0.21-stable-3) ...
Selecting previously unselected package libevent-openssl-2.0-5:amd64.
Preparing to unpack .../04-libevent-openssl-2.0-5_2.0.21-stable-3_amd64.deb ...
Unpacking libevent-openssl-2.0-5:amd64 (2.0.21-stable-3) ...
Selecting previously unselected package libevent-dev.
Preparing to unpack .../05-libevent-dev_2.0.21-stable-3_amd64.deb ...
Unpacking libevent-dev (2.0.21-stable-3) ...
Selecting previously unselected package libpcre16-3:amd64.
Preparing to unpack .../06-libpcre16-3_2%3a8.39-3_amd64.deb ...
Unpacking libpcre16-3:amd64 (2:8.39-3) ...
Selecting previously unselected package libpcre32-3:amd64.
Preparing to unpack .../07-libpcre32-3_2%3a8.39-3_amd64.deb ...
Unpacking libpcre32-3:amd64 (2:8.39-3) ...
Selecting previously unselected package libpcre3-dev:amd64.
Preparing to unpack .../08-libpcre3-dev_2%3a8.39-3_amd64.deb ...
Unpacking libpcre3-dev:amd64 (2:8.39-3) ...
Selecting previously unselected package libssl-dev:amd64.
Preparing to unpack .../09-libssl-dev_1.1.0f-3+deb9u2_amd64.deb ...
Unpacking libssl-dev:amd64 (1.1.0f-3+deb9u2) ...
Selecting previously unselected package libssl-doc.
Preparing to unpack .../10-libssl-doc_1.1.0f-3+deb9u2_all.deb ...
Unpacking libssl-doc (1.1.0f-3+deb9u2) ...
Selecting previously unselected package pkg-config.
Preparing to unpack .../11-pkg-config_0.29-4+b1_amd64.deb ...
Unpacking pkg-config (0.29-4+b1) ...
Selecting previously unselected package zlib1g-dev:amd64.
Preparing to unpack .../12-zlib1g-dev_1%3a1.2.8.dfsg-5_amd64.deb ...
Unpacking zlib1g-dev:amd64 (1:1.2.8.dfsg-5) ...
Selecting previously unselected package crystal.
Preparing to unpack .../13-crystal_0.27.2-1_amd64.deb ...
Unpacking crystal (0.27.2-1) ...
Setting up libssl-dev:amd64 (1.1.0f-3+deb9u2) ...
Setting up pkg-config (0.29-4+b1) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Setting up libevent-core-2.0-5:amd64 (2.0.21-stable-3) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up libpcrecpp0v5:amd64 (2:8.39-3) ...
Setting up libpcre32-3:amd64 (2:8.39-3) ...
Setting up libssl-doc (1.1.0f-3+deb9u2) ...
Setting up libpcre16-3:amd64 (2:8.39-3) ...
Setting up zlib1g-dev:amd64 (1:1.2.8.dfsg-5) ...
Setting up libpcre3-dev:amd64 (2:8.39-3) ...
Setting up libevent-pthreads-2.0-5:amd64 (2.0.21-stable-3) ...
Setting up libevent-extra-2.0-5:amd64 (2.0.21-stable-3) ...
Setting up libevent-openssl-2.0-5:amd64 (2.0.21-stable-3) ...
Setting up libevent-dev (2.0.21-stable-3) ...
Setting up crystal (0.27.2-1) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Reading package lists... Done
Building dependency tree       
Reading state information... Done
libssl-dev is already the newest version (1.1.0f-3+deb9u2).
libssl-dev set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  icu-devtools libicu-dev libstdc++-6-dev
Suggested packages:
  icu-doc libstdc++-6-doc
The following NEW packages will be installed:
  icu-devtools libicu-dev libstdc++-6-dev libxml2-dev
0 upgraded, 4 newly installed, 0 to remove and 1 not upgraded.
Need to get 18.9 MB of archives.
After this operation, 112 MB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 icu-devtools amd64 57.1-6+deb9u2 [178 kB]
Get:2 http://ftp.us.debian.org/debian stretch/main amd64 libstdc++-6-dev amd64 6.3.0-18+deb9u1 [1,420 kB]
Get:3 http://ftp.us.debian.org/debian stretch/main amd64 libicu-dev amd64 57.1-6+deb9u2 [16.5 MB]
Get:4 http://ftp.us.debian.org/debian stretch/main amd64 libxml2-dev amd64 2.9.4+dfsg1-2.2+deb9u2 [812 kB]
Fetched 18.9 MB in 9s (1,941 kB/s)                                                                      
Selecting previously unselected package icu-devtools.
(Reading database ... 135839 files and directories currently installed.)
Preparing to unpack .../icu-devtools_57.1-6+deb9u2_amd64.deb ...
Unpacking icu-devtools (57.1-6+deb9u2) ...
Selecting previously unselected package libstdc++-6-dev:amd64.
Preparing to unpack .../libstdc++-6-dev_6.3.0-18+deb9u1_amd64.deb ...
Unpacking libstdc++-6-dev:amd64 (6.3.0-18+deb9u1) ...
Selecting previously unselected package libicu-dev.
Preparing to unpack .../libicu-dev_57.1-6+deb9u2_amd64.deb ...
Unpacking libicu-dev (57.1-6+deb9u2) ...
Selecting previously unselected package libxml2-dev:amd64.
Preparing to unpack .../libxml2-dev_2.9.4+dfsg1-2.2+deb9u2_amd64.deb ...
Unpacking libxml2-dev:amd64 (2.9.4+dfsg1-2.2+deb9u2) ...
Setting up libstdc++-6-dev:amd64 (6.3.0-18+deb9u1) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up icu-devtools (57.1-6+deb9u2) ...
Setting up libicu-dev (57.1-6+deb9u2) ...
Setting up libxml2-dev:amd64 (2.9.4+dfsg1-2.2+deb9u2) ...
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Suggested packages:
  libyaml-doc
The following NEW packages will be installed:
  libyaml-dev
0 upgraded, 1 newly installed, 0 to remove and 1 not upgraded.
Need to get 56.7 kB of archives.
After this operation, 238 kB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 libyaml-dev amd64 0.1.7-2 [56.7 kB]
Fetched 56.7 kB in 0s (105 kB/s)       
Selecting previously unselected package libyaml-dev:amd64.
(Reading database ... 136970 files and directories currently installed.)
Preparing to unpack .../libyaml-dev_0.1.7-2_amd64.deb ...
Unpacking libyaml-dev:amd64 (0.1.7-2) ...
Setting up libyaml-dev:amd64 (0.1.7-2) ...
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  libgmpxx4ldbl
Suggested packages:
  gmp-doc libgmp10-doc libmpfr-dev
The following NEW packages will be installed:
  libgmp-dev libgmpxx4ldbl
0 upgraded, 2 newly installed, 0 to remove and 1 not upgraded.
Need to get 653 kB of archives.
After this operation, 1,971 kB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 libgmpxx4ldbl amd64 2:6.1.2+dfsg-1 [22.2 kB]
Get:2 http://ftp.us.debian.org/debian stretch/main amd64 libgmp-dev amd64 2:6.1.2+dfsg-1 [631 kB]
Fetched 653 kB in 1s (486 kB/s)     
Selecting previously unselected package libgmpxx4ldbl:amd64.
(Reading database ... 136977 files and directories currently installed.)
Preparing to unpack .../libgmpxx4ldbl_2%3a6.1.2+dfsg-1_amd64.deb ...
Unpacking libgmpxx4ldbl:amd64 (2:6.1.2+dfsg-1) ...
Selecting previously unselected package libgmp-dev:amd64.
Preparing to unpack .../libgmp-dev_2%3a6.1.2+dfsg-1_amd64.deb ...
Unpacking libgmp-dev:amd64 (2:6.1.2+dfsg-1) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Setting up libgmpxx4ldbl:amd64 (2:6.1.2+dfsg-1) ...
Setting up libgmp-dev:amd64 (2:6.1.2+dfsg-1) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  libtinfo-dev
Suggested packages:
  readline-doc
The following NEW packages will be installed:
  libreadline-dev libtinfo-dev
0 upgraded, 2 newly installed, 0 to remove and 1 not upgraded.
Need to get 211 kB of archives.
After this operation, 1,129 kB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 libtinfo-dev amd64 6.0+20161126-1+deb9u2 [79.2 kB]
Get:2 http://ftp.us.debian.org/debian stretch/main amd64 libreadline-dev amd64 7.0-3 [132 kB]
Fetched 211 kB in 0s (291 kB/s)          
Selecting previously unselected package libtinfo-dev:amd64.
(Reading database ... 136996 files and directories currently installed.)
Preparing to unpack .../libtinfo-dev_6.0+20161126-1+deb9u2_amd64.deb ...
Unpacking libtinfo-dev:amd64 (6.0+20161126-1+deb9u2) ...
Selecting previously unselected package libreadline-dev:amd64.
Preparing to unpack .../libreadline-dev_7.0-3_amd64.deb ...
Unpacking libreadline-dev:amd64 (7.0-3) ...
Setting up libtinfo-dev:amd64 (6.0+20161126-1+deb9u2) ...
Setting up libreadline-dev:amd64 (7.0-3) ...
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  gir1.2-rsvg-2.0 libcairo-script-interpreter2 libcairo2-dev libexpat1-dev libfontconfig1-dev
  libfreetype6-dev libgdk-pixbuf2.0-dev libglib2.0-dev libice-dev libpixman-1-dev libpng-dev
  libpng-tools libpthread-stubs0-dev libsm-dev libx11-dev libx11-doc libxau-dev libxcb-render0-dev
  libxcb-shm0-dev libxcb1-dev libxdmcp-dev libxext-dev libxrender-dev x11proto-core-dev
  x11proto-input-dev x11proto-kb-dev x11proto-render-dev x11proto-xext-dev xorg-sgml-doctools
  xtrans-dev
Suggested packages:
  libcairo2-doc libglib2.0-doc libice-doc librsvg2-doc libsm-doc libxcb-doc libxext-doc
The following NEW packages will be installed:
  gir1.2-rsvg-2.0 libcairo-script-interpreter2 libcairo2-dev libexpat1-dev libfontconfig1-dev
  libfreetype6-dev libgdk-pixbuf2.0-dev libglib2.0-dev libice-dev libpixman-1-dev libpng-dev
  libpng-tools libpthread-stubs0-dev librsvg2-dev libsm-dev libx11-dev libx11-doc libxau-dev
  libxcb-render0-dev libxcb-shm0-dev libxcb1-dev libxdmcp-dev libxext-dev libxrender-dev
  x11proto-core-dev x11proto-input-dev x11proto-kb-dev x11proto-render-dev x11proto-xext-dev
  xorg-sgml-doctools xtrans-dev
0 upgraded, 31 newly installed, 0 to remove and 1 not upgraded.
Need to get 17.8 MB of archives.
After this operation, 50.4 MB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 gir1.2-rsvg-2.0 amd64 2.40.16-1+b1 [192 kB]
Get:2 http://ftp.us.debian.org/debian stretch/main amd64 libcairo-script-interpreter2 amd64 1.14.8-1 [373 kB]
Get:3 http://ftp.us.debian.org/debian stretch/main amd64 libexpat1-dev amd64 2.2.0-2+deb9u1 [134 kB]
Get:4 http://ftp.us.debian.org/debian stretch/main amd64 libpng-dev amd64 1.6.28-1 [250 kB]
Get:5 http://ftp.us.debian.org/debian stretch/main amd64 libfreetype6-dev amd64 2.6.3-3.2 [5,815 kB]
Get:6 http://ftp.us.debian.org/debian stretch/main amd64 libfontconfig1-dev amd64 2.11.0-6.7+b1 [897 kB]
Get:7 http://ftp.us.debian.org/debian stretch/main amd64 xorg-sgml-doctools all 1:1.11-1 [21.9 kB]
Get:8 http://ftp.us.debian.org/debian stretch/main amd64 x11proto-core-dev all 7.0.31-1 [728 kB]
Get:9 http://ftp.us.debian.org/debian stretch/main amd64 libxau-dev amd64 1:1.0.8-1 [23.6 kB]
Get:10 http://ftp.us.debian.org/debian stretch/main amd64 libxdmcp-dev amd64 1:1.1.2-3 [42.2 kB]
Get:11 http://ftp.us.debian.org/debian stretch/main amd64 x11proto-input-dev all 2.3.2-1 [158 kB]
Get:12 http://ftp.us.debian.org/debian stretch/main amd64 x11proto-kb-dev all 1.0.7-1 [233 kB]
Get:13 http://ftp.us.debian.org/debian stretch/main amd64 xtrans-dev all 1.3.5-1 [100 kB]
Get:14 http://ftp.us.debian.org/debian stretch/main amd64 libpthread-stubs0-dev amd64 0.3-4 [3,866 B]
Get:15 http://ftp.us.debian.org/debian stretch/main amd64 libxcb1-dev amd64 1.12-1 [169 kB]
Get:16 http://ftp.us.debian.org/debian stretch/main amd64 libx11-dev amd64 2:1.6.4-3+deb9u1 [815 kB]
Get:17 http://ftp.us.debian.org/debian stretch/main amd64 x11proto-render-dev all 2:0.11.1-2 [20.8 kB]
Get:18 http://ftp.us.debian.org/debian stretch/main amd64 libxrender-dev amd64 1:0.9.10-1 [40.8 kB]
Get:19 http://ftp.us.debian.org/debian stretch/main amd64 x11proto-xext-dev all 7.3.0-1 [212 kB]
Get:20 http://ftp.us.debian.org/debian stretch/main amd64 libxext-dev amd64 2:1.3.3-1+b2 [107 kB]
Get:21 http://ftp.us.debian.org/debian stretch/main amd64 libice-dev amd64 2:1.0.9-2 [66.8 kB]
Get:22 http://ftp.us.debian.org/debian stretch/main amd64 libsm-dev amd64 2:1.2.2-1+b3 [35.8 kB]
Get:23 http://ftp.us.debian.org/debian stretch/main amd64 libpixman-1-dev amd64 0.34.0-1 [547 kB]
Get:24 http://ftp.us.debian.org/debian stretch/main amd64 libxcb-render0-dev amd64 1.12-1 [109 kB]
Get:25 http://ftp.us.debian.org/debian stretch/main amd64 libxcb-shm0-dev amd64 1.12-1 [96.9 kB]
Get:26 http://ftp.us.debian.org/debian stretch/main amd64 libglib2.0-dev amd64 2.50.3-2 [2,984 kB]
Get:27 http://ftp.us.debian.org/debian stretch/main amd64 libcairo2-dev amd64 1.14.8-1 [919 kB]         
Get:28 http://ftp.us.debian.org/debian stretch/main amd64 libgdk-pixbuf2.0-dev amd64 2.36.5-2+deb9u2 [54.3 kB]
Get:29 http://ftp.us.debian.org/debian stretch/main amd64 libpng-tools amd64 1.6.28-1 [133 kB]          
Get:30 http://ftp.us.debian.org/debian stretch/main amd64 librsvg2-dev amd64 2.40.16-1+b1 [293 kB]      
Get:31 http://ftp.us.debian.org/debian stretch/main amd64 libx11-doc all 2:1.6.4-3+deb9u1 [2,201 kB]    
Fetched 17.8 MB in 8s (2,010 kB/s)                                                                      
Extracting templates from packages: 100%
Selecting previously unselected package gir1.2-rsvg-2.0:amd64.
(Reading database ... 137020 files and directories currently installed.)
Preparing to unpack .../00-gir1.2-rsvg-2.0_2.40.16-1+b1_amd64.deb ...
Unpacking gir1.2-rsvg-2.0:amd64 (2.40.16-1+b1) ...
Selecting previously unselected package libcairo-script-interpreter2:amd64.
Preparing to unpack .../01-libcairo-script-interpreter2_1.14.8-1_amd64.deb ...
Unpacking libcairo-script-interpreter2:amd64 (1.14.8-1) ...
Selecting previously unselected package libexpat1-dev:amd64.
Preparing to unpack .../02-libexpat1-dev_2.2.0-2+deb9u1_amd64.deb ...
Unpacking libexpat1-dev:amd64 (2.2.0-2+deb9u1) ...
Selecting previously unselected package libpng-dev:amd64.
Preparing to unpack .../03-libpng-dev_1.6.28-1_amd64.deb ...
Unpacking libpng-dev:amd64 (1.6.28-1) ...
Selecting previously unselected package libfreetype6-dev.
Preparing to unpack .../04-libfreetype6-dev_2.6.3-3.2_amd64.deb ...
Unpacking libfreetype6-dev (2.6.3-3.2) ...
Selecting previously unselected package libfontconfig1-dev:amd64.
Preparing to unpack .../05-libfontconfig1-dev_2.11.0-6.7+b1_amd64.deb ...
Unpacking libfontconfig1-dev:amd64 (2.11.0-6.7+b1) ...
Selecting previously unselected package xorg-sgml-doctools.
Preparing to unpack .../06-xorg-sgml-doctools_1%3a1.11-1_all.deb ...
Unpacking xorg-sgml-doctools (1:1.11-1) ...
Selecting previously unselected package x11proto-core-dev.
Preparing to unpack .../07-x11proto-core-dev_7.0.31-1_all.deb ...
Unpacking x11proto-core-dev (7.0.31-1) ...
Selecting previously unselected package libxau-dev:amd64.
Preparing to unpack .../08-libxau-dev_1%3a1.0.8-1_amd64.deb ...
Unpacking libxau-dev:amd64 (1:1.0.8-1) ...
Selecting previously unselected package libxdmcp-dev:amd64.
Preparing to unpack .../09-libxdmcp-dev_1%3a1.1.2-3_amd64.deb ...
Unpacking libxdmcp-dev:amd64 (1:1.1.2-3) ...
Selecting previously unselected package x11proto-input-dev.
Preparing to unpack .../10-x11proto-input-dev_2.3.2-1_all.deb ...
Unpacking x11proto-input-dev (2.3.2-1) ...
Selecting previously unselected package x11proto-kb-dev.
Preparing to unpack .../11-x11proto-kb-dev_1.0.7-1_all.deb ...
Unpacking x11proto-kb-dev (1.0.7-1) ...
Selecting previously unselected package xtrans-dev.
Preparing to unpack .../12-xtrans-dev_1.3.5-1_all.deb ...
Unpacking xtrans-dev (1.3.5-1) ...
Selecting previously unselected package libpthread-stubs0-dev:amd64.
Preparing to unpack .../13-libpthread-stubs0-dev_0.3-4_amd64.deb ...
Unpacking libpthread-stubs0-dev:amd64 (0.3-4) ...
Selecting previously unselected package libxcb1-dev:amd64.
Preparing to unpack .../14-libxcb1-dev_1.12-1_amd64.deb ...
Unpacking libxcb1-dev:amd64 (1.12-1) ...
Selecting previously unselected package libx11-dev:amd64.
Preparing to unpack .../15-libx11-dev_2%3a1.6.4-3+deb9u1_amd64.deb ...
Unpacking libx11-dev:amd64 (2:1.6.4-3+deb9u1) ...
Selecting previously unselected package x11proto-render-dev.
Preparing to unpack .../16-x11proto-render-dev_2%3a0.11.1-2_all.deb ...
Unpacking x11proto-render-dev (2:0.11.1-2) ...
Selecting previously unselected package libxrender-dev:amd64.
Preparing to unpack .../17-libxrender-dev_1%3a0.9.10-1_amd64.deb ...
Unpacking libxrender-dev:amd64 (1:0.9.10-1) ...
Selecting previously unselected package x11proto-xext-dev.
Preparing to unpack .../18-x11proto-xext-dev_7.3.0-1_all.deb ...
Unpacking x11proto-xext-dev (7.3.0-1) ...
Selecting previously unselected package libxext-dev:amd64.
Preparing to unpack .../19-libxext-dev_2%3a1.3.3-1+b2_amd64.deb ...
Unpacking libxext-dev:amd64 (2:1.3.3-1+b2) ...
Selecting previously unselected package libice-dev:amd64.
Preparing to unpack .../20-libice-dev_2%3a1.0.9-2_amd64.deb ...
Unpacking libice-dev:amd64 (2:1.0.9-2) ...
Selecting previously unselected package libsm-dev:amd64.
Preparing to unpack .../21-libsm-dev_2%3a1.2.2-1+b3_amd64.deb ...
Unpacking libsm-dev:amd64 (2:1.2.2-1+b3) ...
Selecting previously unselected package libpixman-1-dev.
Preparing to unpack .../22-libpixman-1-dev_0.34.0-1_amd64.deb ...
Unpacking libpixman-1-dev (0.34.0-1) ...
Selecting previously unselected package libxcb-render0-dev:amd64.
Preparing to unpack .../23-libxcb-render0-dev_1.12-1_amd64.deb ...
Unpacking libxcb-render0-dev:amd64 (1.12-1) ...
Selecting previously unselected package libxcb-shm0-dev:amd64.
Preparing to unpack .../24-libxcb-shm0-dev_1.12-1_amd64.deb ...
Unpacking libxcb-shm0-dev:amd64 (1.12-1) ...
Selecting previously unselected package libglib2.0-dev.
Preparing to unpack .../25-libglib2.0-dev_2.50.3-2_amd64.deb ...
Unpacking libglib2.0-dev (2.50.3-2) ...
Selecting previously unselected package libcairo2-dev.
Preparing to unpack .../26-libcairo2-dev_1.14.8-1_amd64.deb ...
Unpacking libcairo2-dev (1.14.8-1) ...
Selecting previously unselected package libgdk-pixbuf2.0-dev.
Preparing to unpack .../27-libgdk-pixbuf2.0-dev_2.36.5-2+deb9u2_amd64.deb ...
Unpacking libgdk-pixbuf2.0-dev (2.36.5-2+deb9u2) ...
Selecting previously unselected package libpng-tools.
Preparing to unpack .../28-libpng-tools_1.6.28-1_amd64.deb ...
Unpacking libpng-tools (1.6.28-1) ...
Selecting previously unselected package librsvg2-dev:amd64.
Preparing to unpack .../29-librsvg2-dev_2.40.16-1+b1_amd64.deb ...
Unpacking librsvg2-dev:amd64 (2.40.16-1+b1) ...
Selecting previously unselected package libx11-doc.
Preparing to unpack .../30-libx11-doc_2%3a1.6.4-3+deb9u1_all.deb ...
Unpacking libx11-doc (2:1.6.4-3+deb9u1) ...
Setting up libcairo-script-interpreter2:amd64 (1.14.8-1) ...
Setting up libpthread-stubs0-dev:amd64 (0.3-4) ...
Setting up libpng-tools (1.6.28-1) ...
Processing triggers for libglib2.0-0:amd64 (2.50.3-2) ...
Setting up xorg-sgml-doctools (1:1.11-1) ...
Setting up x11proto-kb-dev (1.0.7-1) ...
Processing triggers for sgml-base (1.29) ...
Setting up libglib2.0-dev (2.50.3-2) ...
Setting up xtrans-dev (1.3.5-1) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Setting up libpixman-1-dev (0.34.0-1) ...
Setting up gir1.2-rsvg-2.0:amd64 (2.40.16-1+b1) ...
Setting up libexpat1-dev:amd64 (2.2.0-2+deb9u1) ...
Setting up libx11-doc (2:1.6.4-3+deb9u1) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up libpng-dev:amd64 (1.6.28-1) ...
Setting up x11proto-core-dev (7.0.31-1) ...
Setting up libxau-dev:amd64 (1:1.0.8-1) ...
Setting up libxdmcp-dev:amd64 (1:1.1.2-3) ...
Setting up libfreetype6-dev (2.6.3-3.2) ...
Setting up libice-dev:amd64 (2:1.0.9-2) ...
Setting up libxcb1-dev:amd64 (1.12-1) ...
Setting up x11proto-render-dev (2:0.11.1-2) ...
Setting up x11proto-input-dev (2.3.2-1) ...
Setting up libfontconfig1-dev:amd64 (2.11.0-6.7+b1) ...
Setting up libsm-dev:amd64 (2:1.2.2-1+b3) ...
Setting up libxcb-shm0-dev:amd64 (1.12-1) ...
Setting up libxcb-render0-dev:amd64 (1.12-1) ...
Setting up x11proto-xext-dev (7.3.0-1) ...
Setting up libx11-dev:amd64 (2:1.6.4-3+deb9u1) ...
Setting up libxrender-dev:amd64 (1:0.9.10-1) ...
Setting up libgdk-pixbuf2.0-dev (2.36.5-2+deb9u2) ...
Setting up libxext-dev:amd64 (2:1.3.3-1+b2) ...
Setting up libcairo2-dev (1.14.8-1) ...
Setting up librsvg2-dev:amd64 (2.40.16-1+b1) ...
Reading package lists... Done
Building dependency tree       
Reading state information... Done
postgresql is already the newest version (9.6+181+deb9u2).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
postgresql-9.6 is already the newest version (9.6.10-0+deb9u1).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
postgresql-client-9.6 is already the newest version (9.6.10-0+deb9u1).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
postgresql-contrib-9.6 is already the newest version (9.6.10-0+deb9u1).
0 upgraded, 0 newly installed, 0 to remove and 1 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  imagemagick
0 upgraded, 1 newly installed, 0 to remove and 1 not upgraded.
Need to get 141 kB of archives.
After this operation, 200 kB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 imagemagick amd64 8:6.9.7.4+dfsg-11+deb9u6 [141 kB]
Fetched 141 kB in 0s (234 kB/s)     
Selecting previously unselected package imagemagick.
(Reading database ... 139455 files and directories currently installed.)
Preparing to unpack .../imagemagick_8%3a6.9.7.4+dfsg-11+deb9u6_amd64.deb ...
Unpacking imagemagick (8:6.9.7.4+dfsg-11+deb9u6) ...
Setting up imagemagick (8:6.9.7.4+dfsg-11+deb9u6) ...
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Suggested packages:
  sqlite3-doc
The following NEW packages will be installed:
  libsqlite3-dev
0 upgraded, 1 newly installed, 0 to remove and 1 not upgraded.
Need to get 704 kB of archives.
After this operation, 2,063 kB of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian stretch/main amd64 libsqlite3-dev amd64 3.16.2-5+deb9u1 [704 kB]
Fetched 704 kB in 0s (792 kB/s)         
Selecting previously unselected package libsqlite3-dev:amd64.
(Reading database ... 139461 files and directories currently installed.)
Preparing to unpack .../libsqlite3-dev_3.16.2-5+deb9u1_amd64.deb ...
Unpacking libsqlite3-dev:amd64 (3.16.2-5+deb9u1) ...
Setting up libsqlite3-dev:amd64 (3.16.2-5+deb9u1) ...
Error: invalid version 'start'
User Not Found, adding user
Adding user `invidious' to group `sudo' ...
Adding user invidious to group sudo
Done.
Downloading Invidious from GitHub
Cloning into 'invidious'...
remote: Enumerating objects: 54, done.
remote: Counting objects: 100% (54/54), done.
remote: Compressing objects: 100% (39/39), done.
remote: Total 6730 (delta 19), reused 38 (delta 15), pack-reused 6676
Receiving objects: 100% (6730/6730), 3.61 MiB | 2.17 MiB/s, done.
Resolving deltas: 100% (4036/4036), done.
Note: checking out '0.14.0'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at 699f85e... Fix Google login
/home/invidious
Synchronizing state of postgresql.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable postgresql
Creating user postgres with no password
ERROR:  role "postgres" already exists
Grant all on database postgres to user postgres
GRANT
Creating user kemal with password testing
ERROR:  role "kemal" already exists
Creating user invidious with password testing
ERROR:  role "invidious" already exists
Creating database testing with owner kemal
CREATE DATABASE
Grant all on database testing to user kemal
GRANT
Grant all on database testing to user invidious
GRANT
Running channels.sql
CREATE TABLE
GRANT
CREATE INDEX
Running videos.sql
CREATE TABLE
GRANT
CREATE INDEX
Running channel_videos.sql
CREATE TABLE
GRANT
CREATE INDEX
psql:/home/invidious/invidious/config/sql/channel_videos.sql:35: WARNING:  hash indexes are not WAL-logged and their use is discouraged
CREATE INDEX
Running users.sql
CREATE TABLE
GRANT
CREATE INDEX
Running nonces.sql
CREATE TABLE
GRANT
Finished Database section
Updating config.yml with new info...
Done updating config.yml with new info!
Fetching https://github.com/detectlanguage/detectlanguage-crystal.git
Fetching https://github.com/kemalcr/kemal.git
Fetching https://github.com/luislavena/radix.git
Fetching https://github.com/jeromegn/kilt.git
Fetching https://github.com/crystal-loot/exception_page.git
Fetching https://github.com/will/crystal-pg.git
Fetching https://github.com/crystal-lang/crystal-db.git
Fetching https://github.com/crystal-lang/crystal-sqlite3.git
Installing detect_language (0.1.0 at 0.2.0)
Installing kemal (0.24.0 at afd17fc)
Installing radix (0.3.9)
Installing kilt (0.4.0)
Installing exception_page (0.1.2)
Installing pg (0.15.0)
Installing db (0.5.1)
Installing sqlite3 (0.10.0)
Created symlink /etc/systemd/system/multi-user.target.wants/invidious.service → /lib/systemd/system/invidious.service.
Invidious service has been successfully installed!
● invidious.service - Invidious (An alternative YouTube front-end)
   Loaded: loaded (/lib/systemd/system/invidious.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2019-02-13 04:36:34 CET; 45ms ago
 Main PID: 23139 (invidious)
    Tasks: 8 (limit: 4915)
   CGroup: /system.slice/invidious.service
           └─23139 /home/invidious/invidious/invidious -o invidious.log

Feb 13 04:36:34 debian9-univ systemd[1]: Started Invidious (An alternative YouTube front-end).
Feb 13 04:36:34 debian9-univ invidious[23139]: Unhandled exception:  (DB::ConnectionRefused)


 ######################################################################
 ####                    Invidious Update.sh                       ####
 ####            Automatic update script for Invidio.us            ####
 ####                   Maintained by @tmiland                     ####
 ####                        version: 1.1.4                        ####
 ######################################################################


Thank you for using the Invidious Update.sh script.

Invidious install done. Now visit http://localhost:3000

Documentation for this script is available here: 
 https://github.com/tmiland/Invidious-Updater

 ```
</p></details>


## Issues

- Captcha is not working, issue with [imagemagick](https://github.com/omarroth/invidious/wiki/Issues-with-Captcha-on-Debian-and-Ubuntu)
- Issue with folder permissions after reinstalling, Invidious won't start. [bug](https://github.com/tmiland/Invidious-Updater/issues/6#issue-409626197)

## Todo
- [X] Rework the install prompts - Done in version 1.1.5
- [ ] Rewrite the update procedure
- [X] Add Uninstallation option - Added in version 1.1.4
- [X] Add database migration option [migrate-scripts](https://github.com/omarroth/invidious/tree/master/config/migrate-scripts)
- [X] Add database maintenance option [Database Information and Maintenance](https://github.com/omarroth/invidious/wiki/Database-Information-and-Maintenance)
- [ ] Add option to compile imagemagick from source [Issues with Captcha on Debian and Ubuntu](https://github.com/omarroth/invidious/wiki/Issues-with-Captcha-on-Debian-and-Ubuntu)
- [ ] Add support to deploy in Docker

### Possible options
- Add support for auto-update check
- [ ] For Invidious
- [ ] For Script

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
