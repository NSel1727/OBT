#!/bin/bash

#
#------------------------------
#
# Import settings
#
# Git branch

. ./settings.sh

# WriteLog() function

. ./timestampLogger.sh

#
#------------------------------
#
# Constants
#

#BUILD_HOME=~/build/CE/platform/build
LONG_DATE=$(date "+%Y-%m-%d_%H-%M-%S")
MEMCACHED_CHECK_LOG_FILE=${OBT_LOG_DIR}/CheckMemcached-${LONG_DATE}.log

tryCount=2

#
#------------------------------
#
# Check the state of Memcached
#

WriteLog "Start Memcached Server check..." "${MEMCACHED_CHECK_LOG_FILE}"

# Check if Memcached installed
if type "memcached" &> /dev/null
then
    while [[ $tryCount -ne 0 ]]
    do
        WriteLog "Try count: ${tryCount}" "${MEMCACHED_CHECK_LOG_FILE}"

        memcachedState=$( ps ax | grep ' [m]emcached -d -u root' )
        if [[ -z $memcachedState ]]
        then
            WriteLog "Stoped! Start it! " "${MEMCACHED_CHECK_LOG_FILE}"
            memcached -d -u root > /dev/null 2>&1
            sleep 20
            tryCount=$(( $tryCount-1 ))
            continue
        else
            WriteLog "It is OK! " "${MEMCACHED_CHECK_LOG_FILE}"
            break
        fi
    done
    
    if [[ $tryCount -eq 0 ]]
    then
        WriteLog "Memcached won't start! Give up and send Email to Agyi! " "${MEMCACHED_CHECK_LOG_FILE}"
        # send email to Agyi
        echo "Memcached won't start! " | mailx -s "Problem with Memcached" -u $USER  ${ADMIN_EMAIL_ADDRESS}
    fi
else
    WriteLog "Memcached not installed in this sysytem! Give up and send Email to Agyi! " "${MEMCACHED_CHECK_LOG_FILE}"
    # send email to Agyi
    echo "Memcached not installed in this sysytem! " | mailx -s "Problem with Memcached" -u $USER  ${ADMIN_EMAIL_ADDRESS}
fi

WriteLog "End of Memcached Server check." "${MEMCACHED_CHECK_LOG_FILE}"
