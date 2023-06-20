## Commented Code Removals

Line 38:
```
#NUMBER_OF_CPUS=1
```

Line 64:
```
#cd  ${COVERAGE_ROOT}
```

Lines 158-183:
```
#
                #----------------------------------------------------
                #
                # Tremporarily remove cassandra-simple.ecl test
                #

                #WriteLog "Temporarily remove cassandra-simple.ecl test" "${COVERAGE_LOG_FILE}"

                #res=$( find -name 'cassandra*.ecl' -type f -print -exec rm -f '{}' \;)

                #WriteLog "Res: ${res}" "${COVERAGE_LOG_FILE}"

                #filepath=$( find ${TEST_HOME} -name 'cassandra*.ecl' -type f -print )
                #filepath=

                #if [ -f ${filepath} ]
                #then
                #   WriteLog "Patching ${fielpath} to exclude on Roxie" "${COVERAGE_LOG_FILE}"
                #   echo "Patching ${fielpath} to exclude on Roxie"
                #
                #   (echo "//noroxie"; cat ${filepath}) >${filepath}_new
                #   mv ${filepath}_new ${filepath}
                #else
                #   WriteLog "${fielpath} not found to exclude on Roxie" "${COVERAGE_LOG_FILE}"
                #   echo "${fielpath} not found to exclude on Roxie"
                #fi
                
```
                
Line 303:
```
#cp ${logDir}/thor.*.log ${COVERAGE_ROOT}/
```

Lines 310-311:
```
#[ $passed -gt 0 ] && passed="<span style=\"color:#298A08\">$passed</span>"
#[ $failed -gt 0 ] && failed="<span style=\"color:#FF0000\">$passed</span>"
```
  
Lines 343-344:
```
#[ $passed -gt 0 ] && passed="<span style=\"color:#298A08\">$passed</span>"
#[ $failed -gt 0 ] && failed="<span style=\"color:#FF0000\">$passed</span>"
```
  
Line 353:
```
#service hpcc-init stop
```

## Other Changes

Remove Unused Variable:
```
LOGDIR=~/HPCCSystems-regression/log
```
