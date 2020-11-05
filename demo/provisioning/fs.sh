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

  configure_fileserver
}

#{{{ Helper functions

install_packages() {

  log "Installing packages"

  dnf install -y epel-release
  dnf install -y \
    audit \
    bash-completion \
    bind-utils \
    cockpit \
    cockpit-dashboard \
    git \
    multitail \
    python3-policycoreutils \
    pciutils \
    psmisc \
    samba \
    samba-client \
    tree \
    vim-enhanced
}

enable_selinux() {
  if [ "$(getenforce)" != 'Enforcing' ]; then
    log "Enabling SELinux"
    # Enable SELinux right now
    setenforce 1
    # Make the change permanent
    sed -i 's/^SELINUX=[a-z]*$/SELINUX=enforcing/' /etc/selinux/config
  fi
}

start_basic_services() {
  log "Starting essential services"

  systemctl enable --now auditd.service
  systemctl enable --now firewalld.service
  systemctl enable --now cockpit.socket
  firewall-cmd --add-service=cockpit
  firewall-cmd --add-service=cockpit --permanent
}

# Usage: is_group GROUP_NAME
#  Checks whether the specified group is present on the system and returns exit
#  status 0 if it is.
is_group() {
  group_name="${1}"
  getent group "${group_name}" > /dev/null 2>&1
}

# Usage: ensure_groups_present [GROUP]...
#  Creates the specified groups if necessary
ensure_groups_present() {
  while [ "$#" -gt '0' ]; do
    group_name="${1}"
    if ! is_group "${group_name}"; then
      debug "Creating group ${group_name}"
      groupadd "${group_name}"
    fi
    shift
  done
}

# Usage: is_user USER_NAME
#  Checks whether the specified user is present on the system and returns exit
#  status 0 if it is.
is_user() {
  user_name="${1}"
  getent passwd "${user_name}" > /dev/null 2>&1
}

# Usage: ensure_user_present USER PASSWORD GROUP[,GROUP]...
#  Creates the specified user, if they don't exist yet.
#  Also initialises the password and assigns supplementary groups
#  Specify multiple groups separated with commas and no spaces:
#     group1,group2,group3...
ensure_user_present() {
  user_name="${1}"
  password="${2}"
  groups="${3}"
  if ! is_user "${user_name}"; then
    debug "Adding user ${user_name}"
    useradd -g users -G "${groups}" "${user_name}"
    passwd --stdin "${user_name}" <<< "${password}"
    printf '%s\n%s\n' "${password}" "${password}"\
      | smbpasswd -a "${user_name}"
  fi
}

configure_fileserver() {
  log "Enabling services, firewall"
  cp /vagrant/provisioning/fs/smb.conf /etc/samba/smb.conf
  systemctl enable --now nmb
  systemctl enable --now smb
  firewall-cmd --add-service samba --permanent
  firewall-cmd --add-service samba-client --permanent
  firewall-cmd --reload

  log "Creating users and groups"
  ensure_groups_present pirates ninjas
  ensure_user_present teach teach pirates
  ensure_user_present sparrow sparrow pirates
  ensure_user_present hattori hattori ninjas
  ensure_user_present fuma fuma ninjas

  log "Creating share directories"
  if [ ! -d /srv/shares ]; then
    mkdir -p /srv/shares/{everyone,cove,dojo}
  fi
  echo "Share for everyone" > /srv/shares/everyone/everyone.txt
  echo "A place for pirates to hang out" > /srv/shares/cove/pirates.txt
  echo "This is where ninjas train their skills" > /srv/shares/dojo/ninjas.txt

  chown -R root:users /srv/shares/everyone
  chown -R root:pirates /srv/shares/cove
  chown -R root:ninjas /srv/shares/dojo
  chmod 775 /srv/shares/everyone
  chmod 775 /srv/shares/cove
  chmod 770 /srv/shares/dojo
  # chcon -R -t samba_share_t /srv/shares/
}

# Usage: log [ARG]...
#
# Prints all arguments on the standard output stream
log() {
  printf '\e[0;33m>>> %s\e[0m\n' "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  printf '\e[0;36m### %s\e[0m\n' "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf '\e[0;31m!!! %s\e[0m\n' "${*}" 1>&2
}
#}}}

main "${@}"

