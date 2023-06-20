## Removed Commented Code

Line 31:
```
#WUTOOLTEST_EXCLUSION='CcdFileTest'
```

Line 258:
```
#cat ${WUTOOLTEST_RESULT_FILE} | egrep -i 'ok|Run:' | while read res
```

Line 282:
```
#WriteLog "Result: ${RESULT}" "$WUTOOLTEST_EXECUTION_LOG_FILE"
```

Line 290:
```
#FAILED=$(( $FAILED + $UNIT_FAILED))
```

Lines 308-309:
```
#WriteLog "TestResult:unit:total:${UNIT_TOTAL} passed:${UNIT_PASSED} failed:${UNIT_FAILED} errors:{$UNIT_ERRORS} timeout:${UNIT_TIMEOUT}"  "$WUTOOLTEST_EXECUTION_LOG_FILE"
#echo "TestResult:wutoolTest:total:${UNIT_TOTAL} passed:${UNIT_PASSED} failed:${UNIT_FAILED} errors:{$UNIT_ERRORS} timeout:${UNIT_TIMEOUT}" > $WUTOOLTEST_SUMMARY_FILE
```
         
Lines 321-322:
```
#WriteLog "TestResult:wutoolTest(${target}):total:${UNIT_TOTAL} passed:${UNIT_PASSED} failed:${UNIT_FAILED} errors:${UNIT_ERRORS} timeout:${UNIT_TIMEOUT} elaps:$( SecToTimeStr ${elaps} )"  "$WUTOOLTEST_EXECUTION_LOG_FILE"    
    #echo "TestResult:wutoolTest(${target}):total:${UNIT_TOTAL} passed:${UNIT_PASSED} failed:${UNIT_FAILED} errors:${UNIT_ERRORS} timeout:${UNIT_TIMEOUT} elaps:$( SecToTimeStr ${elaps} )" >> $WUTOOLTEST_SUMMARY_FILE
```

Line 328:
```
#echo "TestResult:wutoolTest:total:${TOTAL} passed:${PASSED} failed:${FAILED} errors:${ERRORS} timeout:${TIMEOUT} elaps:$( SecToTimeStr ${TEST_TIME} )" > $WUTOOLTEST_SUMMARY_FILE
```

## Other Changes

Remove Cassandra Part:

```
#------------------------------------------------------------
# Check Cassandra
#

WriteLog "Check Cassandra..." "$WUTOOLTEST_EXECUTION_LOG_FILE"

tryCount=0   # DO NOT TRY TO START CASSANDRA (based on log4j problem)

testCassandra=0
CASSANDRA_STOPPED=0

if [[ $tryCount -ne 0 ]]
then
    # Check if Cassandra installed
    if type "cqlsh" &> /dev/null
    then
        unset -v JAVA_HOME

        while [[ $tryCount -ne 0 ]]
        do
            WriteLog "Try count: $tryCount" "${WUTOOLTEST_EXECUTION_LOG_FILE}"
            cassandraState=$( cqlsh -e "show version;" -u cassandra -p cassandra  2>/dev/null | grep 'Cassandra')
            if [[ -z $cassandraState ]]
            then
                WriteLog "It doesn't respond to version query. Check if it is already running." "${WUTOOLTEST_EXECUTION_LOG_FILE}"
                cassandraPID=$( ps ax  | grep '[c]assandra' | awk '{print $1}' )

                if [[ -n "$cassandraPID" ]]
                then
                    WriteLog "It is running (pid: ${cassandraPID}), kill it. " "${WUTOOLTEST_EXECUTION_LOG_FILE}"
                    sudo kill -9 ${cassandraPID}
                    sleep 10
                    sudo rm -rf /var/lib/cassandra/*
                fi

                WriteLog "Stoped! Start it!" "${WUTOOLTEST_EXECUTION_LOG_FILE}"
                CASSANDRA_STOPPED=1
                sudo cassandra > /dev/null 2>&1
                sleep 20
                tryCount=$(( $tryCount-1 ))
                continue
            else
                WriteLog "It is OK!" "${WUTOOLTEST_EXECUTION_LOG_FILE}"
                testCassandra=1
                # Wait for 10 sec to Cassandra wake up
                sleep 10
                break
            fi
        done
        if [[ $testCassandra -eq 0 ]]
        then
            WriteLog "Cassandra doesn't start! Skip test on it. Send Email to Agyi!" "${WUTOOLTEST_EXECUTION_LOG_FILE}"
            # send email to Agyi
            echo "Cassandra doesn't start! Skip WUTool test on it!" | mailx -s "Problem with Cassandra in WUTool test" -u $USER  ${ADMIN_EMAIL_ADDRESS}
        else
            testParams=( "DALISERVER=." "DALISERVER=. cassandraserver=127.0.0.1 entire=1 repository=1" )
        fi
    else
        WriteLog "Cassandra  not installed in this sysytem! Send Email to Agyi!" "${WUTOOLTEST_EXECUTION_LOG_FILE}"
        # send email to Agyi
        echo "Cassandra  not installed in this system!" | mailx -s "Problem with Cassandra" -u $USER  ${ADMIN_EMAIL_ADDRESS}
    fi
else
    WriteLog "DO NOT TRY TO START CASSANDRA (based on log4j problem)" "$WUTOOLTEST_EXECUTION_LOG_FILE"
fi
```

Make Constant:

```
SED_INPUT="s/^[[:space:]]*Run:[[:space:]]*\([0-9]*\)[[:space:]]*Failures:[[:space:]]*\([0-9]*\)[[:space:]]*Errors:[[:space:]]*\([0-9]*\)[[:space:]]*Timeout:[[:space:]]*\([0-9]*\)[[:space:]]*$/"
```
```
SED_INPUT="s/^[[:space:]]*Run:[[:space:]]*([0-9]*)[[:space:]]*Failures:[[:space:]]*([0-9]*)[[:space:]]*Errors:[[:space:]]*([0-9]*)[[:space:]]*$/"
```
```
UNIT_TOTAL=$( echo "${RESULT}" | sed -n $SED_INPUT"\1/p")
```

