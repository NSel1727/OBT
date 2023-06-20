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
SCRIPTNAME=${0##*/}
CHECK_LOG_FILE=${OBT_BIN_DIR}/${SCRIPTNAME//.sh/}-${LONG_DATE}.log

tryCount=4

# Add "listeners=PLAINTEXT://127.0.0.1:9092" into config/server.proerties
# if there is an exception in java.net.InetAddress.getCanonicalHostName()

KAFKA_DIR=~/kafka_2.12-2.4.0

#
#------------------------------
#
# Check the state of Memcached
#

pwd=$( pwd ) 
WriteLog "Start Kafka Server check" "${CHECK_LOG_FILE}"

WriteLog "Kafka dir: ${KAFKA_DIR}" "${CHECK_LOG_FILE}"

# Check if Kafka installed
if [ -d ${KAFKA_DIR} ]
then
    WriteLog "Kill node_exporter to free port 9092" "${CHECK_LOG_FILE}"
    res=$( [[ -n "$( pgrep -f node_exporter )" ]] && sudo kill -9 $(pgrep -f node_exporter) || echo "Not found" 2>&1)
    WriteLog "Res: ${res}" "${CHECK_LOG_FILE}"
        
    unset -v JAVA_HOME
    WriteLog "JAVA_HOME: '${JAVA_HOME}' " "${CHECK_LOG_FILE}"

    pushd ${KAFKA_DIR}
    cwd=$(pwd)
    WriteLog "cwd: ${cwd}" "${CHECK_LOG_FILE}"

    while [[ $tryCount -ne 0 ]]
    do
        WriteLog "Try count: ${tryCount}" "${CHECK_LOG_FILE}"

        zookeeperState=$( ps ax | egrep -c '[z]ook' )
        if [[ $zookeeperState -eq 0 ]]
        then
            WriteLog "Zookeeper stoped! Start it! " "${CHECK_LOG_FILE}"

            #sudo rm -fr logs
        rm -fr /tmp/zookeeper /tmp/kafka-logs

            bin/zookeeper-server-start.sh config/zookeeper.properties > /dev/null 2>&1 &
            res=$?
            WriteLog "Result: $res" "${CHECK_LOG_FILE}"

            sleep 40
            
        tryCount=$(( $tryCount-1 ))
        continue
        else
            WriteLog "Zookeeper is OK! " "${CHECK_LOG_FILE}"
        fi

        kafkaState=$( ps ax | egrep -c '[k]afka.Kafka' )
        WriteLog "Kafka State: ${kafkaState}." "${CHECK_LOG_FILE}"

        if [[ $kafkaState -eq 0 ]]
        then
            WriteLog "Kafka stoped! Start it! " "${CHECK_LOG_FILE}"

            tryCount=$(( $tryCount-1 ))
            
            #echo "Kill Kafka"
            #ps aux | grep '[k]afka.Kafka' | awk '{ print $2 }' | sort -r | while read id; do echo "id:$id"; kill -9 $id; sleep 10;done 
            WriteLog "Remove kafka-log" "${CHECK_LOG_FILE}"
            rm -rf /tmp/kafka-logs/
            
            #echo "Kill Zookeeper"
            #ps aux | grep '[z]ook' | awk '{ print $2 }' | sort -r | while read id; do echo "id:$id"; kill -9 $id; sleep 10;done
            #rm -fr /tmp/zookeeper
            #echo "Done"
            
            echo "Start Kafka"
        bin/kafka-server-start.sh config/server.properties > /dev/null 2>&1 &
        sleep 40
           
            #kafkaState=$( ps ax | egrep -c '[k]afka.Kafka' )
        #WriteLog "Kafka State: ${kafkaState}." "${CHECK_LOG_FILE}"
        
            #if [[ $kafkaState -eq 0 ]]
            #then
        #    WriteLog "Kafka didn't started. Stop Zookepper, clean=up and try again." "${CHECK_LOG_FILE}"
        #    
        #   WriteLog "Kill Zookeeper" "${CHECK_LOG_FILE}"
        #   res=$( sudo pkill -f zook )
            #   WriteLog "Rs: ${res}" "${CHECK_LOG_FILE}"
            #
            #    #ps aux | grep '[z]ook' | awk '{ print $2 }' | sort -r | while read id; do echo "id:$id"; WriteLog "$(kill -9 $id)" "${CHECK_LOG_FILE}"; sleep 20;done
        #    rm -fr /tmp/zookeeper  /tmp/kafka-log
        #fi
            #continue
        else
            WriteLog "Kafka is OK! " "${CHECK_LOG_FILE}"
            WriteLog "Broker list: $( echo dump | nc localhost 2181 | grep brokers )" "${CHECK_LOG_FILE}"

        break
        fi
        
    done
    
    if [[ $tryCount -eq 0 ]]
    then
        WriteLog "Zookeeper or Kafka doesn't start! Give up and send Email to ${ADMIN_EMAIL_ADDRESS}! " "${CHECK_LOG_FILE}"
        # send email to Agyi
        echo "Zookeeper or Kafka doesn't start! " | mailx -s "Problem with Kafka" -u $USER  ${ADMIN_EMAIL_ADDRESS}
    fi

    popd

else
    WriteLog "Kafka not installed in this sysytem! Give up and send Email to ${ADMIN_EMAIL_ADDRESS}! " "${CHECK_LOG_FILE}"
    # send email to Agyi
    echo "Kafka not installed in this sysytem! " | mailx -s "Problem with Kafka" -u $USER ${ADMIN_EMAIL_ADDRESS}
fi

WriteLog "End of Kafka Server check." "${CHECK_LOG_FILE}"
