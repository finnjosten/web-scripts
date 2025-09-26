# v1.0.5

# Check for test mode
TEST_MODE=0
if [[ "$1" == "--test" ]]; then
  TEST_MODE=1
  echo "Running in TEST MODE. All changes will be reverted at the end."
fi

# Create a cleanup function for test mode
cleanup() {
  read -p "Press Enter to continue with cleanup or Ctrl+C to exit without cleanup..."

  if [ $TEST_MODE -eq 0 ]; then
    return
  fi

  echo "Cleaning up test mode changes..."
  
  # Remove nginx config if created
  if [[ -n "$conf_file" && -f "$conf_file" ]]; then
    rm -f "$conf_file"
    echo "Removed nginx config: $conf_file"
  fi
  
  # Remove PHP-FPM config if created
  if [[ -n "$php_conf_file" && -f "$php_conf_file" ]]; then
    rm -f "$php_conf_file" 
    echo "Removed PHP-FPM config: $php_conf_file"
  fi
  
  # Remove web directories if created
  if [[ -n "$vhost_dir" && -d "$vhost_dir" ]]; then
    rm -rf "$vhost_dir"
    echo "Removed web directory: $vhost_dir"
  fi
  
  # Remove user if created
  if [[ -n "$username" ]]; then
    if id "$username" &>/dev/null; then
      userdel -r "$username"
      echo "Removed user: $username"
    fi
  fi

  echo "Cleanup complete. No changes were permanently made."
}

read -rp "Enter username: " username
read -rp "Enter WWW path (from /var/www/ starting / not needed): " wwwpath
read -rp "Enter domain name (e.g., example.com): " domain

# If wwwpath starts with /, remove it
if [[ "$wwwpath" == /* ]]; then
  wwwpath="${wwwpath#/}"
fi
wwwpath="/var/www/$wwwpath"

# Create user
useradd -m -s /bin/bash "$username"

usermod -aG pm2users "$username"
usermod -aG webusers "$username"

# Setup home directory files
homedir="/home/$username"
cd "$homedir" || exit

touch .web-user
mkdir -p .ssh
touch .ssh/authorized_keys
chown -R "$username:$username" .ssh

# Write .bashrc
cat > .bashrc <<EOF
export WWW_PATH="$wwwpath"
export USERNAME="$username"

# Custom aliases
alias ll='ls -la'
alias ..='cd ..'
alias www="cd \$WWW_PATH"
alias httpdocs="www && cd httpdocs"
alias logs="www && cd logs"

alias pmc2='sudo /usr/local/bin/pmc2'
alias webserver='sudo /usr/local/bin/webserver'

# Set custom PS1
export PS1='\\[\\e[0;32m\\]\\u@\\h\\[\\e[m\\] \\[\\e[1;34m\\]\\w\\[\\e[m\\] \\[\\e[1;32m\\]\\$\\[\\e[m\\] '

# Set default editor
export EDITOR=nano

# Set larger history
export HISTSIZE=10000
export HISTFILESIZE=10000

# Ignore duplicate commands in history
export HISTCONTROL=ignoreboth

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

httpdocs
clear
EOF

chown "$username:$username" .bashrc

su - $username -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
su - $username -c "nvm install node && nvm use node && nvm alias default node"

# Setup /var/www/vhost/$username/www
vhost_dir="$wwwpath"
mkdir -p "$vhost_dir"

cd "$vhost_dir" || exit

# Check httpdocs folder and contents
if [ ! -d "httpdocs" ]; then
  # httpdocs doesn't exist, check if folder is empty or has files
  if [ "$(ls -A)" ]; then
    mkdir httpdocs
    mv * httpdocs/
  else
    mkdir httpdocs
  fi
else
  # httpdocs exists, check if empty and folder has other files
  if [ ! "$(ls -A httpdocs)" ] && [ "$(ls -A | grep -v '^httpdocs$')" ]; then
    mv $(ls -A | grep -v '^httpdocs$') httpdocs/
  fi
fi

# Check logs folder
logs_dir="$vhost_dir/logs"
mkdir -p "$logs_dir"
cd "$logs_dir" || exit
touch {access,error,php_error}.log
chown -R "$username:$username" "$vhost_dir"

# Check nginx
nginx_dir="$vhost_dir/config"
mkdir -p "$nginx_dir"
cd "$nginx_dir" || exit

conf_dir="/etc/nginx/sites-enabled"
conf_file="$conf_dir/$domain.conf"

# check if nginx config file already exists
if [ -f "$conf_file" ]; then
  echo "Nginx configuration file for $domain already exists."
else
  # Create Nginx config file
  cat > "$conf_file" <<EOF
# Once cerbot is good for domain {$domain} uncomment the following lines (search for: #-) and remove this comment then remove the last server block in the file
#-server {
#-    set \$env_dev 0;
#-    server_name $domain www.$domain;
#-    
#-    root $wwwpath/httpdocs/;
#-    index index.php;
#-
#-    access_log $wwwpath/logs/access.log;
#-    error_log $wwwpath/logs/error.log;
#-
#-    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
#-
#-    location / {
#-        try_files \$uri \$uri/ /index.php?\$query_string;
#-    }
#-
#-    location ~ \.php$ {
#-        include snippets/fastcgi-php.conf;
#-        fastcgi_pass unix:/var/run/php/php$PHP_VERSION-fpm-$username.sock;
#-        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
#-        include fastcgi_params;
#-    }
#-
#-    client_max_body_size 15G;
#-    
#-    include snippets/filelist.conf;
#-
#-    listen [::]:443 ssl; # managed by Certbot
#-    listen 443 ssl; # managed by Certbot
#-    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem; # managed by Certbot
#-    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem; # managed by Certbot
#-    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
#-    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
#-}
#-
# www to non-www redirect for HTTPS
#-server {
#-    if (\$host = www.$domain) {
#-        return 301 https://$domain\$request_uri;
#-    } # managed by Certbot
#-
#-    listen 443 ssl;
#-    listen [::]:443 ssl;
#-    
#-    server_name www.$domain;
#-    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
#-    
#-    ssl_certificate /etc/letsencrypt/live/www.$domain/fullchain.pem;
#-    ssl_certificate_key /etc/letsencrypt/live/www.$domain/privkey.pem;
#-    include /etc/letsencrypt/options-ssl-nginx.conf;
#-    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
#-}
#-
# HTTP redirects
#-server {
#-    if (\$host = $domain) {
#-        return 301 https://$domain\$request_uri;
#-    } # managed by Certbot
#-    if (\$host = www.$domain) {
#-        return 301 https://$domain\$request_uri;
#-    } # managed by Certbot
#-
#-    listen 80;
#-    listen [::]:80;
#-
#-    server_name $domain www.$domain;
#-    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
#-}

server {
  listen 80;
  listen [::]:80;
  server_name $domain www.$domain;

  location / {
    return 404;
  }
}
EOF

  ln -s "$conf_file" "$wwwpath/config/nginx.conf"

  # Test Nginx configuration
  if ! nginx -t; then
    echo "Nginx configuration test failed. Please check the configuration."
    echo "DO NOT RELOAD NGINX UNTIL THE ISSUE IS FIXED!"
    if [ $TEST_MODE -eq 1 ]; then
      cleanup
      exit 1
    fi
  else
    echo "Nginx configuration file created successfully."
  
    # Only actually reload nginx if not in test mode
    if [ $TEST_MODE -eq 0 ]; then
      systemctl restart nginx
    else
      echo "Test mode: Would have reloaded nginx here"
    fi
  fi
fi

# Create PHP-FPM pool config
conf_dir="/etc/php/$PHP_VERSION/fpm/pool.d"
php_conf_file="$conf_dir/$username.conf"

cat > "$php_conf_file" <<EOF
[$username]
user = $username
group = $username
listen = /run/php/php$PHP_VERSION-fpm-$username.sock
listen.owner = $username
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 2
pm.max_spare_servers = 5

php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[display_errors] = off

; Set up logging
php_admin_flag[log_errors] = on
php_admin_value[error_log] = ${wwwpath}logs/php_error.log

; Set resource limits
php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 60
php_admin_value[max_input_time] = 60
php_admin_value[post_max_size] = 64M
php_admin_value[upload_max_filesize] = 64M
EOF


ln -s "$php_conf_file" "$wwwpath/config/php.conf"

# Restart PHP-FPM if not in test mode
if [ $TEST_MODE -eq 0 ]; then
  systemctl restart php$PHP_VERSION-fpm
  echo "Setup complete for user $username."
else
  echo "Test mode: Would have restarted php$PHP_VERSION-fpm here"
  echo "Test completed successfully for user $username."
  
  # Clean up all changes in test mode
  cleanup
fi
