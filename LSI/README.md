# Zabbix-HW-Raid
megacli_zabbix.pl - script for get any parameters from the MegaRAID  for Zabbix

Using:

*Discovery HD

megacli_zabbix.pl none discovery

*Collecting

megacli_zabbix.pl none collect

*Getting states

megaclizabbix.pl [device] [parameter] [type of output]

device - slot_number:_0 (Hard Drive information) or  virtual_drive:_0 ( Logical device information)

parameter - any parameters from arcconf getconfig  like 'SAS Address' , 'Controller Status' , State and over

type of output - 1 or nothing . If set  1 will receive as row else will receive 0 or 1
