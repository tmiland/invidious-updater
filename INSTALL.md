#### Download and execute the script

***Note: you will be prompted to enter root password***

If root password is not set, type:

```bash
sudo passwd root
```
Log in as root
```bash
su root
```

To install this script:
- Latest release
  ```bash
  curl -sSL https://tmiland.github.io/invidious-updater/install.sh | bash release 
  ```
- Master
  ```bash
  curl -sSL https://tmiland.github.io/invidious-updater/install.sh | bash
  ```

### Repository

 ```shell
 sudo curl -SsL -o /etc/apt/sources.list.d/tmiland.list https://deb.tmiland.com/debian/tmiland.list && \
 curl -SsL https://deb.tmiland.com/debian/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/tmiland-archive-keyring.gpg >/dev/null && \
 sudo apt update && \
 sudo apt install invidious-updater
 ```
 
- Run script with ```invidious_update ```
 
- ***Only for Debian/Ubuntu/LinuxMint/PureOS***


 #### Update Invidious via Cron

**Select option 2 once to manually set GitHub Credentials**

```bash

/path/to/script/invidious_update.sh -c

```
Add job to cron:
```bash
crontab -e
```
```bash
@daily bash /path/to/script/invidious_update.sh -c > /dev/null 2>&1 # Automated Invidious Update
```
