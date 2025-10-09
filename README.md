# Web Setup Script


## Web user script

Automatically create a webuser with a premade php FPM config and nginx site config for the site. Also add an directory for the website to be in (usually put in `/var/www/vhost/{domain}` but you can choice anywhere from `/var/www`)

Best used as follows:
- Create a folder in `/opt` (mine is `admin-scripts`)
- Create a new script called `web-user.sh`
- Paste this in it
```BASH
#!/bin/bash
PHP_VERSION="8.4"

TMP_SCRIPT=$(mktemp)
curl -s -o "$TMP_SCRIPT" https://raw.githubusercontent.com/finnjosten/web-scripts/refs/heads/main/web-user.sh
bash "$TMP_SCRIPT" --php "$PHP_VERSION"
rm -f "$TMP_SCRIPT"
```


## Web user script groups

Auto assign certain groups to all the users with .web-user in their home dir (this file is default added with the above script). User can be skipped by adding .web-user-ignore-groups

Best used as follows:
- Create a folder in `/opt` (mine is `admin-scripts`)
- Create a new script called `web-user-groups.sh`
- Paste this in it
```BASH
#!/bin/bash

TMP_SCRIPT=$(mktemp)
curl -s -o "$TMP_SCRIPT" https://raw.githubusercontent.com/finnjosten/web-scripts/refs/heads/main/web-user-groups.sh
bash "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"
```


## Web user script groups

Auto set all the ssh keys to all the users with .web-user in their home dir (this file is default added with the above script). User can be skipped by adding .web-user-ignore-keys

Best used as follows:
- Create a folder in `/opt` (mine is `admin-scripts`)
- Create a new script called `web-user-groups.sh`
- Create a new file called `clone_keys` in the same folder the script, in here place all the ssh keys you need.
- Paste this in it
```BASH
#!/bin/bash

TMP_SCRIPT=$(mktemp)
curl -s -o "$TMP_SCRIPT" https://raw.githubusercontent.com/finnjosten/web-scripts/refs/heads/main/web-user-keys.sh
bash "$TMP_SCRIPT"
rm -f "$TMP_SCRIPT"
```


## SETUP SCRIPT IS OUTDATED!!!!

This script automates the setup of various web projects, including Laravel, React, Docker, and plain static sites. It handles directory creation, project initialization, and Nginx configuration, including SSL setup via Certbot.

## Features

- **Project Types Supported**:
  - Laravel
  - React
  - Docker
  - Plain site (for example plain html or simple php site)
- **GitHub Integration**: Clone repositories if a GitHub link is provided.
- **Dynamic Directory Creation**: Automatically creates directories based on the project type and domain.
- **Nginx Configuration**: Generates and sets up Nginx configurations for each project type.
- **SSL Setup**: Uses Certbot to set up SSL for your domain.
- **File Existence Check**: Warns if files already exist in the target directory and offers options to keep or delete them.

## Prerequisites

- Ensure you have the following installed:
  - **Nginx**
  - **PHP** 8.0 or higer (for Laravel and plain sites)
  - **Composer** (for Laravel)
  - **Node.js** and **npm** (for React)
  - **Git** (for cloning repositories)
  - **GitHub CLI** (`gh`) if you want to clone a private repository.
  - **Certbot** (for SSL)

## Usage
   You can run the script directly from the GitHub repository using `curl` or `wget`:

   ```bash
   # Using curl
   bash <(curl -s https://raw.githubusercontent.com/BlackSparowYT/web-setup-script/refs/heads/main/setup-script.sh)

   # Using wget
   bash <(wget -qO- https://raw.githubusercontent.com/BlackSparowYT/web-setup-script/refs/heads/main/setup-script.sh)
  ```

## Flow chart
here you can view the flow of the script, if the script errors and asks you to continue manually you can refer to this.

