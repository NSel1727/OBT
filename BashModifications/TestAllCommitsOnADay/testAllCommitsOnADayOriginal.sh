#!/bin/bash

PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }' 
#set -x

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

sourcePath=~/build/CE/platform/HPCC-Platform
if [ ! -d $sourcePath ]
then
    sourcePath=~/HPCC-Platform
    if [ ! -d $sourcePath ]
    then
        echo "$sourcePath not exists."
        exit
    fi
fi

BRANCH_ID=master
DEBUG=0
PERFORMANCE_QUERY_LIST="01* 02* 03* 04* 05* 06* 07*"
CWD=$( pwd ) 
targetFile="${PWD}/settings.inc"

testDate="2017-12-05"
before=4
after=2

GetAllCommitsShaOnDay()
{
#    set -x
    testDate=$1
    before=$2
    after=$3
 
    if [[ -n $before ]]
    then
        sourceDate=$( date -I -d "$testDate - $before day" )
    else
        sourceDate=$( date -I -d "$testDate - 1 day" )
    fi
 
    if [[ -n $after ]]
    then
        testDate=$( date -I -d "$testDate + $after day" )
    fi
    
    printf "On %s (Between %s and %s)\n" "$1" "$sourceDate" "$testDate"
    pushd ${sourcePath} > /dev/null

    # to restore whole commit tree
    git checkout -f ${BRANCH_ID} 2> /dev/null
    
    while read c
    do 
        #echo "commit: $c"
        commits+=($(printf "%s\n" "$c" ))
        #echo "len: ${#commits[@]}"
        #echo "commits: ${commits[@]} "
    done < <(git log --after="$sourceDate 00:00" --before="$testDate 00:00$" --merges --reverse | grep 'commit' | cut -d' ' -f2)
    #echo "len: ${#commits[@]}"
    #echo "${commits[@]}"
    
    popd > /dev/null
#    set +x
}


printf "On %s\n" "$testDate"
GetAllCommitsShaOnDay "$testDate" "$before" "$after"

if [ $DEBUG -eq 1 ]
then
    echo "len: ${#commits[*]}"
    echo "${commits[@]}"
fi

commitCount=${#commits[*]}
i=0

if [ $DEBUG -eq 0 ] 
then
    sudo service ntpd stop
fi

IS_SCL=$( type "scl" 2>&1 )
if [[ "${IS_SCL}" =~ "not found" ]]
then 
    printf "SCL is not installed."
else 
    id=$( scl -l | grep -c 'devtoolset' )
    if [[ $id -ne 0 ]]
    then
        DEVTOOLSET=$(  scl -l | tail -n 1 )
        printf "%s is installed." "${DEVTOOLSET}"
        . scl_source enable ${DEVTOOLSET}
        export CL_PATH=/opt/rh/${DEVTOOLSET}/root/usr;
    else
        printf "DEVTOOLSET is not installed."
    fi
fi

printf "Commit\n"
for testSha in ${commits[@]}
do 
    printf "%s\n" $testSha
    
    # create setting.inc with SHA
    printf "# test date:%s \n" "$testDate" > ${targetFile}
    printf "SHA=%s\n\n" "$testSha" >> ${targetFile}
    printf "PERFORMANCE_QUERY_LIST=\"%s\"\n\n" "$PERFORMANCE_QUERY_LIST" >> ${targetFile}

    if [ $DEBUG -eq 0 ] 
    then
        # magic with date set it back to original test date (one minute after midnight)
        sudo date -s "$testDate $i:01:00"
        date
        
        # Execute OBT with performance test
        ./obtMain.sh perf
        
        rename 6.5.0.csv 6.5.0-${testSha:0:8}.csv ~/Perfstat/*.csv
        rename 6.4.1.csv 6.4.1-${testSha:0:8}.csv ~/Perfstat/*.csv

        
        #  Restore the correct date with NTPD 
        sudo ntpdate time.nist.gov
        date
    fi

    i=$(( $i + 1 ))
    
    if [ $DEBUG -eq 1 ]
    then
        if [[ $i -gt 10 ]]
        then
            break
        fi
    fi
done

if [ $DEBUG -eq 0 ] 
then
    sudo service ntpd start
fi

printf "On %s there were %d commits \n" $testDate $commitCount
