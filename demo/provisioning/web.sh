#! /usr/bin/env bash
#
# Installs a simple LAMP stack

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

#}}}

main() {
  install_packages
  enable_selinux
  start_basic_services
  setup_networking

  configure_webserver
}

#{{{ Helper functions

install_packages() {

  info "Installing packages"

  dnf install -y epel-release
  dnf install -y \
    audit \
    bash-completion \
    bind-utils \
    cockpit \
    cockpit-dashboard \
    git \
    httpd \
    mod_ssl \
    multitail \
    mysql \
    python3-policycoreutils \
    php \
    php-mysqlnd \
    pciutils \
    psmisc \
    tree \
    vim-enhanced
}

enable_selinux() {
  if [ "$(getenforce)" != 'Enforcing' ]; then
    info "Enabling SELinux"
    # Enable SELinux right now
    setenforce 1
    # Make the change permanent
    sed -i 's/^SELINUX=[a-z]*$/SELINUX=enforcing/' /etc/selinux/config
  fi
}

start_basic_services() {
  info "Starting essential services"

  systemctl enable --now auditd.service
  systemctl enable --now firewalld.service
  systemctl enable --now cockpit.socket
  firewall-cmd --add-service=cockpit
  firewall-cmd --add-service=cockpit --permanent
}

setup_networking() {
  # the name of the last network interface when calling `ip l`
  last_interface=$(ip l | grep '^[0-9]' | awk '{ print $2; }' | tail -1 | tr -d ':')
  iface_status=$(nmcli dev status | grep "${last_interface}" | awk '{print $3}')

  if [ "${iface_status}" = 'connected'  ]; then
    nmcli dev disconnect "${last_interface}"
  fi
}

configure_webserver() {
  info "Installing test page"
  cp /vagrant/www/test.php /home/vagrant
  cp /vagrant/www/test.php /var/www/html
  chcon -t user_home_t /var/www/html/test.php

  info "Installing script for showing web server logs"
  cp /vagrant/provisioning/web/showlogs.sh /home/vagrant
  chown vagrant:vagrant /home/vagrant/showlogs.sh

  info "Setting port number"
  sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
}

# Color definitions
readonly reset='\e[0m'
readonly cyan='\e[0;36m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  printf "${cyan}### %s${reset}\\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\\n" "${*}" 1>&2
}
#}}}

main "${@}"

