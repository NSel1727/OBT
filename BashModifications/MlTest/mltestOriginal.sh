#!/bin/bash
#set -x
#echo "param:'$1'"

#
#------------------------------
#
# Import settings
#
# Git branch

. ./settings.sh

# WriteLog() function

. ./timestampLogger.sh


# UninstallHPCC() fuction

declare -f -F UninstallHPCC > /dev/null
    
if [ $? -ne 0 ]
then
    . ./UninstallHPCC.sh
fi

#
#------------------------------
#
# Constants
#

LOG_DIR=~/HPCCSystems-regression/log

BIN_HOME=~/

#TEST_ROOT=${BUILD_DIR}/CE/platform
PLATFORM_HOME=${TEST_ROOT}
TEST_ENGINE_HOME=${PLATFORM_HOME}/testing/regress

LONG_DATE=$(date "+%Y-%m-%d_%H-%M-%S")
BUILD_LOG_FILE=${BIN_HOME}/"ML_build_"${LONG_DATE}".log";

ML_CORE_VERSION="V3_0"
ML_PBLAS_VERSION="V3_0"
ML_TEST_ROOT=~/.HPCCSystems/bundles/_versions/PBblas/${ML_PBLAS_VERSION}/PBblas

ML_TEST_HOME=${ML_TEST_ROOT}
ML_TEST_LOG=${OBT_LOG_DIR}/ML_test-${LONG_DATE}.log
ML_CORE_REPO=https://github.com/hpcc-systems/ML_Core.git
ML_PBBLAST_REPO=https://github.com/hpcc-systems/PBblas.git

ML_TEST_RESULT_LOG=${OBT_LOG_DIR}/mltest.${LONG_DATE}.log
ML_TEST_SUMMARY=${OBT_LOG_DIR}/mltests.summary


TIMEOUTED_FILE_LISTPATH=${BIN_HOME}
TIMEOUTED_FILE_LIST_NAME=${TIMEOUTED_FILE_LISTPATH}/MlTimeoutedTests.csv
TIMEOUT_TAG="//timeout 900"

if [[ "${SYSTEM_ID}" =~ "Ubuntu" ]]
then
    HPCC_SERVICE="${SUDO} /etc/init.d/hpcc-init"
    DAFILESRV_STOP="${SUDO} /etc/init.d/dafilesrv stop"
else
    HPCC_SERVICE="${SUDO} service hpcc-init"
    DAFILESRV_STOP="${SUDO} service dafilesrv stop"
fi
#STATUS_HPCC="${SUDO} service hpcc-init status | grep -c 'running'"
#NUMBER_OF_RUNNING_HPCC_COMPONENT="${SUDO} service hpcc-init status | wc -l "

#
#----------------------------------------------------
#

ProcessLog()
{ 
    logfilename=$( ls -clr ${TEST_LOG_DIR}/$1.*.log | head -1 | awk '{ print $9 }' )
    WriteLog "ML test result log filename: ${logfilename}" "${ML_TEST_LOG}"
    total=$(cat ${logfilename} | sed -n "s/^[[:space:]]*Queries:[[:space:]]*\([0-9]*\)[[:space:]]*$/\1/p")
    passed=$(cat ${logfilename} | sed -n "s/^[[:space:]]*Passing:[[:space:]]*\([0-9]*\)[[:space:]]*$/\1/p")
    failed=$(cat ${logfilename} | sed -n "s/^[[:space:]]*Failure:[[:space:]]*\([0-9]*\)[[:space:]]*$/\1/p")
    elapsed=$(cat ${logfilename} | sed -n "s/^Elapsed time: \(.*\)$/\1/p")

    WriteLog "TestResult:Total:${total} passed:${passed} failed:${failed} elaps:${elapsed}" "${ML_TEST_LOG}"
    echo "TestResult:mltests:total:${total} passed:${passed} failed:${failed} elaps:${elapsed}" > ${ML_TEST_SUMMARY}

}


#
#----------------------------------------------------
#
# Start ML Test process
#

TIME_STAMP=$(date +%s)

WriteLog "Machine Learning Confidence Test started" "${ML_TEST_LOG}"

WriteLog "ML test script log file: '${ML_TEST_LOG}'" "${ML_TEST_LOG}"
WriteLog "ML test result log file: '${ML_TEST_RESULT_LOG}'" "${ML_TEST_LOG}"

WriteLog "System id: ${SYSTEM_ID}, HPCC_SERVICE = '${HPCC_SERVICE}'" "${ML_TEST_LOG}"

STARTUP_MSG=""

if [[ "$ML_BUILD" -eq 1 ]]
then
    STARTUP_MSG=${STARTUP_MSG}"build"
fi

if [[ "$ML_RUN_THOR" -eq 1 ]]
then
    STARTUP_MSG="${STARTUP_MSG}, thor"
fi

if [[ -n "$STARTUP_MSG" ]]
then
    WriteLog "Execute performance suite on ${STARTUP_MSG}" "${ML_TEST_LOG}"
else
    WriteLog "No target selected. This is a dry run." "${ML_TEST_LOG}"
fi


#
#---------------------------
#
# Determine the package manager

WriteLog "packageExt: '${PKG_EXT}', installCMD: '${PKG_INST_CMD}'." "${ML_TEST_LOG}"

#
#---------------------------
#
# Clean system
#

WriteLog "Clean system" "${ML_TEST_LOG}"

[ ! -e $ML_TEST_ROOT ] && mkdir -p $ML_TEST_ROOT

#rm -rf ${PERF_TEST_ROOT}/*
cd  ${PERF_TEST_ROOT}

 
#
#---------------------------
#
# Uninstall HPCC to free as much disk space as can
#

if [[ ${ML_KEEP_HPCC} -eq 0 ]]
then
    WriteLog "Uninstall HPCC to free as much disk space as can" "${ML_TEST_LOG}"
    
    WriteLog "Uninstall HPCC-Platform" "${ML_TEST_LOG}"
    
    UninstallHPCC "${ML_TEST_LOG}" "${ML_WIPE_OFF_HPCC}"
else
    WriteLog "Skip Uninstall HPCC but stop it!" "${ML_TEST_LOG}"
    StopHpcc "${ML_TEST_LOG}"
fi

#
#--------------------------------------------------
#
# Build it
#

if [[ $ML_BUILD -eq 1 ]]
then
    WriteLog "                                           " "${ML_TEST_LOG}"
    WriteLog "*******************************************" "${ML_TEST_LOG}"
    WriteLog " Build HPCC Platform from ${BUILD_HOME} ..." "${ML_TEST_LOG}"
    WriteLog "                                           " "${ML_TEST_LOG}"

    #
    #-------------------------------------------------------------------------------------
    # Build HPCC
    #
    
    cd ${BUILD_HOME}

    date=$( date "+%Y-%m-%d %H:%M:%S")
    WriteLog "Start build at ${date}" "${ML_TEST_LOG}"

    if [ ! -f  ${BUILD_DIR}/bin/build_pf.sh ]
    then
        C_CMD="cmake -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= -D CMAKE_BUILD_TYPE=$ML_BUILD_TYPE -D CMAKE_ECLIPSE_MAKE_ARGUMENTS=-30 -DECLWATCH_BUILD_STRATEGY='IF_MISSING' ../HPCC-Platform ln -s ../HPCC-Platform"
        WriteLog "${C_CMD}" "${ML_TEST_LOG}"

        res=( "$(${C_CMD} 2>&1)" )
        echo "${res[*]}" > $BUILD_LOG_FILE
    else
        res=( ". $(${BUILD_DIR}/bin/build_pf.sh HPCC-Platform 2>&1)" )
        echo "${res[*]}"  > $BUILD_LOG_FILE

        WriteLog "Execute '${BUILD_DIR}/bin/build_pf.sh'" "${ML_TEST_LOG}"

    fi

    CMD="sudo make -j ${NUMBER_OF_CPUS} package"

    WriteLog "cmd: ${CMD}" "${ML_TEST_LOG}"

    ${CMD} >> ${BUILD_LOG_FILE} 2>&1

    #res=$( ${CMD} 2>&1 )
    #WriteLog "build result:${res}" "${ML_TEST_LOG}"

    if [ $? -ne 0 ] 
    then
        WriteLog "Build failed: build has errors " "${ML_TEST_LOG}"
        buildResult=FAILED
        exit
    else
        ls -l hpcc*${PKG_EXT} >/dev/null 2>&1
        if [ $? -ne 0 ] 
        then
            WriteLog "Build failed: no rpm package found " "${ML_TEST_LOG}"
            buildResult=FAILED
            exit
        else
            WriteLog "Build succeed" "${ML_TEST_LOG}"
            buildResult=SUCCEED
        fi
    fi

    date=$( date "+%Y-%m-%d %H:%M:%S")
    WriteLog "Build end at ${date}" "${ML_TEST_LOG}"

    HPCC_PACKAGE=$( grep 'Current release version' ${BUILD_LOG_FILE} | cut -c 31- )${PKG_EXT}
    
    WriteLog " Default package: '${HPCC_PACKAGE}'." "${ML_TEST_LOG}"
    WriteLog "                                           " "${ML_TEST_LOG}"      

else
    WriteLog "                                           " "${ML_TEST_LOG}"
    WriteLog "*******************************************" "${ML_TEST_LOG}"
    WriteLog " Skip build HPCC Platform...               " "${ML_TEST_LOG}"
    WriteLog "                                           " "${ML_TEST_LOG}"      

    cd ${BUILD_HOME}
    HPCC_PACKAGE=$(find . -maxdepth 1 -name 'hpccsystems-platform-community*' -type f )    
    WriteLog " Default package: \n\t'${HPCC_PACKAGE}' ." "${ML_TEST_LOG}"
    WriteLog "                                           " "${ML_TEST_LOG}"      

fi

TARGET_PLATFORM="thor"

if [ $ML_RUN_THOR -eq 1 ]
then
    #***************************************************************
    #
    #           THOR test
    #
    #***************************************************************
    
    WriteLog "                                   " "${ML_TEST_LOG}"
    WriteLog "***********************************" "${ML_TEST_LOG}"
    WriteLog " Start ML ${TARGET_PLATFORM} test. " "${ML_TEST_LOG}"
    WriteLog "                                   " "${ML_TEST_LOG}"
    
    #
    # --------------------------------------------------------------
    # Install HPCC
    #
    WriteLog "Install HPCC Platform ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    
    res=$( ${SUDO} ${PKG_INST_CMD} ${BUILD_HOME}/${HPCC_PACKAGE} 2>&1 )
    
    if [ $? -ne 0 ]
    then
        if [[ "$res" =~ "already installed" ]]
        then
            WriteLog "$res" "${ML_TEST_LOG}"
        else
            WriteLog "Error in install! ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
            exit
        fi
    fi

    #
    #---------------------------
    #
    # Patch environment.xml to use diferent size Memory
    #

    MEMSIZE=$(( $ML_THOR_MEMSIZE_GB * (2 ** 30) ))
    MEMSIZE_KB=$(( $ML_THOR_MEMSIZE_GB * (2 ** 20) ))


    # for hthor we should change 'defaultMemoryLimitMB' as well 

    MEMSIZE_MB=$(( $ML_THOR_MEMSIZE_GB * (2 ** 10) ))

    
    WriteLog "Patch environment.xml to use ${ML_THOR_MEMSIZE_GB}GB Memory for test on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    WriteLog "Patch environment.xml to use ${ML_THOR_NUMBER_OF_SLAVES} slaves for ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    
    ${SUDO} cp /etc/HPCCSystems/environment.xml /etc/HPCCSystems/environment.xml.bak
    ${SUDO} sed -e 's/totalMemoryLimit="1073741824"/totalMemoryLimit="'${MEMSIZE}'"/g' -e 's/slavesPerNode="1"/slavesPerNode="'${ML_THOR_NUMBER_OF_SLAVES}'"/g' "/etc/HPCCSystems/environment.xml" > temp.xml && ${SUDO} mv -f temp.xml "/etc/HPCCSystems/environment.xml"

    if [ $? -ne 0 ]
    then
        WriteLog "Error in update environment.xml file! ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    else
        WriteLog "The environment.xml file Updated. ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
    fi



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
    
    #
    #---------------------------
    #
    # Check HPCC Systems
    #
    WriteLog "Check HPCC Systems on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"

    NUMBER_OF_HPCC_COMPONENTS=$( /opt/HPCCSystems/sbin/configgen -env /etc/HPCCSystems/environment.xml -list | egrep -i -v 'eclagent' | wc -l )
    
    hpccRunning=$( ${HPCC_SERVICE} status | grep -c 'running' )

    if [[ "$hpccRunning" -ne "$NUMBER_OF_HPCC_COMPONENTS" ]]
    then
        WriteLog "Start HPCC System on ${TARGET_PLATFORM}..." "${ML_TEST_LOG}"
        
        hpccStatus=$( ${HPCC_SERVICE} start  2>&1 )
 
        WriteLog "Result:\n${hpccStatus}" "${ML_TEST_LOG}"
    fi
    
    # give it some time
    sleep 5
    
    hpccRunning=$( ${HPCC_SERVICE} status | grep -c 'running' )
    if [[ "$hpccRunning" -ne ${NUMBER_OF_HPCC_COMPONENTS} ]]
    then
        WriteLog "Unable start HPCC system!! Only ${hpccRunning} component is up on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
        exit -2
    else
        hpccStatus=$( ${HPCC_SERVICE} status )
        WriteLog "HPCC system status: \n${hpccStatus}" "${ML_TEST_LOG}"
    fi
    
    #
    #---------------------------
    #
    # Get test from github
    #
    WriteLog "Get the latest ML core and PBblas" "${ML_TEST_LOG}"
    
    cd  ${PERF_TEST_ROOT}
    myPwd=$( pwd )

    WriteLog "Pwd: ${myPwd} for $TARGET_PLATFORM" "${ML_TEST_LOG}"

    WriteLog "Install ML_Core bundle from GitHub" "${ML_TEST_LOG}"

    tryCountMax=5
    tryCount=$tryCountMax
    tryDelay=2m

    while true
    do
        cRes=$( ecl bundle install --update --force ${ML_CORE_REPO} 2>&1 )
        if [[ 0 -ne  $? ]]
        then
            tryCount=$(( $tryCount-1 ))

            if [[ $tryCount -ne 0 ]]
            then
                WriteLog "Wait for ${tryDelay} to try again." "${ML_TEST_LOG}"
                sleep ${tryDelay}
                continue
            else
                WriteLog "Install ML_Core bundle was failed after ${tryCountMax} attempts. Result is: ${cRes}" "${ML_TEST_LOG}"
                WriteLog "Archive ${TARGET_PLATFORM} ML logs" "${ML_TEST_LOG}"
                ${BIN_HOME}/archiveLogs.sh ml-${TARGET_PLATFORM} timestamp=${OBT_TIMESTAMP}
                exit -3
            fi
        else
            WriteLog "Install ML_Core bundle was success." "${ML_TEST_LOG}"
            ML_CORE_VERSION=$( echo "${cRes}" | egrep "^ML_Core" | awk '{ print $2 }' )
            WriteLog "Version: $( echo "${cRes}" | egrep "^ML_Core" )" "${ML_TEST_LOG}"
            break
        fi
    done
    
    WriteLog "Install PBblas bundle from GitHub" "${ML_TEST_LOG}"

    tryCount=$tryCountMax

    while true
    do
        cRes=$( ecl bundle install --update --force ${ML_PBBLAST_REPO} 2>&1)
        if [[ 0 -ne  $? ]]
        then
            tryCount=$(( $tryCount-1 ))

            if [[ $tryCount -ne 0 ]]
            then
                WriteLog "Wait for ${tryDelay} to try again." "${ML_TEST_LOG}"
                sleep ${tryDelay}
                continue
            else    
               WriteLog "Install PBblas bundle was failed after ${tryCountMax} attempts. Result is: ${cRes}" "${ML_TEST_LOG}"
               WriteLog "Archive ${TARGET_PLATFORM} ML logs" "${ML_TEST_LOG}"
               ${BIN_HOME}/archiveLogs.sh ml-${TARGET_PLATFORM} timestamp=${OBT_TIMESTAMP}
               exit -3
            fi
        else
            WriteLog "Install PBblas bundle was success." "${ML_TEST_LOG}"
            ML_PBLAS_VERSION=$( echo "${cRes}" | egrep "^PBblas" | awk '{ print $2 }' )
            WriteLog "Version: $( echo "${cRes}" | egrep "^PBblas" )" "${ML_TEST_LOG}"
            ML_PBLAS_VERSION_PATH="V${ML_PBLAS_VERSION//./_}"
            ML_TEST_ROOT=~/.HPCCSystems/bundles/_versions/PBblas/${ML_PBLAS_VERSION_PATH}/PBblas
            ML_TEST_HOME=${ML_TEST_ROOT}
            break
       fi
   done

    if [[ ! -d ${ML_TEST_HOME} ]]
    then
        WriteLog "${ML_TEST_HOME} doesn't exists! Check the version, maybe changed!" "${ML_TEST_LOG}"
        exit -4
    fi
    

    cd  ${ML_TEST_HOME}
    # Temporarly patch ConfTest.ecl to use proper IMPORT for Test 
    # WriteLog "Temporarily patch ConfTest.ecl to use proper IMPORT" "${ML_TEST_LOG}" 
    # cp ecl/ConfTest.ecl ecl/ConfTest.bak
    # sed 's/IMPORT ^.test as Tests;/IMPORT $.^.test as Tests;/' ecl/ConfTest.ecl > temp.ecl && mv -f temp.ecl ecl/ConfTest.ecl

    myPwd=$( pwd )
    #
    #---------------------------
    #
    # Run ML tests 
    #
    WriteLog "Run ML tests  on platforms pwd:${myPwd}" "${ML_TEST_LOG}"
    
    cd ${ML_TEST_HOME}    

    WriteLog "ML_TEST_HOME  : ${ML_TEST_HOME}" "${ML_TEST_LOG}"
    WriteLog "ML_ENGINE_HOME: ${ML_ENGINE_HOME}" "${ML_TEST_LOG}"
    
    CMD="${REGRESSION_TEST_ENGINE_HOME}/ecl-test run -t ${TARGET_PLATFORM} --config ${REGRESSION_TEST_ENGINE_HOME}/ecl-test.json --timeout ${ML_TIMEOUT} -fthorConnectTimeout=36000 --pq ${ML_PARALLEL_QUERIES}"

    WriteLog "CMD: '${CMD}'" "${ML_TEST_LOG}"
    
    if [ ${EXECUTE_ML_SUITE} -ne 0 ]
    then
        ${CMD} >> ${ML_TEST_LOG} 2>&1
        
        retCode=$( echo $? )
        WriteLog "retcode: ${retCode}" "${ML_TEST_LOG}"
    
        if [ ${retCode} -ne 0 ] 
        then
            WriteLog "Machine Learning tests on ${TARGET_PLATFORM} returns with ${retCode}" "${ML_TEST_LOG}"
            #exit -1
        else 
            ProcessLog "${TARGET_PLATFORM}"
        fi
    else
        WriteLog "Skip Machine Learning test suite execution!" "${ML_TEST_LOG}"
        WriteLog "                                      " "${ML_TEST_LOG}"        
    fi
    

    NUM_OF_ML_ZAPS=( $(sudo find ${ZAP_DIR}/ -iname 'ZAPReport*' -type f -exec printf "%s\n" '{}' \; ) )
    if [ ${#NUM_OF_ML_ZAPS[@]} -ne 0 ]
    then
        WriteLog "Copy ML test ZAP files to ${TARGET_DIR}/test/ZAP" "${ML_TEST_LOG}"
        if [ ! -e ${TARGET_DIR}/test/ZAP ]
        then
            WriteLog "Create ${TARGET_DIR}/test/ZAP directory..." "${ML_TEST_LOG}"
            mkdir -p ${TARGET_DIR}/test/ZAP
        fi
    
        WriteLog "cp ${ZAP_DIR}/* ${TARGET_DIR}/test/ZAP/" "${ML_TEST_LOG}"
        cp ${ZAP_DIR}/* ${TARGET_DIR}/test/ZAP/
    else
        WriteLog "No ZAP file generated." "${ML_TEST_LOG}"
    fi


    # Check if any core file generated. If yes, create stack trace with gdb

    NUM_OF_ML_CORES=( $(sudo find /var/lib/HPCCSystems/ -iname 'core*' -type f -exec printf "%s\n" '{}' \; ) )
    
    if [ ${#NUM_OF_ML_CORES[@]} -ne 0 ]
    then
        WriteLog "${#NUM_OF_ML_CORES[@]} ML test core files found." "${ML_TEST_LOG}"

        for  core in ${NUM_OF_ML_CORES[@]}
        do
            WriteLog "Generate backtrace for $core." "${ML_TEST_LOG}"
            base=$( dirname $core )
            lastSubdir=${base##*/}
            comp=${lastSubdir##my}
    
            #sudo gdb --batch --quiet -ex "set interactive-mode off" -ex "thread apply all bt" -ex "quit" "/opt/HPCCSystems/bin/${comp}" $core | sudo tee "$core.trace" 2>&1
            sudo ${GDB_CMD} "/opt/HPCCSystems/bin/${comp}" $core | sudo tee "$core.trace" 2>&1
    
       done

    else
        WriteLog "No core file generated." "${ML_TEST_LOG}"
    fi

    # Archive  logs
    pushd ${OBT_BIN_DIR}
    
    # Copy test summary to Wiki
    WriteLog "Copy ML test result files to ${TARGET_DIR}..." "${ML_TEST_LOG}"

    WriteLog "  ${LOG_DIR}/${TARGET_PLATFORM}*.log" "${ML_TEST_LOG}"
    cp ${LOG_DIR}/${TARGET_PLATFORM}*.log ${TARGET_DIR}/test/mltests.log

    WriteLog "  mltests.summary" "${ML_TEST_LOG}"
    cp mltests.summary ${TARGET_DIR}/test/mltests.summary

    WriteLog "Archive ${TARGET_PLATFORM} ML logs" "${ML_TEST_LOG}"
    
    ./archiveLogs.sh ml-${TARGET_PLATFORM} timestamp=${OBT_TIMESTAMP}
    
    popd
    #
    #---------------------------
    #
    # Uninstall HPCC to free as much disk space as can
    #

    if [[ ${KEEP_HPCC} -eq 0 ]]
    then
        WriteLog "Uninstall HPCC to free as much disk space as can on ${TARGET_PLATFORM}!" "${ML_TEST_LOG}"
    
        WriteLog "Uninstall HPCC-Platform" "${ML_TEST_LOG}"
    
        UninstallHPCC "${ML_TEST_LOG}" "${ML_WIPE_OFF_HPCC}"

    else
        WriteLog "Skip Uninstall HPCC on ${TARGET_PLATFORM} but stop it!" "${ML_TEST_LOG}"
        StopHpcc "${ML_TEST_LOG}"
    fi

    if [[ -f /etc/HPCCSystems/environment.xml.bak ]]
    then
        WriteLog "Restore original environment.xml on ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
        
        ${SUDO} cp /etc/HPCCSystems/environment.xml.bak /etc/HPCCSystems/environment.xml
     
        if [ $? -ne 0 ]
        then
            WriteLog "Error in restore environment.xml file! ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
        else
            WriteLog "The environment.xml file restored. ${TARGET_PLATFORM}" "${ML_TEST_LOG}"
        fi
    fi

    #
    #----------------------------
    #
    # Remove ECL-Bundles
    #
    #WriteLog "Remove ECL-Bundles" "${ML_TEST_LOG}"
    
    #rm -rf ${PERF_TEST_ROOT}/PerformanceTesting
    
    WriteLog "                                    " "${ML_TEST_LOG}"
    WriteLog "************************************" "${ML_TEST_LOG}"
    WriteLog " End of ML ${TARGET_PLATFORM} test. " "${ML_TEST_LOG}"
    WriteLog "                                    " "${ML_TEST_LOG}"
    
else
    WriteLog "                                   " "${ML_TEST_LOG}"
    WriteLog "***********************************" "${ML_TEST_LOG}"
    WriteLog " Skip ML ${TARGET_PLATFORM} test.  " "${ML_TEST_LOG}"
    WriteLog "                                   " "${ML_TEST_LOG}"

fi

#
#-----------------------------------------------------------------------------
#
# End of ML test
#


cd ${OBT_BIN_DIR}

#
#---------------------------
#
# Stop HPCC Systems
#

#WriteLog "Stop HPCC Systems ${TARGET_PLATFORM}" "${ML_TEST_LOG}"

#StopHpcc "${ML_TEST_LOG}"

WriteLog "End of Machine Learning test" "${ML_TEST_LOG}"

set +x
