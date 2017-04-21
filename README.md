# Zabbix-HW-Raid
arcconf_zabbix.pl - script for geting any parameters from the adaptec raid card for Zabbix

Using:

arcconf_zabbix.pl [device] [parametr] [type of output]
device - device_X  like device_1
parametr - any parameters from arcconf getconfig  like 'SAS Address'
type of output - 1 or nothing . If set as 1 receive as row else receive 0 or 1