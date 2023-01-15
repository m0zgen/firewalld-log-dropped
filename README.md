# Firewalld log dropped

* Enable / Disable Firewalld DROP, REJECT logs in to:
```
/var/log/firewalld.log
```

* Enable / Disable logrotate for `firewalld.log`:
```
/etc/rsyslog.d/firewalld.conf
```

## Usage

With:
* `-e` - enable logging
* `-d` - disable logging