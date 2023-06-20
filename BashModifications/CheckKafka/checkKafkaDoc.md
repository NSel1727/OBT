## Removed Commented Code

Line 22:
```
#BUILD_HOME=~/build/CE/platform/build
```

Line 68:
```
#sudo rm -fr logs
```

Lines 92-93:
```
#echo "Kill Kafka"
#ps aux | grep '[k]afka.Kafka' | awk '{ print $2 }' | sort -r | while read id; do echo "id:$id"; kill -9 $id; sleep 10;done
```
              
Lines 97-100:
```
#echo "Kill Zookeeper"
#ps aux | grep '[z]ook' | awk '{ print $2 }' | sort -r | while read id; do echo "id:$id"; kill -9 $id; sleep 10;done
#rm -fr /tmp/zookeeper
#echo "Done"
```
               
Lines 106-120:
```
#kafkaState=$( ps ax | egrep -c '[k]afka.Kafka' )
#WriteLog "Kafka State: ${kafkaState}." "${CHECK_LOG_FILE}"

#if [[ $kafkaState -eq 0 ]]
    #then
#    WriteLog "Kafka didn't started. Stop Zookepper, clean=up and try again." "${CHECK_LOG_FILE}```
#    
#   WriteLog "Kill Zookeeper" "${CHECK_LOG_FILE}"
#   res=$( sudo pkill -f zook )
    #   WriteLog "Rs: ${res}" "${CHECK_LOG_FILE}"
    #
    #    #ps aux | grep '[z]ook' | awk '{ print $2 }' | sort -r | while read id; do echo "id:$id"; WriteLog "$(kill -9 $id)" "${CHECK_LOG_FILE}"; sleep 20;done
#    rm -fr /tmp/zookeeper  /tmp/kafka-log
#fi
    #continue
```
                    
## Other Changes

Add Consistent Snake Case:

SCRIPTNAME -> SCRIPT_NAME
tryCount -> TRY_COUNT
zookeeperState -> ZOOKEEPER_STATE
kafkaState -> KAFKA_STATE
