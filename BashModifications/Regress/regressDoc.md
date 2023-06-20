## Commented Code Removals

Lines 30-35:
```
#RELEASE_BASE=5.0
#STAGING_DIR=/common/nightly_builds/HPCC/$RELEASE_BASE
#SHORT_DATE=$(date "+%Y-%m-%d")
#BUILD_SYSTEM=centos_6_x86_64
#BUILD_TYPE=CE/platform
#TARGET_DIR=${STAGING_DIR}/${SHORT_DATE}/${BUILD_SYSTEM}/${BUILD_TYPE}
```

Line 42:
```
#TEST_ROOT=~/test
```

Line 66:
```
#startPort=$(        sudo xmlstarlet sel -t -m "//Environment/Software/ThorCluster" -v '@slaveport'        -nl  /etc/HPCCSystems/environment.xml )
```

Line 69:
```
#slavesPerNode=$(    sudo xmlstarlet sel -t -m "//Environment/Software/ThorCluster" -v '@slavesPerNode'    -nl  /etc/HPCCSystems/environment.xml )
```

Line 72:
```
#channelsPerSlave=$( sudo xmlstarlet sel -t -m "//Environment/Software/ThorCluster" -v '@channelsPerSlave' -nl  /etc/HPCCSystems/environment.xml )
```

Line 75:
```
#localThorPortInc=$( sudo xmlstarlet sel -t -m "//Environment/Software/ThorCluster" -v '@localThorPortInc' -nl  /etc/HPCCSystems/environment.xml )
```

Line 111:
```
# ./checkCassandra.sh
```

Line 154:
```
# ./checkKafka.sh
```

Line 349:
```
#subRes=$( SubmoduleUpdate "--init" )
```

Line 355:
```
#ExitEpilog
```

Lines 360-368:
```
#
#-----------------------------------------------------
#
# Use roxie debug version of environment.xml
#

#WriteLog "Use roxie debug version of environment.xml" "${REGRESS_LOG_FILE}"
    
#sudo cp ~/build/bin/environment.xml.roxie.debug /etc/HPCCSystems/environment.xml
```

Lines 438-454:
```
#workflowContingency8=60  # sec
#WriteLog "Patch regression suite workflow_contingency_8 with $workflowContingency8 sec for force timeout as quickly as possible when it hangs." "${REGRESS_LOG_FILE}```
#
#cp -fv ${SOURCE_HOME}/testing/regress/ecl/workflow_contingency_8.ecl ${SOURCE_HOME}/testing/regress/ecl/workflow_contingency_8.ecl-back
#
#hasTimeout=$(egrep -c '//timeout ' ${SOURCE_HOME}/testing/regress/ecl/workflow_contingency_8.ecl )
#if [[ ${hasTimeout} -eq 0 ]]
#then
#    # It has not '//timeout <value> line, add one at the top of the file
#    sed -i -e '/^\/\*##.*$/i\/\/ Patched by the OBT on '"$( date '+%Y.%m.%d %H:%M:%S')"'\n\/\/timeout '"$workflowContingency8"  ${SOURCE_HOME}/testing/regress/ecl/workflow_contingency_8.ecl
#else
#    # It has  '//timeout <value> line, change it to value of $workflowContingency8
#    sed -i -e 's/^\/\/timeout \(.*\).*$/\/\/ Patched by the OBT on '"$( date '+%Y.%m.%d %H:%M:%S')"'\n\/\/timeout '"$workflowContingency8"'/g'  ${SOURCE_HOME}/testing/regress/ecl/workflow_contingency_8.ecl  #> patched-workflow_contingency_8.ecl && mv -f patched-workflow_contingency_8.ecl ${SOURCE_HOME}/testing/regress/ecl/workflow_contingency_8.ecl
#fi
#WriteLog "$(egrep -B1 -A1 '//timeout ' ${SOURCE_HOME}/testing/regress/ecl/workflow_contingency_8.ecl )" "${REGRESS_LOG_FILE}"
#
#WriteLog "Done." "${REGRESS_LOG_FILE}"
```

Lines 533-535:
```
#libDir=/var/lib/HPCCSystems/regression
#[ ! -d $libDir ] && mkdir  -p  $libDir
#rm -rf ${libDir}/*
```

Line 609:
```
#[ $passed -gt 0 ] && passed="<span style=\"color:#298A08\">$passed</span>"
```

Line 688:
```
#[ $passed -gt 0 ] && passed="<span style=\"color:#298A08\">$passed</span>"
```

Line 703:
```
#echo "TestResult:Total:${total} passed:${passed} failed:${failed} elapsed:${elapsed}"
```

Lines 706-711:
```
# if [[ $cluster -eq 'roxie' && $failed -ne '0' ]]
# then
#     WriteLog "There is any failed testcases. Abort Roxie to generate core." "${REGRESS_LOG_FILE}"
#     pkill -2 -x 'roxie'
#
# fi
```

Lines 790-814:
```
# Moved into archiveLogs.sh
#
# Check if any core file generated. If yes, create stack trace with gdb
#
#NUM_OF_REGRESSION_CORES=( $(sudo find /var/lib/HPCCSystems/ -iname 'core*' -type f -exec printf "%s\n" '{}' \; ) )
#    
#if [ ${#NUM_OF_REGRESSION_CORES[@]} -ne 0 ]
#then
#    WriteLog "${#NUM_OF_REGRESSION_CORES[@]} regression test core files found." "${REGRESS_LOG_FILE}"
#
#    for  core in ${NUM_OF_REGRESSION_CORES[@]}
#    do
#        WriteLog "Generate backtrace for $core." "${REGRESS_LOG_FILE}"
#        base=$( dirname $core )
#        lastSubdir=${base##*/}
#        comp=${lastSubdir##my}
#
#        #sudo gdb --batch --quiet -ex "set interactive-mode off" -ex "thread apply all bt" -ex "quit" "/opt/HPCCSystems/bin/${comp}" $core | sudo tee "$core.trace" 2>&1
#        sudo ${GDB_CMD} "/opt/HPCCSystems/bin/${comp}" $core | sudo tee "$core.trace" 2>&1
#
#    done
#
#else
#    WriteLog "No core file generated." "${REGRESS_LOG_FILE}"
#fi
```

Line 829:
```
# rm var-log-HPCCSystems*
```

Lines 844-899:
```
# -----------------------------------------------------
# 
# Uninstall HPCC
# 
#
#echo "Uninstall HPCC-Platform"
#WriteLog "Uninstall HPCC-Platform" "${REGRESS_LOG_FILE}"
#
#
#cd $TEST_ROOT
#
#uninstallFailed=FALSE
#
#if [ -f /opt/HPCCSystems/sbin/complete-uninstall.sh ]
#then
#   sudo /opt/HPCCSystems/sbin/complete-uninstall.sh
#   [ $? -ne 0 ] && uninstallFailed=TRUE
#else
#   WriteLog "It seems HPCC Systems isn't istalled." "${REGRESS_LOG_FILE}"
#   
#   rpm -qa | grep hpcc | grep -v grep |
#   while read hpcc_package
#   do
#     WriteLog "HPCC package: ${hpcc_package}" "${REGRESS_LOG_FILE}"
#     rpm -e $hpcc_package  >  uninstall.log 2>&1
#     [ $? -ne 0 ] && uninstallFailed=TRUE
#   done
#
#   rpm -qa | grep hpcc > /dev/null 2>&1
#   if [ $? -eq 0 ]
#   then
#       WriteLog "Can't remove HPCC package: ${hpcc_package}" "${REGRESS_LOG_FILE}"
#       uninstallFailed=TRUE
#   fi
#
#fi
#
#WriteLog "Check if any dafilesrv is running" "${REGRESS_LOG_FILE}"
#res=$(pgrep dafile 2>&1)
#WriteLog "${res}" "${REGRESS_LOG_FILE}"
#pkill dafile
#
#WriteLog "Check if any eclagent is running" "${REGRESS_LOG_FILE}"
#res=$(pgrep eclagent 2>&1)
#WriteLog "${res}" "${REGRESS_LOG_FILE}"
#pkill eclagent
#
#if [ "$uninstallFailed" = "TRUE" ]
#then
#   echo "TestResult:FAILED" >> uninstall.summary 
#   WriteLog "Uninstall HPCC-Platform FAILED" "${REGRESS_LOG_FILE}"
#
#else
#   echo "TestResult:PASSED" >> uninstall.summary 
#   WriteLog "Uninstall HPCC-Platform PASSED" "${REGRESS_LOG_FILE}"
#fi
```

## Other Changes

Consistent Multi-Word Variable Snake Case:

startPort -> START_PORT
slavesPerNode -> SLAVES_PER_NODE
channelsPerSlave -> CHANNELS_PER_SLAVE
localThorPortInc -> LOCAL_THOR_PORT_INC
endPort -> END_PORT
hpccRunning -> HPCC_RUNNING
subRes -> SUB_RES
teststdlibraryTimeout -> TEST_STD_LIBRARY_TIMEOUT
additionalPlugins -> ADDITIONAL_PLUGINS
upperPlugin -> UPPER_PLUGIN
regExclusion -> REG_EXCLUSION
hasError -> HAS_ERROR
inFile -> IN_FILE
inSuiteErrorLog -> IN_SUITE_ERROR_LOG
retCode -> RET_CODE


Remove Part Relating to thorMonitor.sh:
```
#
#-----------------------------------------------------
#
# Stop/Start thorMonitor.sh 
#

if [[ $( ps aux | grep -E -c '[t]horMonitor' ) -ge 1 ]] 
then
    WriteLog "Kill thorMonitor..." "${REGRESS_LOG_FILE}"
    sudo pkill thorMonitor
    WriteLog "Done." "${REGRESS_LOG_FILE}"
fi

WriteLog "Restart thorMonitor" "${REGRESS_LOG_FILE}"

pushd ${BIN_ROOT}

./thorMonitor.sh > thorMonitor-${LONG_DATE}.log 2>&1  &

popd

WriteLog "Done." "${REGRESS_LOG_FILE}"
```
