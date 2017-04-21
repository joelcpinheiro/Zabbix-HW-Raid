# Zabbix-HW-Raid
aacraid_zabbix.pl - script for get any parameters from the Adaptec RAID  for Zabbix

Using:

*Discovery HD
aacraid_zabbix.pl none discovery

*Collecting
aacraid_zabbix.pl none collect

*Getting states
aacraid_zabbix.pl [device] [parameter] [type of output]

device - device_X   as device_1 (Hard Drive information) or ad (Adapter information) or ld ( Logical device information)

parameter - any parameters from arcconf getconfig  like 'SAS Address' , 'Controller Status' , State and over

type of output - 1 or nothing . If set  1 will receive as row else will receive 0 or 1
