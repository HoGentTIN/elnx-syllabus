% The Samba file server
% Enterprise Linux
% HOGENT applied computer science

# Introduction

## Before we begin

Set up the test environment

```console
$ cd elnx-syllabus/demo
$ vagrant up fs
[...]
```

A working VM this time!

## Agenda

- Origin
- Samba on Enterprise Linux
- Main configuration
- Shares

Samba as AD DC is not discussed here

## Origin

- Server Message Block (SMB)
    - Originates with IBM (1980's)
    - Acquired by Microsoft
- Common Internet File System (CIFS)
    - Name for early version of SMB
- Samba: 1992, Andrew Tridgell
    - Reverse engineered through network sniffing!
    - Had reputation of being more stable!

# Samba on Enterprise linux

## Installation

```console
sudo dnf install samba samba-client
sudo systemctl enable --now nmb
sudo systemctl enable --now smb
sudo firewall-cmd --add-service samba
```

## Two services!

- `nmbd`: NetBIOS name server
    - Resolve host names `\\server\share`
- `smbd`
    - File server (Windows Network Neighbourhood)
    - Network printer sharing
    - Active Directory Domain Controller

## Ports

Check with `ss`!

| Service | Port    |
|:--------|:--------|
| NetBIOS | 137/udp |
|         | 138/udp |
| SMB     | 139/tcp |
|         | 445/tcp |

## Getting help

- Man pages: samba(7), nmbd(8), smbd(8), [smb.conf(5)](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html)
- [Samba Wiki](https://wiki.samba.org/index.php/Main_Page)
    - [Setting up Samba as a Standalone Server](https://wiki.samba.org/index.php/Setting_up_Samba_as_a_Standalone_Server)
    - [Samba File Serving](https://wiki.samba.org/index.php/Samba_File_Serving)
- RHEL documentation: [Deploying Different types of servers](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/deploying_different_types_of_servers/index)
    - [Chapter 3: Using Samba as a server](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/deploying_different_types_of_servers/assembly_using-samba-as-a-server_deploying-different-types-of-servers)

# Configuration

## Main configuration

- Location `/etc/samba/smb.conf`
- = INI-file

## Default global settings

```ini
[global]
    workgroup = SAMBA

    security = user
    passdb backend = tdbsam
```

- Standard workgroup name
- User authentication with local database
    - `/var/lib/samba/private/passdb.tdb`

## Printer sharing

```ini
[global]
    printing = cups
    printcap name = cups
    load printers = yes
    cups options = raw
[printers]
    comment = All Printers
    path = /var/tmp
    printable = Yes
    create mask = 0600
    browseable = No
```

---

```ini
[print$]
    comment = Printer Drivers
    path = /var/lib/samba/drivers
    write list = @printadmin root
    force group = @printadmin
    create mask = 0664
    directory mask = 0775
```

## NetBIOS name support

```ini
[global]
  netbios name = files
  workgroup = AVALON
  server string = "Avalon, Inc. file server"

  wins support = yes
  local master = yes
  domain master = yes
  preferred master = yes
```

Test with

- `nmblookup -U 192.168.56.12 files`
- `nmblookup files`

# Shares

## Permissions

Managing (r/w) access to shares is hard!

- Filesystem permissions (users, groups)
- Samba configuration file
- SELinux context

## Recommendation

- Create group for each share
- Assign permissions on group level

## Setup

2 groups, 2 users in each group:

| User    | Group   |
|:--------|:--------|
| sparrow | pirates |
| teach   | pirates |
| fuma    | ninjas  |
| hattori | ninjas  |

Password = username

## Shared directories

```console
# tree /srv/shares/
/srv/shares/
├── cove
│   └── everyone.txt
├── dojo
│   └── ninjas.txt
└── everyone
    └── pirates.txt
```

## Minimal share definition

```ini
[everyone]
    path = /srv/shares/everyone
```

- Read-only
- Access for all authenticated users

## Accessing the share with smbclient

- Show shares: `smbclient -L //server/`
- Log in as alice with password letmein:
    - `smbclient //server/share -Ualice%letmein`
- Guest login:
    - `smbclient //server/share -U%`

## Changing access levels

| Setting             | Purpose          |
|:--------------------|:-----------------|
| browseable          | share is visible |
| valid users         | read access      |
| read only/writeable | write access     |

## Warning! File permissions

- Underlying file permissions must match!
    - UNIX ACLs
- SELinux context should be correct
    - `samba_share_t`
    - `public_content_t`

## Share for ninjas

```ini
[dojo]
    path = /srv/shares/dojo
    valid users = @ninjas
    readonly = no
```

## Managing permissions of new files

```ini
[cove]
    path = /srv/shares/cove
    read only = No
    valid users = @pirates
    force create mode = 0660
    force directory mode = 0770
    force group = pirates
```

# Troubleshooting

## Troubleshooting tips

- Check logs:
    - `journalctl -u nmb.service`
    - `journalctl -u smb.service`
    - `tail -f /var/log/audit/audit.log`
- Check config file syntax: `testparm -s`
- Use `smbclient` instead of Windows file manager
    - Much better error messages
