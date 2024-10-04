#### Download and execute the script

For latest release

```bash
curl -s https://api.github.com/repos/tmiland/Invidious-Updater/releases/latest \
| grep "browser_download_url.*sh" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
```

```bash
chmod +x invidious_update.sh
./invidious_update.sh
```
Or directly

```bash
curl -sSL https://github.com/tmiland/Invidious-Updater/releases/latest/download/invidious_update.sh | bash
```

For master branch
```bash
wget https://github.com/tmiland/Invidious-Updater/raw/master/invidious_update.sh
chmod +x invidious_update.sh
./invidious_update.sh
```
### Repository

 ```shell
 sudo curl -SsL -o /etc/apt/sources.list.d/tmiland.list https://deb.tmiland.com/debian/tmiland.list
 ```

 ```shell
 curl -SsL https://deb.tmiland.com/debian/KEY.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/tmiland-archive-keyring.gpg >/dev/null
 ```

 ```shell
 sudo apt update
 ```
 
 ```shell
 sudo apt install invidious-updater
 ```
 
- Run script with ```invidious_update ```
 
- ***Only for Debian/Ubuntu/LinuxMint/PureOS***

#### Check for script update (Default "no")

 ```bash
 
 ./invidious_update.sh -u
 
 ```
 
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

***Note: you will be prompted to enter root password***

If root password is not set, type:

```bash
sudo passwd root
```

#### Install inv sig helper
This option will install [inv_sig_helper](https://github.com/iv-org/inv_sig_helper)
```bash

/path/to/script/invidious_update.sh -i

```

#### Update YouTube trusted session generator
This option will install [YouTube trusted session generator](https://github.com/iv-org/youtube-trusted-session-generator)
```bash

/path/to/script/invidious_update.sh -y

```
Add job to cron to periodically update po_token and visitor_data:
```bash
crontab -e
```
```bash
@daily bash /path/to/script/invidious_update.sh -y > /dev/null 2>&1 # Automated YouTube trusted session generator update
```