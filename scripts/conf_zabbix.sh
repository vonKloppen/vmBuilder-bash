#!/bin/bash

sed -i 's/Hostname=Zabbix\ server/Hostname='$(hostname)'/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Server=127.0.0.1/Server=ZABBIX_SERVER/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=ZABBIX_SERVER:11051/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/LogFileSize=0/LogFileSize=10/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/#\ ListenPort=10050/ListenPort=11050/' /etc/zabbix/zabbix_agentd.conf

