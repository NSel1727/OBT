## Commented Code Removals

Line 3:
```
#echo "param:'$1'"
```

Line 38:
```
#TEST_ROOT=${BUILD_DIR}/CE/platform
```

Lines 66-78:
```
#if [[ "${SYSTEM_ID}" =~ "Ubuntu" ]]
#then
#    HPCC_SERVICE="${SUDO} /etc/init.d/hpcc-init"
#    DAFILESRV_STOP="${SUDO} /etc/init.d/dafilesrv stop"
#else
#    #HPCC_SERVICE="${SUDO} service hpcc-init"
#    #DAFILESRV_STOP="${SUDO} service dafilesrv stop"
#    HPCC_SERVICE="${SUDO} /etc/init.d/hpcc-init"
#    DAFILESRV_STOP="${SUDO} /etc/init.d/dafilesrv stop"
#fi

#STATUS_HPCC="${SUDO} service hpcc-init status | grep -c 'running'"
#NUMBER_OF_RUNNING_HPCC_COMPONENT="${SUDO} service hpcc-init status | wc -l "
```

Line 169:
```
#rm -rf ${PERF_TEST_ROOT}/*
```

Lines 235-236:
```
#res=$( ${CMD} 2>&1 )
                #WriteLog "build result:${res}" "${ML_TEST_LOG}"
```
                
Line 271:
```
#HPCC_PACKAGE=$(find . -maxdepth 1 -name 'hpccsystems-platform-community*' -type f | sort -r | head -n 1 )
```

Lines 394-409:
```
#
    #---------------------------
    #
    # Kill Couchbase server if running and ecessary
    #
    #  ps aux | grep '[c]ouchbase'
    #  sudo /opt/couchbase/bin/couchbase-server -k 
    #
    #WriteLog "Check HPCC Systems on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"

    #
    #---------------------------
    # Patch environment.conf
    #sudo sed -i -e 's/interface=\(*\)/interface=10.*/' /etc/HPCCSystems/environment.conf
    #WriteLog "Interface setting in environment.conf file is:" "${ML_TEST_LOG}"
    #WriteLog "$( egrep 'interface' /etc/HPCCSystems/environment.conf )" "${ML_TEST_LOG}"
```
    
Lines 498-501:
```
# Don't give up, try the next bundle
                #WriteLog "Archive ${TARGET_PLATFORM} ML logs" "${ML_TEST_LOG}"
                #${BIN_HOME}/archiveLogs.sh ml-${TARGET_PLATFORM} timestamp=${OBT_TIMESTAMP}
                #exit -3
```
                
Lines 523-524:
```
#echo "Copy new tests over...."
#read
```
                
Line 613:
```
#sudo gdb --batch --quiet -ex "set interactive-mode off" -ex "thread apply all bt" -ex "quit" "/opt/HPCCSystems/bin/${comp}" $core | sudo tee "$core.trace" 2>&1
```

Lines 680-682:
```
#WriteLog "Remove ECL-Bundles" "${ML_TEST_LOG}"
#rm -rf ${PERF_TEST_ROOT}/PerformanceTesting
```

Lines 712-714:
```
#WriteLog "Stop HPCC Systems ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
#StopHpcc "${ML_TEST_LOG}"
```
                
## Other Changes

Remove Unused Variables:
```
ML_CORE_VERSION="V3_0"
```
```
ML_CORE_REPO=https://github.com/hpcc-systems/ML_Core.git
```
```
ML_PBBLAST_REPO=https://github.com/hpcc-systems/PBblas.git
```
```
MEMSIZE_MB=$(( $ML_THOR_MEMSIZE_GB * (2 ** 10) ))
```
```
TIMEOUTED_FILE_LISTPATH=${BIN_HOME}
TIMEOUTED_FILE_LIST_NAME=${TIMEOUTED_FILE_LISTPATH}/MlTimeoutedTests.csv
TIMEOUT_TAG="//timeout 900"
```
```
TIME_STAMP=$(date +%s)
```
```
buildResult=FAILED
```
```
buildResult=SUCCEED
```

Remove Cassandra Part:

```
    #
    #----------------------------------------------------
    #
    # Kill Cassandra if it used too much memory
    #
    
    WriteLog "Check memory on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    
    freeMem=$( GetFreeMem )

    WriteLog "Free memory is: $( GetFreeMemGB ) on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    
    if [[ $freeMem -lt $MEMSIZE_KB ]]
    then
        WriteLog "Free memory too low on ${TARGET_PLATFORM} and we need ${ML_THOR_MEMSIZE_GB}.!" "${ML_TEST_LOG}"

        cassandraPID=$( ps ax  | grep '[c]assandra' | awk '{print $1}' )
    
        if [ -n "$cassandraPID" ]
        then
            WriteLog "Kill Cassandra (pid: ${cassandraPID})  on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
        
            ${SUDO}  kill -9 ${cassandraPID}
            sleep 5
    
            freeMem=$( GetFreeMem  )
            if [[ "$freeMem" -lt 3777356 ]]
            then
                WriteLog "The free memory ($( GetFreeMemGB )) is still too low! Cannot start HPCC Systems!! Give it up on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
        
                # send email to Agyi
                echo "After the kill Cassandra the Performance test free memory (${freeMem} kB) is still too low on ${TARGET_PLATFORM}! Performance test stopped!" | mailx -s "OBT Memory problem" -u $USER  ${ADMIN_EMAIL_ADDRESS}
        
                exit -1
            fi
        fi
        WriteLog "Free memory is: $( GetFreeMemGB ) on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    fi
```
