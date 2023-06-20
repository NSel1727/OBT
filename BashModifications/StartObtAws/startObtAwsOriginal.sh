#!/bin/bash

PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
#set -x


LOG_FILE="/dev/null"

#
#------------------------------
#
# Import settings
#
# WriteLog() function

. ~/smoketest/timestampLogger.sh

res=$( declare -f -F WriteLog  2>&1 )
    
if [ $? -ne 0 ]
then
    echo "WriteLog() function is missing (${res}, cwd: $(pwd)) try to import again"
    . ~/smoketest/timestampLogger.sh
    res=$( declare -f -F WriteLog  2>&1 )
fi

WriteLog "res: ${res}" "$LOG_FILE"


#
#------------------------------
#
# Functions
#

MyExit()
{
    errorCode=$1
    errorTitle=$2
    errorMsg=$3
    instanceName=$4
    commitId=$5

    # Check if instance running
    runningInstanceID=$( aws ec2 describe-instances --filters "Name=tag:Name,Values=${instanceName}" "Name=tag:Commit,Values=${commitId}" --query "Reservations[].Instances[].InstanceId" --output text )
    publicIP=$( aws ec2 describe-instances --filters "Name=tag:Name,Values=${instanceName}" "Name=tag:Commit,Values=${commitId}" --query "Reservations[].Instances[].PublicIpAddress" --output text )
    [[ -z ${publicIP} ]] && publicIP="N/A"
    WriteLog "MyExit(): Public IP: ${publicIP}" "$LOG_FILE"
    
    if [[ -n ${runningInstanceID} ]]
    then
        terminate=$( aws ec2 terminate-instances --instance-ids ${runningInstanceID} 2>&1 )
        WriteLog "MyExit(): Terminate in instance result:\n ${terminate}" "$LOG_FILE"
    else
        WriteLog "MyExit(): Running instance ID not found." "$LOG_FILE"
    fi

    (echo "At $(date "+%Y.%m.%d %H:%M:%S") session (instance ID: ${runningInstanceID} on IP: ${publicIP}) exited with error code: $errorCode."; echo "${errorMsg}"; echo "${terminate}" ) | mailx -s "Abnormal end of session $instanceName ($commitId) on ${publicIP}" attila.vamos@gmail.com,attila.vamos@lexisnexisrisk.com

    exit $errorCode
}

CompressAndDownload()
{
    param=$1
    
    WriteLog "Compress and download HPCCSystems logs..." "$LOG_FILE"
    res=$( ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS} centos@${instancePublicIp} "[ -d /var/log/HPCCSystems ] && ( zip -u /home/centos/smoketest/${INSTANCE_NAME}/HPCCSystems-logs-$(date '+%y-%m-%d_%H-%M-%S') -r /var/log/HPCCSystems/* > /home/centos/smoketest/${INSTANCE_NAME}/HPCCSystems-logs-$(date '+%y-%m-%d_%H-%M-%S').log 2>&1 ) || echo \"There is no /var/log/HPCCSystems/ directory.\" " 2>&1 )
    WriteLog "Res: $res" "$LOG_FILE"

    res=$( rsync -va --timeout=60 -e "ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS}" centos@${instancePublicIp}:/home/centos/smoketest/${INSTANCE_NAME}/HPCCSystems-logs-* ${SMOKETEST_HOME}/${INSTANCE_NAME}/ 2>&1 )
    WriteLog "Res: $res" "$LOG_FILE"
    
    if [[ -z "$param" ]]
    then
        WriteLog "Compress and download pullRequests*.json file(s)..." "$LOG_FILE"
        res=$( ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS} centos@${instancePublicIp} "zip -u /home/centos/smoketest/pullRequests-$(date '+%y-%m-%d_%H-%M-%S') /home/centos/smoketest/pullRequests*.json > /home/centos/smoketest/pullRequests-$(date '+%y-%m-%d_%H-%M-%S').log 2>&1 " 2>&1 )
        WriteLog "Res: $res" "$LOG_FILE"

        res=$( rsync -va --timeout=60 -e "ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS}" centos@${instancePublicIp}:/home/centos/smoketest/pullRequests-* ${SMOKETEST_HOME}/${INSTANCE_NAME}/ 2>&1 )
        WriteLog "Res: $res" "$LOG_FILE"
    else
        WriteLog "Compress and download HPCCSystems-regression/log and zap directories ..." "$LOG_FILE"
        timeStamp="$(date '+%y-%m-%d_%H-%M-%S')"
        res=$( ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS} centos@${instancePublicIp} "zip -u /home/centos/smoketest/HPCCSystems-regression-$timeStamp /home/centos/smoketest/${INSTANCE_NAME}/HPCCSystems-regression/log/*  > /home/centos/smoketest/HPCCSystems-regression-$timeStamp.log 2>&1 " 2>&1 )
        WriteLog "Res: $res" "$LOG_FILE"
        res=$( ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS} centos@${instancePublicIp} "zip -u /home/centos/smoketest/HPCCSystems-regression-$timeStamp /home/centos/smoketest/${INSTANCE_NAME}/HPCCSystems-regression/zap/*  > /home/centos/smoketest/HPCCSystems-regression-$timeStamp.log 2>&1 " 2>&1 )
        WriteLog "Res: $res" "$LOG_FILE"

        res=$( rsync -va --timeout=60 -e "ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS}" centos@${instancePublicIp}:/home/centos/smoketest/HPCCSystems-regression-$timeStamp* ${SMOKETEST_HOME}/${INSTANCE_NAME}/ 2>&1 )
        WriteLog "Res: $res" "$LOG_FILE"
    
    fi
    
    WriteLog "Check and download email from Cron..." "$LOG_FILE"
    res=$(  rsync -va --timeout=60 -e "ssh -i ${SSH_KEYFILE} ${SSH_OPTIONS}" centos@${instancePublicIp}:/var/mail/centos ${SMOKETEST_HOME}/${INSTANCE_NAME}/centos-$(date '+%y-%m-%d_%H-%M-%S').mail 2>&1 )
    WriteLog "Res: $res" "$LOG_FILE"
}

CreateResultFile()
{
    MSG=$1
    C_ID=$2
    RESULT_FILE=${SMOKETEST_HOME}/${INSTANCE_NAME}/result-${TIME_STAMPT}.log
    echo "${MSG}" > $RESULT_FILE
    echo "1/1. Process ${INSTANCE_NAME}, label: ${MSG}" >> $RESULT_FILE 
    echo " sha : ${C_ID} " >> $RESULT_FILE
    echo " Summary : 0 sec (00:00:00) " >> $RESULT_FILE
    echo " pass : False " >> $RESULT_FILE
}

#
#------------------------------
#
# Main
#

DOCS_BUILD=0
SMOKETEST_HOME=$(pwd)
ADD_GIT_COMMENT=0
INSTANCE_NAME="PR-12701"
DRY_RUN=''  #"-dryRun"
AVERAGE_SESSION_TIME=1.0 # Hours
TIME_STAMPT=$( date "+%y-%m-%d_%H-%M-%S" )
APP_ID=$(hostname)
BASE_TEST=''

while [ $# -gt 0 ]
do
    param=$1
    param=${param#-}
    WriteLog "Param: ${param}" "$LOG_FILE"
    case $param in
    
        instance*)  INSTANCE_NAME=${param//instanceName=/}
                INSTANCE_NAME=${INSTANCE_NAME//\"/}
                #INSTANCE_NAME=${INSTANCE_NAME//PR/PR-}
                WriteLog "Instancename: '${INSTANCE_NAME}'" "$LOG_FILE"
                ;;
                
        docs*)  DOCS_BUILD=${param}
                WriteLog "Build docs: '${DOCS_BUILD}'" "$LOG_FILE"
                ;;
                
        smoketestH*) SMOKETEST_HOME=${param//smoketestHome=/}
                SMOKETEST_HOME=${SMOKETEST_HOME//\"/}
                WriteLog "Smoketest home: '${SMOKETEST_HOME}'" "$LOG_FILE"
                ;;
                
        addGitC*) ADD_GIT_COMMENT=${param}
                WriteLog "Add git comment: ${ADD_GIT_COMMENT}" "$LOG_FILE"
                ;;
                
        commit*) COMMIT_ID=${param}
                WriteLog "CommitID: ${COMMIT_ID}" "$LOG_FILE"
                C_ID=${COMMIT_ID//commitId=/}
                ;;
                
        dryRun) DRY_RUN=${param}
                WriteLog "Dry run: ${DRY_RUN}" "$LOG_FILE"
                ;;
                
        appId) APP_ID=${param}
                WriteLog "App ID: ${APP_ID}" "$LOG_FILE"
                ;;
                
        baseTest*) BASE_TEST=${param}
                WriteLog "Base test: ${BASE_TEST}" "$LOG_FILE"
#                BASE_TAG=${param//baseTest=/}
#                BASE_TAG=${BASE_TAG//\"/}
#                WriteLog "Execute base test with tag: ${BASE_TAG}" "$LOG_FILE"
                ;;
                
        base*) BASE=${param//base=/}
                WriteLog "Base : ${BASE}" "$LOG_FILE"
                ;;
                
        jira*) JIRA=${param//jira=/}
                WriteLog "Jira : ${JIRA}" "$LOG_FILE"
                ;;                
        
    esac
    shift
done

REGION="ca-central-1" #$(aws configure get region)
WriteLog "Param: region= ${REGION}" "$LOG_FILE"
SSH_KEYFILE="~/HPCC-Platform-Smoketest.pem"
SSH_OPTIONS="-oConnectionAttempts=1 -oConnectTimeout=20 -oStrictHostKeyChecking=no"

OBT_AWS_INSTANCE='i-0385b05c486283a53'

WriteLog "Start OBT-AWS01" "$LOG_FILE"
echo " aws ec2 start-instances --region \"$REGION\" --instance-ids \"$OBT_AWS_INSTANCE\""
instance=$( aws ec2 start-instances --region "$REGION" --instance-ids "$OBT_AWS_INSTANCE" 2>&1 )
retCode=$?
WriteLog "Ret code: $retCode" "$LOG_FILE"
WriteLog "Instance: $instance" "$LOG_FILE"

instanceId=$( echo "$instance" | egrep 'InstanceId' | tr -d '", ' | cut -d : -f 2 )
WriteLog "Instance ID: $instanceId" "$LOG_FILE"

if [[ -z "$instanceId" ]]
then
    WriteLog "Instance creation failed, exit" "$LOG_FILE"
    WriteLog "$instance" > ${SMOKETEST_HOME}/${INSTANCE_NAME}/build.summary
    # Give a chance to re-try.
    [[ -f ${SMOKETEST_HOME}/${INSTANCE_NAME}/build.summary ]] && rm ${SMOKETEST_HOME}/${INSTANCE_NAME}/build.summary

    # Create result-yy-mm-dd_hh-mm-ss.log file to ensure it is appear in listtest.sh output   
    CreateResultFile "Instance creation failed, exit" "${C_ID}"
   
    MyExit "-1" "Instance creation failed, exit" "$instance" "${INSTANCE_NAME}" "${C_ID}"
fi

instanceInfo=$( aws ec2 describe-instances  --region ${REGION} --instance-ids ${instanceId} 2>&1 | egrep -i 'instan|status|publicip|privateip|volume' )
WriteLog "Instance info: $instanceInfo" "$LOG_FILE"

if [[ $instanceInfo =~ "InvalidInstanceID.NotFound" ]]
then
    WriteLog "Instance start failed, exit" "$LOG_FILE"

    MyExit "-1" "Error:${instanceInfo}, exit" "$instance" "${INSTANCE_NAME}" "${C_ID}"
fi

if [[ $REGION =~ 'us-east-1' ]]
then
    instancePublicIp=$( echo "$instanceInfo" | egrep 'PrivateIpAddress' | head -n 1 | tr -d '", ' | cut -d : -f 2 )
else
    instancePublicIp=$( echo "$instanceInfo" | egrep 'PublicIpAddress' | tr -d '", ' | cut -d : -f 2 )
fi

tryCount=5
delay=10 # sec
while [[ -z "$instancePublicIp" ]]
do
    WriteLog "Instance has not public IP yet, wait for ${delay} sec and try again." "$LOG_FILE"
    sleep ${delay}
    instanceInfo=$( aws ec2 describe-instances  --region ${REGION} --instance-ids ${instanceId} 2>&1 | egrep -i 'instan|status|publicip|privateip|volume' )
    WriteLog "Instance info: $instanceInfo" "$LOG_FILE"
    if [[ $REGION =~ 'us-east-1' ]]
    then
        instancePublicIp=$( echo "$instanceInfo" | egrep 'PrivateIpAddress' | head -n 1 | tr -d '", ' | cut -d : -f 2 )
    else
        instancePublicIp=$( echo "$instanceInfo" | egrep 'PublicIpAddress' | tr -d '", ' | cut -d : -f 2 )
    fi
    WriteLog "Public IP: '${instancePublicIp}'" "$LOG_FILE"
    tryCount=$(( $tryCount - 1 ))
    [[ $tryCount -eq 0 ]] && break;
done

if [[ -z "$instancePublicIp" ]]
then
    WriteLog "Instance has not public IP exit" "$LOG_FILE"
    WriteLog "$instance" > ${SMOKETEST_HOME}/${INSTANCE_NAME}/build.summary
   
    MyExit "-1" "Instance has not public IP, exit" "$instance" "${INSTANCE_NAME}" "${C_ID}"
fi
WriteLog "Public IP: '${instancePublicIp}'" "$LOG_FILE"

WriteLog "Remove Public IP: ${instancePublicIp} from know_hosts to prevent SSH warning \n(man-in-the-middle attack) when public IP address is reused by AWS." "$LOG_FILE"
res=$( ssh-keygen -R ${instancePublicIp} -f ~/.ssh/known_hosts 2>&1 )
WriteLog "Res: ${res}\n" "$LOG_FILE"


volumeId=$( echo "$instanceInfo" | egrep 'VolumeId' | tr -d '", ' | cut -d : -f 2 )
WriteLog "Volume ID: $volumeId" "$LOG_FILE"
        
WriteLog "Wait for a while for initialise instance" "$LOG_FILE"
sleep 20

WriteLog "Done." "$LOG_FILE"

