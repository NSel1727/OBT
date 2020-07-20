#!/bin/bash


#
#------------------------------
#
# Imports (settings, functions)
#

# Git branch settings

. ./settings.sh

#
#------------------------------
#


PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' 
#set -x

sourcePath=~/build/CE/platform/HPCC-Platform
BRANCH_ID=master

TIME_SERVER=$( grep ^server /etc/ntp.conf | head -n 1 | cut -d' ' -f2 )


IS_SCL=$( type "scl" 2>&1 )
if [[ "${IS_SCL}" =~ "not found" ]]
then 
    printf "SCL is not installed.\n"
else 
    id=$( scl -l | grep -c 'devtoolset' )
    if [[ $id -ne 0 ]]
    then
        DEVTOOLSET=$(  scl -l | tail -n 1 )
        printf "%s is installed.\n" "${DEVTOOLSET}"
        . scl_source enable ${DEVTOOLSET}
        export CL_PATH=/opt/rh/${DEVTOOLSET}/root/usr;
    else
        printf "DEVTOOLSET is not installed.\n"
    fi
fi

GetCommitSha()
{
    #set -x
    testDate=$1
    sourceDate=$( date -I -d "$testDate - 1 day" )
    
    pushd ${sourcePath} > /dev/null

    # to restore whole commit tree
    git checkout -f ${BRANCH_ID} > /dev/null 2>&1
    
    sha=$( git log --after="$sourceDate 00:00" --before="$testDate 00:00$" --merges | grep -A3 'commit' | head -n 1 | cut -d' ' -f2 )
    until [[ -n "$sha" ]]
    do
        # step one day back
        sourceDate=$( date -I -d "$sourceDate - 1 day" )
        # Get SHA
        sha=$( git log --after="$sourceDate 00:00" --before="$testDate 00:00$" --merges | grep -A3 'commit' | head -n 1 | cut -d' ' -f2 )
    done

    # to restore whole commit tree
    git checkout -f ${BRANCH_ID} > /dev/null 2>&1

    
    popd > /dev/null
    #set +x

    sha=${sha:0:8}
    sha=${sha^^}
    
    echo $sha
}


CWD=$( pwd ) 
targetFile="${PWD}/settings.inc"

direction="forward"
#direction="backward"

dayCount=0
daySkip=1

if [[ "$direction" == "forward" ]]
then
    # Forward
    firsTestDate="2020-06-24"
    lastTestDate="2020-06-27"

    testDate=$firsTestDate
else
    #  Backward
    lastTestDate="2017-08-27"
    firsTestDate="2017-08-21"
    # back 4 weeks
    #firsTestDate=$( date -I -d "$lastTestDate - 27 days")
    # back one week
    #firsTestDate=$( date -I -d "$lastTestDate - 6 days")

    testDate=$lastTestDate
fi

printf "from %s to %s direction %s\n" "$firsTestDate" "$lastTestDate" "$direction"

#sudo service ntpd stop


printf "Test date\tcommit\n"
# forward
until [[ "$testDate" > "$lastTestDate" ]]
# backward
#until [[ "$testDate" < "$firsTestDate" ]]
do 
    testSha=$( GetCommitSha "$testDate" )

    #printf "%s\t%s\n" "$testDate" "$testSha"

    export JOB_NAME_SUFFIX="#${testSha}"

    # create setting.inc with SHA
    printf "# Generated by $0 on %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" > ${targetFile}
    printf "PERF_TEST_DATE=\"%s\"\n" "$testDate" >> ${targetFile}
    printf "SHA=%s\n" "$testSha" >> ${targetFile}
    printf "JOB_NAME_SUFFIX=\"--jobnamesuffix %s\"\n" "${testSha}" >> ${targetFile}
    
    
    cat ${targetFile}

    # magic with date set it back to original test date (one minute after midnight)
    #sudo date -s "$testDate 00:01:00"

    #date

    # Execute OBT with performance test
    ./obtMain.sh perf
    
    #  Restore the correct date with NTPD 
    #sudo ntpdate $TIME_SERVER
    #sudo ntpd -gq
    #date
    
    # next test date
    if [[ "$direction" == "forward" ]]
    then
        testDate=$( date -I -d "$testDate + $daySkip day")
    else
        testDate=$( date -I -d "$testDate - $daySkip day")
    fi
    dayCount=$(( $dayCount + 1 ))
    
    printf "-----------------------------------------------------------------\n"

done

printf "day counts:%d\n" $dayCount

#sudo service ntpd start
