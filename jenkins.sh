#! /bin/bash

# Logger functions
log_info() {
    echo "INFO: $1"
}

log_warning() {
    echo "WARNING: $1"
}

log_error() {
    echo "ERROR: $1"
}

# Check if Jenkins is installed
if ! command -v jenkins &> /dev/null
then
    log_info "Jenkins not found. Proceeding with installation."

    # Update and Install Prerequisites
    sudo apt-get update
    sudo apt-get install -y python3 curl

    # Install Jenkins
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update
    sudo apt-get install -y jenkins

    # Start Jenkins Service
    sudo systemctl start jenkins
    sudo systemctl enable jenkins

    # Wait for Jenkins to Start
    log_info "Waiting for Jenkins to launch..."
    sleep 30
else
    log_info "Jenkins is already installed. Skipping installation."
fi

# Fetch the IP address and construct the Jenkins URL
ip_address=$(hostname -I | awk '{print $1}')
url="http://${ip_address}:8080"

# Admin credentials
user="admin"
password="22012006@Rr"
encoded_password=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "$password")

# Fetch Jenkins initial admin password
initial_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Encode additional credentials
fullname=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "Admin User")
email=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "admin@example.com")

# Get the crumb and cookie
cookie_jar="$(mktemp)"
full_crumb=$(curl -u "admin:$initial_password" --cookie-jar "$cookie_jar" $url/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))
arr_crumb=(${full_crumb//:/ })
only_crumb=$(echo ${arr_crumb[1]})

# Create an admin user
curl -X POST -u "admin:$initial_password" $url/setupWizard/createAdminUser \
    -H "Connection: keep-alive" \
    -H "Accept: application/json, text/javascript" \
    -H "X-Requested-With: XMLHttpRequest" \
    -H "$full_crumb" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --cookie $cookie_jar \
    --data-raw "username=$user&password1=$encoded_password&password2=$encoded_password&fullname=$fullname&email=$email&Jenkins-Crumb=$only_crumb&json=%7B%22username%22%3A%20%22$user%22%2C%20%22password1%22%3A%20%22$encoded_password%22%2C%20%22password2%22%3A%20%22$encoded_password%22%2C%20%22fullname%22%3A%20%22$fullname%22%2C%20%22email%22%3A%20%22$email%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D"

# Install recommended plugins
curl -X POST -u "$user:$encoded_password" $url/pluginManager/installPlugins \
  -H 'Connection: keep-alive' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H "$full_crumb" \
  -H 'Content-Type: application/json' \
  --cookie $cookie_jar \
  --data-raw "{'dynamicLoad':true,'plugins':['cloudbees-folder','antisamy-markup-formatter','build-timeout','credentials-binding','timestamper','ws-cleanup','ant','gradle','workflow-aggregator','github-branch-source','pipeline-github-lib','pipeline-stage-view','git','ssh-slaves','matrix-auth','pam-auth','ldap','email-ext','mailer'],'Jenkins-Crumb':'$only_crumb'}"

# Configure the Jenkins instance
url_urlEncoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote(input(), safe=''))" <<< "$url")
curl -X POST -u "$user:$encoded_password" $url/setupWizard/configureInstance \
  -H 'Connection: keep-alive' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H "$full_crumb" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --cookie $cookie_jar \
  --data-raw "rootUrl=$url_urlEncoded%2F&Jenkins-Crumb=$only_crumb&json=%7B%22rootUrl%22%3A%20%22$url_urlEncoded%2F%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D&core%3Aapply=&Submit=Save&json=%7B%22rootUrl%22%3A%20%22$url_urlEncoded%2F%22%2C%20%22Jenkins-Crumb%22%3A%20%22$only_crumb%22%7D"
