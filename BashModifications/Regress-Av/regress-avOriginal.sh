#!/bin/bash

TEST_ROOT=~/test
TEST_HOME=${TEST_ROOT}/HPCC-Platform/testing/regress
BUILD_HOME=~/build/CE/platform/build


# Clean system

echo ""
#echo "Clean system"
#[ ! -e $TEST_ROOT ] && mkdir -p $TEST_ROOT
#
#rm -rf ${TEST_ROOT}/*
cd  ${TEST_ROOT}


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

# Prepare regression test 
echo ""
echo "Prepar reqgression test"
logDir=/root/HPCCSystems-regression/log
[ ! -d $logDir ] && mkdir -p $logDir 
rm -rf ${logDir}/*

libDir=/var/lib/HPCCSystems/regression
[ ! -d $libDir ] && mkdir  -p  $libDir
rm -rf ${libDir}/*

# Run test 
echo ""
echo "Run reqgression test"
cd  $TEST_HOME
./regress --suiteDir . list | grep -v "Cluster" |
while read cluster
do

  echo ""
  echo "./regress --suiteDir . run $cluster"
  ./regress --suiteDir . run $cluster
  cp ${logDir}/${cluster}*.log ${TEST_ROOT}/
  total=$(cat ${logDir}/${cluster}*.log | sed -n "s/^[[:space:]]*Queries:[[:space:]]*\([0-9]*\)[[:space:]]*$/\1/p")
  passed=$(cat ${logDir}/${cluster}*.log | sed -n "s/^[[:space:]]*Passing:[[:space:]]*\([0-9]*\)[[:space:]]*$/\1/p")
  failed=$(cat ${logDir}/${cluster}*.log | sed -n "s/^[[:space:]]*Failure:[[:space:]]*\([0-9]*\)[[:space:]]*$/\1/p")
  #[ $passed -gt 0 ] && passed="<span style=\"color:#298A08\">$passed</span>"
  #[ $failed -gt 0 ] && failed="<span style=\"color:#FF0000\">$passed</span>"
  echo "TestResult:Total:${total} passed:$passed failed:$failed" > ${TEST_ROOT}/${cluster}.summary 

done

cd $TEST_ROOT

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


