## Commented Code Removals

Line 3:
```
#echo "param:'$1'"
```

Lines 326-327:
```
#WriteLog "Repo clone failed ! Result is: ${cres}" "${PERF_TEST_LOG}"
#ExitEpilog "${PERF_TEST_LOG}"
```
                
Line 425:
```
#BOOST_PKG="boost_1_71_0.tar.gz"
```

Lines 483-495:
```
#    if [ ! -f  ${BUILD_DIR}/bin/build_perf.sh ]
#    then
#        C_CMD="/usr/local/bin/cmake -D CMAKE_BUILD_TYPE=$PERF_BUILD_TYPE -DMAKE_DOCS=0 -DUSE_CPPUNIT=1 -DTEST_PLUGINS=0 -DINCLUDE_PLUGINS=0 -DSUPPRESS_PY3EMBED=ON -DINCLUDE_PY3EMBED=OFF -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= -D CMAKE_ECLIPSE_MAKE_ARGUMENTS=-30 -DECLWATCH_BUILD_STRATEGY='IF_MISSING' ../HPCC-Platform ln -s ../HPCC-Platform"
#        # C_CMD="cmake -D INCLUDE_PY3EMBED=OFF -D PY3EMBED=OFF -D SUPPRESS_PY3EMBED=ON -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D CMAKE_ECLIPSE_MAKE_ARGUMENTS=-30 -DECLWATCH_BUILD_STRATEGY='IF_MISSING' ../HPCC-Platform ln -s ../HPCC-Platform"
#        WriteLog "${C_CMD}" "${PERF_TEST_LOG}"
#
#        res=( "$(${C_CMD} 2>&1)" )
#        WriteLog "${res[*]}" "${PERF_TEST_LOG}"
#    else
        #WriteLog "Execute '${BUILD_DIR}/bin/build_perf.sh'" "${PERF_TEST_LOG}"

        #C_CMD="/usr/local/bin/cmake -DCMAKE_BUILD_TYPE=$PERF_BUILD_TYPE -DTEST_PLUGINS=0 -DINCLUDE_PLUGINS=0 -DSUPPRESS_PY3EMBED=ON -DINCLUDE_PY3EMBED=OFF -DMAKE_DOCS=0 -DUSE_CPPUNIT=1 -DINCLUDE_SPARK=0 -DSUPPRESS_SPARK=1 -DSPARK=0 -DGENERATE_COVERAGE_INFO=0 -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= -DMYSQL_LIBRARIES=/usr/lib64/mysql/libmysqlclient.so  -DMYSQL_INCLUDE_DIR=/usr/include/mysql -DMAKE_MYSQLEMBED=1 -DECLWATCH_BUILD_STRATEGY=SKIP ../HPCC-Platform ln -s ../HPCC-Platform"
        # C_CMD="cmake -D INCLUDE_PY3EMBED=OFF -D PY3EMBED=OFF -D SUPPRESS_PY3EMBED=ON -DUSE_LIBXSLT=ON -DXALAN_LIBRARIES= -D CMAKE_BUILD_TYPE=$BUILD_TYPE -D CMAKE_ECLIPSE_MAKE_ARGUMENTS=-30 -DECLWATCH_BUILD_STRATEGY='IF_MISSING' ../HPCC-Platform ln -s ../HPCC-Platform"
```
        
Line 500:
```
#CMAKE_CMD+=$' -G "'${GENERATOR}$'"'
```

Line 509:
```
#CMAKE_CMD+=$' -D CMAKE_ECLIPSE_MAKE_ARGUMENTS=-30 ../HPCC-Platform ln -s '
```

Line 514:
```
#eval ${CMAKE_CMD} >> "${PERF_TEST_LOG}" 2>&1
```

Line 518:
```
#res=( "$(${C_CMD} 2>&1)" )
```

Line 520:
```
#fi
```

Line 536:
```
#CMD="make -j 1 package"
```

Lines 542-545:
```
#WriteLog "Execute it again: ${CMD}" "${PERF_TEST_LOG}"                #res=$( ${CMD} 2>&1 )
#WriteLog "build result:${res}" "${PERF_TEST_LOG}"
```
                
Lines 602-623:
```
#
    # --------------------------------------------------------------
    # Install HPCC
    #
#    if [[ ${PERF_KEEP_HPCC} -eq 0 ]]
#    then
#        WriteLog "Remove environment.xml to ensure clean, out-of-box environmnet." "${PERF_TEST_LOG}"
#        sudo rm /etc/HPCCSystems/environment.xml
#
#        WriteLog "Install HPCC Platform ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
#    
#        ${SUDO} ${PKG_INST_CMD} ${BUILD_HOME}/${HPCC_PACKAGE}
#    
#        if [ $? -ne 0 ]
#        then
#            WriteLog "Error in install! ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
#            exit
#        fi
#    else
#        WriteLog "Start HPCC Platform ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
#        ${SUDO} service hpcc-init start
#    fi
```

Line 670:
```
#${SUDO} cp /etc/HPCCSystems/environment.xml /etc/HPCCSystems/environment.xml.bak
```

Line 710:
```
#exit -1
```

Lines 825-860:
```
#
    #----------------------------------------------------
    #
    # Patch testcase(s) which previously run timeout if any

    #echo "Patch testcases which previously run timeout if any ${TARGET_PLATFORM}"
    #WriteLog "Patch testcases which previously run timeout if any ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
    
    #if [ -f ${TIMEOUTED_FILE_LIST_NAME} ]
    #then
    #    echo "There is some timeouted testcases"
    #    WriteLog "There is some timeouted testcases" "${PERF_TEST_LOG}"
    #    myPwd=$( pwd )    
    #    cd ${PERF_TEST_HOME}/ecl
    #    
    #    while read fileName
    #    do
    #        echo "File:${fileName}"
    #        WriteLog "File:${fileName}" "${PERF_TEST_LOG}"
    #        
    #        patched=$( grep '//timeout' ${fileName}.ecl )
    #    
    #        if [[ -z ${patched} ]]
    #        then
    #            echo "Patching..."
    #            WriteLog "Patching..." "${PERF_TEST_LOG}"
    #            $(echo ${TIMEOUT_TAG}; cat ${fileName}".ecl") >${fileName}.new
    #            mv ${fileName}{.new,.ecl}
    #        else
    #            echo "Already has //timeout tag !"
    #            WriteLog "Already has //timeout tag !" "${PERF_TEST_LOG}"
    #        fi
    #    done < "${TIMEOUTED_FILE_LIST_NAME}"
    #    
    #    cd ${myPwd}
    #fi
```

Line 1688:
```
#if [[ "$PERF_RESULT" == "PASS" ]]
```

Lines 1463-1465:
```
#    else
                  #        WriteLog "Start HPCC Platform ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
                  #        ${SUDO} service hpcc-init start
```
                  
## Other Changes

Ensure Multi-Word Variables are in Snake Case:

buildResult -> BUILD_RESULT
subRes -> SUB_RES
hpccRunning -> HPCC_RUNNING
retCode -> RET_CODE
excludeAlgos -> EXCLUDE_ALGOS
isExists -> IS_EXISTS
freeMem -> FREE_MEM
myPwd -> MY_PWD

Remove Cassandra Parts:

Original:
```
    CMAKE_CMD+=$' -D CMAKE_EXPORT_COMPILE_COMMANDS=ON -D USE_LIBXSLT=ON -D XALAN_LIBRARIES= -D MAKE_CASSANDRAEMBED=1'
```
Updated:
```
    CMAKE_CMD+=$' -D CMAKE_EXPORT_COMPILE_COMMANDS=ON -D USE_LIBXSLT=ON -D XALAN_LIBRARIES= '
```
```
    #
    #----------------------------------------------------
    #
    # Kill Cassandra if it used too much memory
    #
    WriteLog "Check memory on ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
    
    FREE_MEM=$( free | grep -E "^(Mem)" | awk '{print $4 }' )

    WriteLog "Free memory is: ${FREE_MEM} kB on ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
    
    MIN_ALLOWED_FREE_MEM = 3777356
    if [[ "$FREE_MEM" -lt MIN_ALLOWED_FREE_MEM ]]
    then
        WriteLog "Free memory too low on ${TARGET_PLATFORM}!" "${PERF_TEST_LOG}"

        cassandraPID=$( ps ax  | grep '[c]assandra' | awk '{print $1}' )
    
        if [ -n "$cassandraPID" ]
        then
            WriteLog "Kill Cassandra (pid: ${cassandraPID})  on ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
        
            kill -9 ${cassandraPID}
            sleep 5
    
            FREE_MEM=$( free | grep -E "^(Mem)" | awk '{print $4 }' )
            if [[ "$FREE_MEM" -lt 3777356 ]]
            then
                WriteLog "The free memory (${FREE_MEM} kB) is still too low! Cannot start HPCC Systems!! Give it up on ${TARGET_PLATFORM}" "${PERF_TEST_LOG}"
        
                # send email to Agyi
                echo "After the kill Cassandra the Performance test free memory (${FREE_MEM} kB) is still too low on ${TARGET_PLATFORM}! Performance test stopped!" | mailx -s "OBT Memory problem" -u $USER  ${ADMIN_EMAIL_ADDRESS}
            fi
        fi
    fi

    WriteLog "Free memory is: ${FREE_MEM} kB on ${TARGET_PLATFORM}" "${PERF_TEST_LOG}
```
