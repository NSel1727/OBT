#!/bin/bash

hpccRunning=$( sudo service hpcc-init status | grep -c "running")
echo $hpccRunning' running component(s)'
if [[ $hpccRunning -ne 0 ]]
then
    #sudo /etc/init.d/hpcc-init status | cut -s -d' '  -f1
    echo "Stop HPCC System..."
    res=$(sudo service hpcc-init stop |grep 'still')
    # If the result is "Service dafilesrv, mydafilesrv is still running."
    if [[ -n $res ]]
    then
        echo $res
        sudo service dafilesrv stop
    fi
else
    echo "HPCC System already stopped."
fi

# give it some time
#sleep 5

hpccRunning=$( sudo service hpcc-init status | grep -c "running")
if [[ $hpccRunning -ne 0 ]]
then
    echo $hpccRunning" components are still up!"
    exit -1
else
    echo "All components are down!"
fi

