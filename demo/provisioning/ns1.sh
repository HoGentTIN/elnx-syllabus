#! /usr/bin/env bash
#
# Installs and configures MariaDB

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
  # Ensure vagrant can read logs without sudo
  usermod --append --groups adm vagrant

  install_packages
  enable_selinux
  start_basic_services

  setup_bind
}

#{{{ Helper functions

install_packages() {

  info "Installing packages"

  yum install -y epel-release
  yum install -y \
    audit \
    bash-completion \
    bind \
    bind-utils \
    git \
    nano \
    pciutils \
    psmisc \
    python3-policycoreutils \
    tcpdump \
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
  systemctl start auditd.service
  systemctl restart network.service
  systemctl start firewalld.service
}

setup_bind() {
  info "Starting BIND"
  systemctl enable named.service
  firewall-cmd --add-service=dns
  firewall-cmd --add-service=dns --permanent

  cp /vagrant/provisioning/dns/named.conf /etc/
  cp /vagrant/provisioning/dns/example.com /var/named
  cp /vagrant/provisioning/dns/*.in-addr.arpa /var/named

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

