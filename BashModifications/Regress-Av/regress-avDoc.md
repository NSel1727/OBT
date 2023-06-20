## Removed Commented Code

Lines 11-14:
```
#echo "Clean system"
#[ ! -e $TEST_ROOT ] && mkdir -p $TEST_ROOT
#
#rm -rf ${TEST_ROOT}/*
```

Lines 18-49:
```
#rpm -qa | grep hpcc | grep -v grep |
            #while read hpcc_package
            #do
            #   rpm -e $hpcc_package
            #done

            #rpm -qa | grep hpcc > /dev/null 2>&1
            #if [ $? -eq 0 ]
            #then
            #   touch  clean.failed
            #   exit
            #fi



            # Install HPCC
            #echo ""
            #echo "Install HPCC-Platform"
            #rpm -i --nodeps ${BUILD_HOME}/hpccsystems-platform_community*.rpm > install.log 2>&1
            #if [ $? -ne 0 ]
            #then
            #   echo "TestResult:FAILED" >> install.summary 
            #   exit
            #else
            #   echo "TestResult:PASSED" >> install.summary
            #fi
            #service hpcc-init start

            # Get test from github
            #echo ""
            #echo "Get test from github"
            #git clone https://github.com/hpcc-systems/HPCC-Platform.git 
```

Lines 77-78:
```
#[ $passed -gt 0 ] && passed="<span style=\"color:#298A08\">$passed</span>"
#[ $failed -gt 0 ] && failed="<span style=\"color:#FF0000\">$passed</span>"
```
  
Lines 85-102:
```
# Uninstall HPCC
                #echo ""
                #echo "Uninstall HPCC-Platform"
                #uninstallFailed=FALSE
                #hpccPackageName=$(rpm -qa | grep hpcc)
                #rpm -e $hpccPackageName  >  uninstall.log 2>&1
                #[ $? -ne 0 ] && uninstallFailed=TRUE
                #
                #rpm -qa | grep hpcc  > /dev/null 2>&1
                #[ $? -eq 0 ] && uninstallFailed=TRUE


                #if [ "$uninstallFailed" = "TRUE" ]
                #then
                #   echo "TestResult:FAILED" >> uninstall.summary 
                #else
                #   echo "TestResult:PASSED" >> uninstall.summary 
                #fi
```
                
## Remove Unused Variables

```
BUILD_HOME=~/build/CE/platform/build
```
  
