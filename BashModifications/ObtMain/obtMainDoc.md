## Commented Code Removals

Line 12:
```
#. ~/.bash_profile
```

Line 84:
```
#echo "param:'"$1"'"
```

Lines 209-210:
```
#./archiveLogs.sh obt-cleanup timestamp=${OBT_TIMESTAMP}
                #exit -1
```
                
Line 280:
```
#(fn="myPortUsage-"$( date "+%Y-%m-%d_%H-%M-%S" )".log"; while true; do echo $( date "+%y.%m.%d %H:%M:%S" ) >> ${fn}; sudo ss -antp4 >> ${fn}; echo -e "------------------------------------------\n" >> ${fn}; sleep 1; done ) &
```

Line 290:
```
#(fn="myPortUsage-"$( date "+%Y-%m-%d_%H-%M-%S" )".log"; while true; do echo $( date "+%y.%m.%d %H:%M:%S" ) >>$
```

Line 304:
```
#cd $TEST_ROOT
```

Lines 369-372:
```
# send email to Agyi
                #echo "After the kill Cassandra the OBT Free memory $( GetFreeMemGB ) is still too low!" | mailx -s "OBT Memory problem" -u $USER  ${ADMIN_EMAIL_ADDRESS}

                #ExitEpilog
```
                
Lines 430-432:
```
#WriteLog "Try to kill Couchbase" "${OBT_LOG_FILE}" 
#killCouchbase=$( sudo /opt/couchbase/bin/couchbase-server -k )
#WriteLog "Couchbase result:${killCouchbase}" "${OBT_LOG_FILE}"
```
                
Lines 638-640:
```
#if [ $RUN_UNITTESTS -ne 1 ]
                #then
                    # Unit tests doesn't run, so archive build logs now
```

Line 643:
```
#fi
```

Lines 787-807:
```
#    if [ ! -e ${TARGET_DIR}/test/ML ]
#    then
#        WriteLog "Create ${TARGET_DIR}/test/ML directory..." "${OBT_LOG_FILE}"
#        mkdir -p ${TARGET_DIR}/test/ML
#    fi

#    # Copy test summary to Wiki
#    WriteLog "Copy ML test result files from ${LOG_DIR} to ${TARGET_DIR}..." "${OBT_LOG_FILE}"
#
#    WriteLog "--->${LOG_DIR}/ml-....log" "${OBT_LOG_FILE}"
#    WriteLog "--->$(ls -l ${LOG_DIR}/ )" "${OBT_LOG_FILE}"
#    res=$( cp -v ${LOG_DIR}/ml-*.log ${TARGET_DIR}/test/  2>&1 )
#    WriteLog "---->res:${res}" "${OBT_LOG_FILE}"
#
#    WriteLog "--_>mltests.summary" "${OBT_LOG_FILE}"
#    res=$( cp -v mltests.summary ${TARGET_DIR}/test/mltests.summary 2>&1 )
#    WriteLog "---->res:${res}" "${OBT_LOG_FILE}"
#    
# To-DO Should check it there is any ZAP file
#WriteLog "  ZAP file(s)" "${OBT_LOG_FILE}"
#cp ${ZAP_DIR}/* ${TARGET_DIR}/test/ZAP/
```

Lines 839-840:
```
# Remove old builds
#${BUILD_DIR}/bin/clean_builds.sh
```

Line 1045:
```
#./calcTrend2.py -d ../../Perfstat/ ${PERF_CALCTREND_PARAMS} >> "${OBT_LOG_FILE}" 2>&1
```
                
Line 1122:
```
#res=$( find ${STAGING_DIR_ROOT} -maxdepth 2 -mtime +${WEB_LOG_ARCHIEVE_DIR_EXPIRE} -type d -print 2>&1 )
```

Lines 1131-1132:
```
# send email to Agyi
    #echo "On $OBT_DATESTAMP $OBT_TIMESTAMP the value of WEB_LOG_ARCHIEVE_DIR_EXPIRE is:${WEB_LOG_ARCHIEVE_DIR_EXPIRE} is smaller than the expected on $OBT_SYSTEM ($BRANCH_ID)" | mailx -s "OBT WEB_LOG_ARCHIEVE_DIR_EXPIRE problem" -u $USER  ${ADMIN_EMAIL_ADDRESS}
```
    
## Other Changes

Make Functions to Reduce Code:

```
WriteLogHelper()
{
    WriteLog "                            " "${OBT_LOG_FILE}"   
    WriteLog "***********************" "${OBT_LOG_FILE}"
    WriteLog $1 "${OBT_LOG_FILE}"
    WriteLog "                            " "${OBT_LOG_FILE}"   
}
```
```
WriteLogHelper " Skip build HPCC Platform..."
```

```
UpdateBN()
{
    cp -f ./BuildNotification.ini ./BuildNotification.bak
    sed $1 $2 ./BuildNotification.ini > ./BuildNotification.tmp && mv -f ./BuildNotification.tmp ./BuildNotification.ini
}
```
```
UpdateBN "-e" '/# Gen\(.*\)/d' -e '/# Upd\(.*\)/d' -e '/^BuildBranch : \(.*\)/c # Updated by OBT @ '"$( date '+%Y-%m-%d %H:%M:%S' )"' \nBuildBranch : '${BRANCH_ID}
```

```
UpdateRPTR()
{
    cp -f ./ReportPerfTestResult.ini ./ReportPerfTestResult.bak
    sed $1 $2 ./ReportPerfTestResult.ini > ./ReportPerfTestResult.tmp && mv -f ./ReportPerfTestResult.tmp ./ReportPerfTestResult.ini
}
```
```
UpdateRPTR "e" '/# Gen\(.*\)/d' -e '/# Upd\(.*\)/d' -e '/^BuildBranch : \(.*\)/c # Updated by OBT @ '"$( date '+%Y-%m-%d %H:%M:%S' )"' \nBuildBranch : '${BRANCH_ID}
```

Remove Cassandra Part:
```
#
#----------------------------------------------------
#
# Kill Cassandra if it used too much memory
#
```
```
freeMem=$( GetFreeMem )

# Limit in kByte
MEMORY_LIMIT_GB=3
MEMORY_LIMIT=$(( $MEMORY_LIMIT_GB * (2 ** 20) ))


if [[ $freeMem -lt ${MEMORY_LIMIT} ]]
then
    cassandraPID=$( ps ax  | grep '[c]assandra' | awk '{print $1}' )

    if [[ -n "$cassandraPID" ]]
    then

        WriteLog "Free memory too low, kill Cassandra (pid: ${cassandraPID})" "${OBT_LOG_FILE}"

        sudo kill -9 ${cassandraPID}
        sleep 20

        freeMem=$( GetFreeMem )

        if [[ $freeMem -lt ${MEMORY_LIMIT} ]]
        then
            WriteLog "The free memory $( GetFreeMemGB ) is too low!" "${OBT_LOG_FILE}"
        else
            WriteLog "The free memory is $( GetFreeMemGB )." "${OBT_LOG_FILE}"
        fi
    else
        WriteLog "Cassandra doesn't run but the free memory ($( GetFreeMemGB )) is too low!" "${OBT_LOG_FILE}"

        WriteLog "Try to kill Kafka and zookeeper" "${OBT_LOG_FILE}" 
        killKafka=$( ps ax | grep '[K]afka' | awk '{print $1 }' | while read pid; do echo "kill $pid"; sudo kill -9 $pid; done; )
        WriteLog "${killKafka}" "${OBT_LOG_FILE}"
        sleep 20

        killZookeeper=$( ps ax | grep '[z]ook' | awk '{print $1 }' | while read pid; do echo "kill $pid"; sudo kill -9 $pid; done; )
        WriteLog "${killZookeeper}" "${OBT_LOG_FILE}"
        sleep 20

        rm -fr /tmp/zookeeper /tmp/kafka-log

        WriteLog "The free memory is $( GetFreeMemGB )!" "${OBT_LOG_FILE}"
    fi

    clearOsCache=$( free; sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches; free )
    WriteLog "Clear Os cache result:\n${clearOsCache}" "${OBT_LOG_FILE}"

    WriteLog "The free memory is $( GetFreeMemGB )!" "${OBT_LOG_FILE}"

fi

cassandraPID=$( ps ax  | grep '[c]assandra' | awk '{print $1}' )

if [[ -n "$cassandraPID" ]]
then

    WriteLog "Try to kill Cassandra (pid: ${cassandraPID})" "${OBT_LOG_FILE}"

    sudo kill -9 ${cassandraPID}
    sleep 20

    WriteLog "The free memory is $( GetFreeMemGB )!" "${OBT_LOG_FILE}"
fi
```
