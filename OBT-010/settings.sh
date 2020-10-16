#!/bin/bash
PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

set -a

#
#----------------------------------------------------
#
# Get system info 
#

SYSTEM_ID=$( cat /etc/*-release | egrep -i "^PRETTY_NAME" | cut -d= -f2 | tr -d '"' )
if [[ "${SYSTEM_ID}" == "" ]]
then
    SYSTEM_ID=$( cat /etc/*-release | head -1 )
fi

SYSTEM_ID=${SYSTEM_ID// (*)/}
SYSTEM_ID=${SYSTEM_ID// /_}
SYSTEM_ID=${SYSTEM_ID//./_}

#
#----------------------------------------------------
#

BRANCH_ID=master

if [[ ( "${SYSTEM_ID}" =~ "CentOS_release_6" ) ]]
then
    # For obtSequencer.sh 
    BRANCHES_TO_TEST=( 'candidate-7.4.x' 'candidate-7.6.x' 'candidate-7.8.x' )

    # For versioning
    RUN_0=("BRANCH_ID=candidate-7.4.x")
    RUN_1=("BRANCH_ID=candidate-7.6.x")
    RUN_2=("BRANCH_ID=candidate-7.8.x")

    RUN_ARRAY=(
        RUN_0[@]
        RUN_1[@]
        RUN_2[@]
    )
else
    # For obtSequencer.sh 
    BRANCHES_TO_TEST=( 'candidate-7.8.x' 'candidate-7.10.x' 'candidate-7.12.x' 'master' )

    # For versioning
    RUN_0=("BRANCH_ID=candidate-7.8.x" "REGRESSION_NUMBER_OF_THOR_CHANNELS=4")
    RUN_1=("BRANCH_ID=candidate-7.10.x")
    RUN_2=("BRANCH_ID=candidate-7.10.x" "REGRESSION_NUMBER_OF_THOR_CHANNELS=4")
    RUN_3=("BRANCH_ID=candidate-7.12.x")
    RUN_4=("BRANCH_ID=candidate-7.12.x" "REGRESSION_NUMBER_OF_THOR_CHANNELS=4")
    RUN_5=("BRANCH_ID=master")

    RUN_ARRAY=(
        RUN_0[@]
        RUN_1[@]
        RUN_2[@]
        RUN_3[@]
        RUN_4[@]
        RUN_5[@]
    )
fi
#
#----------------------------------------------------
#
# Override settings if necessary (generated by the obtSequencer.sh)
#

if [[ -f ./settings.inc ]]
then
    . ./settings.inc
fi

#
#-----------------------------------------------------------
#
# To determine the number of CPUs/Cores to build and parallel execution

NUMBER_OF_CPUS=$(( $( grep 'core\|processor' /proc/cpuinfo | awk '{print $3}' | sort -nru | head -1 ) + 1 ))

MEMORY=$(( $( free | grep -i "mem" | awk '{ print $2}' )/ ( 1024 ** 2 ) ))

SETUP_PARALLEL_QUERIES=$(( $NUMBER_OF_CPUS - 1 ))
TEST_PARALLEL_QUERIES=$SETUP_PARALLEL_QUERIES

if [[ $NUMBER_OF_CPUS -ge 20 ]]
then
    SETUP_PARALLEL_QUERIES=20
    TEST_PARALLEL_QUERIES=20
else
    if [[ $NUMBER_OF_CPUS -le 4 ]]
    then
        [[ $NUMBER_OF_CPUS -gt 2 ]] && TEST_PARALLEL_QUERIES=$(( $NUMBER_OF_CPUS - 2 )) || TEST_PARALLEL_QUERIES=1
    fi
fi

#
#-----------------------------------------------------------
# To determine the number of CMake build threads
#

if [[ $NUMBER_OF_CPUS -ge 20 ]]
then
    # We have plenty of cores release the CMake do what it wants
    NUMBER_OF_BUILD_THREADS=
else
    # Use 50% more threads than the number of CPUs you have
    NUMBER_OF_BUILD_THREADS=$(( $NUMBER_OF_CPUS * 3 / 2 )) 
fi


#
#-----------------------------------------------------------
#
# Determine the package manager

IS_NOT_RPM=$( type "rpm" 2>&1 | grep -c "not found" )
PKG_EXT=
PKG_INST_CMD=
PKG_QRY_CMD=
PKG_REM_CMD=

if [[ "$IS_NOT_RPM" -eq 1 ]]
then
    PKG_EXT=".deb"
    PKG_INST_CMD="dpkg -i "
    PKG_QRY_CMD="dpkg -l "
    PKG_REM_CMD="dpkg -r "
else
    PKG_EXT=".rpm"
    PKG_INST_CMD="rpm -i --nodeps "
    PKG_QRY_CMD="rpm -qa "
    PKG_REM_CMD="rpm -e --nodeps "
fi

#
#----------------------------------------------------
#
# Common macros

URL_BASE=http://10.246.32.16/common/nightly_builds/HPCC
RELEASE_BASE=$BRANCH_ID
STAGING_DIR_ROOT=/common/nightly_builds/HPCC/
STAGING_DIR=${STAGING_DIR_ROOT}/$RELEASE_BASE

SHORT_DATE=$(date "+%Y-%m-%d")

if [ -z $OBT_TIMESTAMP ] 
then 
    OBT_TIMESTAMP=$(date "+%H-%M-%S")
    export OBT_TIMESTAMP
fi

if [ -z $OBT_DATESTAMP ] 
then 
    OBT_DATESTAMP=${SHORT_DATE}
    export OBT_DATESTAMP
fi


SUDO=sudo

if [[ "${SYSTEM_ID}" =~ "Ubuntu" ]]
then
    HPCC_SERVICE="${SUDO} /etc/init.d/hpcc-init"
    DAFILESRV_STOP="${SUDO} /etc/init.d/dafilesrv stop"
else
    HPCC_SERVICE="${SUDO} service hpcc-init"
    DAFILESRV_STOP="${SUDO} service dafilesrv stop"
fi


OBT_SYSTEM=OBT-010
OBT_SYSTEM_ENV=TestFarm2
OBT_SYSTEM_STACKSIZE=81920
OBT_SYSTEM_NUMBER_OF_PROCESS=524288
OBT_SYSTEM_NUMBER_OF_FILES=524288

BUILD_SYSTEM=${SYSTEM_ID}
RELEASE_TYPE=CE/platform
TARGET_DIR=${STAGING_DIR}/${OBT_DATESTAMP}/${OBT_SYSTEM}-${BUILD_SYSTEM}/${OBT_TIMESTAMP}/${RELEASE_TYPE}

BUILD_DIR=~/build
OBT_LOG_DIR=${BUILD_DIR}/bin
OBT_BIN_DIR=${BUILD_DIR}/bin
BUILD_HOME=${BUILD_DIR}/${RELEASE_TYPE}/build
SOURCE_HOME=${BUILD_DIR}/${RELEASE_TYPE}/HPCC-Platform
REGRESSION_TEST_ENGINE_HOME=$OBT_BIN_DIR/rte

GIT_2DAYS_LOG=${OBT_LOG_DIR}/git_2days.log
GLOBAL_EXCLUSION_LOG=${OBT_LOG_DIR}/GlobalExclusion.log

TEST_ROOT=${SOURCE_HOME}
TEST_ENGINE_HOME=${TEST_ROOT}/testing/regress

REGRESSION_RESULT_DIR=~/HPCCSystems-regression
TEST_LOG_DIR=$REGRESSION_RESULT_DIR/log
ZAP_DIR=$REGRESSION_RESULT_DIR/zap

LOG_DIR=~/HPCCSystems-regression/log

BIN_HOME=~

DEBUG_BUILD_DAY=6
BUILD_TYPE=RelWithDebInfo

WEEK_DAY=$(date "+%w")

if [[ $WEEK_DAY -eq $DEBUG_BUILD_DAY ]]
then
    BUILD_TYPE=Debug
fi

TEST_PLUGINS=1
USE_CPPUNIT=1
MAKE_WSSQL=1
USE_LIBMEMCACHED=1
ECLWATCH_BUILD_STRATEGY=IF_MISSING
ENABLE_SPARK=0
SUPPRESS_SPARK=1


# Use complete-uninstall.sh to wipe HPCC
WIPE_OFF_HPCC=0


# ESP Server IP address to customize Regression Test Engine 
# It is used on multinode cluster if the OBT runs different machine than ESP Server
# Default
ESP_IP=127.0.0.1
#
# For our multi node performance cluster:
#ESP_IP=10.241.40.5

LOCAL_IP_STR=$( /sbin/ip -f inet -o addr | egrep -i 'eth0|ib0' | sed -n "s/^.*inet[[:space:]]\([0-9]*\).\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*$/\1\.\2\.\3\.\4/p" )

ADMIN_EMAIL_ADDRESS="attila.vamos@gmail.com"

QUICK_SESSION=0  # If non zero then execute standard unittests, else use default settings

#
#----------------------------------------------------
#
# House keeping
#

# When old 'HPCC-Platform' and 'build' directories exipre
SOURCE_DIR_EXPIRE=1  # days, this is a small VM with 120 GB disk

# usually it is same as EXPIRE, but if we run more than one test a day it can consume ~4GB/test disk space
SOURCE_DIR_MAX_NUMBER=7 # Not implemented yet

BUILD_DIR_EXPIRE=1   # days
BUILD_DIR_MAX_NUMBER=7   # Not implemented yet


# Local log archive
LOG_ARCHIEVE_DIR_EXPIRE=30 # days

# Remote, WEB log archive
WEB_LOG_ARCHIEVE_DIR_EXPIRE=60 # days


#
#----------------------------------------------------
#
# Monitors
#

PORT_MONITOR_START=1

DISK_SPACE_MONITOR_START=1

MY_INFO_MONITOR_START=1

#
#----------------------------------------------------
#
# Trace generation macro
#

GDB_CMD='gdb --batch --quiet -ex "set interactive-mode off" -ex "echo \nBacktrace for all threads\n==========================" -ex "thread apply all bt" -ex "echo \n Registers:\n==========================\n" -ex "info reg" -ex "echo \n Disas:\n==========================\n" -ex "disas" -ex "quit"'

#
#----------------------------------------------------
#
# Doc build macros
#

BUILD_DOCS=1


#
#----------------------------------------------------
#
# Supress plugin(s) for a specific build
#

# Default no suppress anything
SUPRESS_PLUGINS=''

if [[ ( "${SYSTEM_ID}" =~ "CentOS_release_6" ) ]] 
then
    # Supresss Azure on CenOS 6
    SUPRESS_PLUGINS="$SUPRESS_PLUGINS -DUSE_AZURE=OFF"
fi


REMBED_EXCLUSION_BRANCHES=( "candidate-6.4.x" "candidate-7.4.x" )

if [[ " ${REMBED_EXCLUSION_BRANCHES[@]} " =~ " ${BRANCH_ID} " ]]
then
    # There is an R environmet and Rembed.cpp incompatibility on the candidate-64.34 branch,
    # so don't build it
    SUPRESS_PLUGINS="$SUPRESS_PLUGINS -DSUPPRESS_REMBED=ON"
fi

SQS_EXCLUSION_BRANCHES=( "candidate-7.6.x" "master" )
if [[ ( "${SYSTEM_ID}" =~ "CentOS_release_6" ) && (  " ${SQS_EXCLUSION_BRANCHES[@]} " =~ " ${BRANCH_ID} " ) ]] 
then
    # Old libcurl on Centos 6.x so exclude this from 7.6.x and perhaps later versions
    SUPRESS_PLUGINS="$SUPRESS_PLUGINS -DSUPPRESS_SQS=ON"
fi

AWS_EXCLUSION_BRANCHES=( "candidate-7.4.x" )
if [[ ( "${SYSTEM_ID}" =~ "CentOS_release_6" ) && (  " ${AWS_EXCLUSION_BRANCHES[@]} " =~ " ${BRANCH_ID} " ) ]] 
then
    # Old libcurl on Centos 6.x so exclude this from master and perhaps later versions
    # Buld problem with CentOS 6 and Devtoolset-7 it found Devtoolset-2 
    # (Perhaps it is some bug, but this is areally old branch, so exclude)
    SUPRESS_PLUGINS="$SUPRESS_PLUGINS -DUSE_AWS=OFF"
fi

BOOST_EXCLUSION_BRANCHES=( "candidate-7.4.x" )
if [[ "${SYSTEM_ID}" =~ "CentOS_release_6" ]] 
then
    if [[ " ${BOOST_EXCLUSION_BRANCHES[@]} " =~ " ${BRANCH_ID} " ]] 
    then
        # Old libcurl on Centos 6.x so exclude this from master and perhaps later versions
        # Buld problem with CentOS 6 and Devtoolset-7 it found Devtoolset-2 
        # (Perhaps it is some bug, but this is areally old branch, so exclude)
        SUPRESS_PLUGINS="$SUPRESS_PLUGINS -DCENTOS_6_BOOST=ON"
    else
        SUPRESS_PLUGINS="$SUPRESS_PLUGINS -DCENTOS_6_BOOST=ON"
    fi
fi

#
#----------------------------------------------------
#
# Regression tests macros
#

# Use complete-uninstall.sh to wipe HPCC
REGRESSION_WIPE_OFF_HPCC=1


# Control to Regression Engine
# 0 - skip Regression Engine execution (dry run to test framework)
# 1 - execute RE to run Regression Suite
EXECUTE_REGRESSION_SUITE=1

REGRESSION_SETUP_PARALLEL_QUERIES=$SETUP_PARALLEL_QUERIES
REGRESSION_PARALLEL_QUERIES=$TEST_PARALLEL_QUERIES

REGRESSION_NUMBER_OF_THOR_SLAVES=4

#if not already defined (by the sequencer) then define it
[ -z $REGRESSION_NUMBER_OF_THOR_CHANNELS ] && REGRESSION_NUMBER_OF_THOR_CHANNELS=1

REGRESSION_THOR_LOCAL_THOR_PORT_INC=20

[[ $REGRESSION_NUMBER_OF_THOR_CHANNELS -ne 1 ]] && REGRESSION_THOR_LOCAL_THOR_PORT_INC=20 

REGRESSION_TIMEOUT="" # Default 720 from ecl-test.json config file
if [[ "$BUILD_TYPE" == "Debug" ]]
then
    REGRESSION_TIMEOUT="--timeout 1800"
fi

# To tackle down the genjoin* timeout issues

if [[ "$BUILD_TYPE" == "RelWithDebInfo" &&  "$BRANCH_ID" == "candidate-7.2.x" ]]
then
    REGRESSION_TIMEOUT="--timeout 1800"
fi


# Enable stack trace generation
REGRESSION_GENERATE_STACK_TRACE="--generateStackTrace"

REGRESSION_EXCLUDE_FILES=""
if [[ "$BRANCH_ID" == "candidate-6.4.x" ]]
then
    REGRESSION_EXCLUDE_FILES="--ef couchbase-simple*,embedR*,modelingWithR*"
    REGRESSION_GENERATE_STACK_TRACE=""
fi

if [[ "$BRANCH_ID" == "candidate-7.0.x" ]]
then
    REGRESSION_EXCLUDE_FILES="--ef couchbase-simple*"
    REGRESSION_GENERATE_STACK_TRACE=""
fi

if [[ "$BRANCH_ID" == "candidate-7.2.x" ]]
then
    REGRESSION_EXCLUDE_FILES="--ef couchbase-simple*"
fi

if [[ "$BRANCH_ID" == "candidate-7.4.x" ]]
then
    REGRESSION_EXCLUDE_FILES="--ef pipefail.ecl,embedR*,modelingWithR*"
fi

REGRESSION_EXCLUDE_CLASS=""

PYTHON_PLUGIN=''

# To use local installation
#COUCHBASE_SERVER=$LOCAL_IP_STR
#COUCHBASE_USER=$USER

# Need to add private key into .ssh directory to use remote couchbase server
COUCHBASE_SERVER=10.240.62.177
COUCHBASE_USER=centos

REGRESSION_REPORT_RECEIVERS="attila.vamos@gmail.com,attila.vamos@lexisnexisrisk.com"
REGRESSION_REPORT_RECEIVERS_WHEN_NEW_COMMIT="richard.chapman@lexisnexisrisk.com,attila.vamos@lexisnexisrisk.com,attila.vamos@gmail.com"

#
#----------------------------------------------------
#
# Build & upload Coverity result
#

# Enable to run Coverity build and upload result

RUN_COVERITY=1
COVERITY_TEST_DAY=1    # Monday
COVERITY_TEST_BRANCH=master

#
#----------------------------------------------------
#
# Wutest macros
#

# Enable to run WUtest atfter Regression Suite
# If and only if the Regression Suite execution is enalbled
RUN_WUTEST=1
RUN_WUTEST=$(( $EXECUTE_REGRESSION_SUITE && $RUN_WUTEST ))


WUTEST_HOME=${TEST_ROOT}/testing/esp/wudetails
WUTEST_RESULT_DIR=${TEST_ROOT}/testing/esp/wudetails/results
WUTEST_BIN="wutest.py"
WUTEST_CMD="python3 ${WUTEST_BIN}"
WUTEST_LOG_DIR=${OBT_LOG_DIR}


#
#----------------------------------------------------
#
# Unit tests macros
#

# Enable to run unittests before execute Performance Suite
RUN_UNITTESTS=1
UNITTESTS_PARAM="-all"

if [[ ${QUICK_SESSION} -gt 0 ]]
then
    UNITTESTS_PARAM=""
fi

UNITTESTS_EXCLUDE=" JlibReaderWriterTestTiming AtomicTimingTest "

JlibSemTestStress_EXCLUSION_BRANCHES=( "candidate-7.2.x" "candidate-7.4.x" )

if [[ " ${JlibSemTestStress_EXCLUSION_BRANCHES[@]} " =~ "$BRANCH_ID" ]]
then
    [[ ! "${UNITTESTS_EXCLUDE[@]}" =~ "JlibSemTestStress" ]] && UNITTESTS_EXCLUDE+="JlibSemTestStress "
fi


#
#----------------------------------------------------
#
# WUtool test macros
#

# Enable to run WUtool test before execute any Suite
RUN_WUTOOL_TESTS=1


#
#----------------------------------------------------
#
# Performance tests macros
#

# Enable rebuild HPCC before execute Performance Suite
PERF_BUILD=1
PERF_BUILD_TYPE=RelWithDebInfo

PERF_CONTROL_TBB=0
PERF_USE_TBB=1
PERF_USE_TBBMALLOC=1

# Control the Performance Suite target(s)
PERF_RUN_HTHOR=1
PERF_RUN_THOR=1
PERF_RUN_ROXIE=1

# To controll core generation and logging test
PERF_RUN_CORE_TEST=1

# Control Performance test cluster
PERF_NUM_OF_NODES=1
PERF_IP_OF_NODES=( '127.0.0.1' )

# totalMemoryLimit for Hthor
PERF_HTHOR_MEMSIZE_GB=4

# totalMemoryLimit for Thor
PERF_THOR_MEMSIZE_GB=4

PERF_THOR_NUMBER_OF_SLAVES=4
#if not already defined (by the sequencer) then define it
[ -z $PERF_NUMBER_OF_THOR_CHANNELS ] && PERF_NUMBER_OF_THOR_CHANNELS=1

PERF_THOR_LOCAL_THOR_PORT_INC=100

# totalMemoryLimit for Roxie
PERF_ROXIE_MEMSIZE_GB=4

# Control to Regression Engine Setup phase
# 0 - skip Regression Engine setup execution (dry run to test framework)
# 1 - execute RE to run Performance Suite
EXECUTE_PERFORMANCE_SUITE_SETUP=1

# Control to Regression Engine
# 0 - skip Regression Engine execution (dry run to test framework)
# 1 - execute RE to run Performance Suite
EXECUTE_PERFORMANCE_SUITE=1

# timeout in seconds (-1 means no timeout in Regression Engine)
PERF_TIMEOUT=-1

# 0 - HPCC unistalled after Performance Suite finished on hthor
# 1 - performance test doesn't uninstall HPCC after executed tests
PERF_KEEP_HPCC=1

# 0 - HPCC stopped after Performance Suite finished on hthor
# 1 - Keep HPCC alive after executed tests
PERF_KEEP_HPCC_ALIVE=1

# Use complete-uninstall.sh to wipe HPCC
# 0 - HPCC doesn't wipe off
# 1 - HPCC does wipe off
PERF_WIPE_OFF_HPCC=0


PERF_SETUP_PARALLEL_QUERIES=$SETUP_PARALLEL_QUERIES
PERF_TEST_PARALLEL_QUERIES=1

# Example:
#PERF_QUERY_LIST="04ae_* 04cd_* 04cf_* 05bc_* 06bc_*"
PERF_EXCLUDE_CLASS="-e stress"

# Don't use these settings on this machine (yet)
#PERF_FLUSH_DISk_CACHE="--flushDiskCache --flushDiskCachePolicy 1 "
#PERF_RUNCOUNT="--runcount 2"

PERF_TEST_MODE="STD"

if [ -n "$PERF_FLUSH_DISK_CACHE" ]
then
    PERF_TEST_MODE="CDC"
fi

if [ -n "$PERF_RUNCOUNT" ]
then
    loop=$( echo $PERF_RUNCOUNT | awk '{ print $2}' )
    PERF_TEST_MODE=$PERF_TEST_MODE"+${loop}L"
fi

PERF_ENABLE_CALCTREND=1
PERF_CALCTREND_PARAMS=""

#
#----------------------------------------------------
#
# Machine Lerning tests macros
#

# Enable to run ML tests before execute Performance Suite
RUN_ML_TESTS=1

# 0 - HPCC unistalled after Machine Learning finished on hthor
# 1 - Machine Learning test doesn't uninstall HPCC after executed tests
ML_KEEP_HPCC=1

# Use complete-uninstall.sh to wipe HPCC
# 0 - HPCC doesn't wipe off
# 1 - HPCC does wipe off
ML_WIPE_OFF_HPCC=1


# Enable rebuild HPCC before execute Machine Lerning Suite
ML_BUILD=0
ML_BUILD_TYPE=$BUILD_TYPE

# Control the target(s)
ML_RUN_THOR=1
ML_THOR_MEMSIZE_GB=4

if [[ $NUMBER_OF_CPUS -ge 20 ]]
then
    ML_THOR_NUMBER_OF_SLAVES=8
else
    ML_THOR_NUMBER_OF_SLAVES=$(( $NUMBER_OF_CPUS - 2 ))
fi

# Control to Regression Engine
# 0 - skip Regression Engine execution (dry run to test framework)
# 1 - execute RE to run Performance Suite
EXECUTE_ML_SUITE=1

# timeout in seconds (-1 means no timeout in Regression Engine)
ML_TIMEOUT=-1
ML_PARALLEL_QUERIES=1

#
#----------------------------------------------------
#
# Export variables
#

set +a

#
#----------------------------------------------------
#
# Common functions
#

[[ -f ${OBT_BIN_DIR}/utils.sh ]] && . ${OBT_BIN_DIR}/utils.sh

# End of settings.sh
