#! /usr/bin/env bash
#
# Show the most important log files for a webserver using multitail
#
# 1/ journalctl output for the httpd service
# 2/ Apache access log
# 3/ Apache error log
#
# Each log is shown with the appropriate color scheme (-cS option)
#
journalctl --full --follow --unit=httpd.service | \
  multitail -cS syslog -j \
    -cS apache -i /var/log/httpd/access_log \
    -cS apache_error -i /var/log/httpd/error_log
