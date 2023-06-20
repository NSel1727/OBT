## Commented CodeLin Removals

Line 38:
```
#TEST_ROOT=${BUILD_DIR}/CE/platform
```

Lines 70-71:
```
#STATUS_HPCC="${SUDO} service hpcc-init status | grep -c 'running'"
#NUMBER_OF_RUNNING_HPCC_COMPONENT="${SUDO} service hpcc-init status | wc -l "
```

Line 143:
```
#rm -rf ${PERF_TEST_ROOT}/*
```

Lines 209-210:
```
#res=$( ${CMD} 2>&1 )
#WriteLog "build result:${res}" "${ML_TEST_LOG}"
```
                
Lines 355-370:
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
    
Lines 489-492:
```
# Temporarly patch ConfTest.ecl to use proper IMPORT for Test 
    # WriteLog "Temporarily patch ConfTest.ecl to use proper IMPORT" "${ML_TEST_LOG}" 
    # cp ecl/ConfTest.ecl ecl/ConfTest.bak
    # sed 's/IMPORT ^.test as Tests;/IMPORT $.^.test as Tests;/' ecl/ConfTest.ecl > temp.ecl && mv -f temp.ecl ecl/ConfTest.ecl
```
    
Line 563:
```
#sudo gdb --batch --quiet -ex "set interactive-mode off" -ex "thread apply all bt" -ex "quit" "/opt/HPCCSystems/bin/${comp}" $core | sudo tee "$core.trace" 2>&1
```

Lines 623-630:
```
#
                #----------------------------
                #
                # Remove ECL-Bundles
                #
                #WriteLog "Remove ECL-Bundles" "${ML_TEST_LOG}"
                #rm -rf ${PERF_TEST_ROOT}/PerformanceTesting
```

Line 653-661:
```
#
               #---------------------------
               #
               # Stop HPCC Systems
               #

               #WriteLog "Stop HPCC Systems ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
              #StopHpcc "${ML_TEST_LOG}"
```
              
## Other Changes

Remove Unused Variables:
```
TIMEOUTED_FILE_LISTPATH=${BIN_HOME}
TIMEOUTED_FILE_LIST_NAME=${TIMEOUTED_FILE_LISTPATH}/MlTimeoutedTests.csv
TIMEOUT_TAG="//timeout 900"
```
```
DAFILESRV_STOP="${SUDO} /etc/init.d/dafilesrv stop"
```
```
DAFILESRV_STOP="${SUDO} service dafilesrv stop"    
```
```
buildResult=SUCCEED
```
```
buildResult=FAILED
```

Consistent Snake Case:

hpccRunning -> HPCC_RUNNING
hpccStatus -> HPCC_STATUS
myPwd -> MY_PWD
tryCountMax -> TRY_COUNT_MAX
tryCount -> TRY_COUNT
tryDelay -> TRY_DELAY
retCode -> RET_CODE

Remove Cassandra Part

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
