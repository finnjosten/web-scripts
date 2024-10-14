# Web Setup Script

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

