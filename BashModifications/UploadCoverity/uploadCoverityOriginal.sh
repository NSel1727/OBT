#!/bin/bash

# Git branch settings

. ./settings.sh

SHORT_DATE=$(date "+%Y-%m-%d")
REPORT_FILE_NAME=hpcc-$SHORT_DATE.tgz

WEEK_DAY=$(date "+%w")
RECEIVERS=attila.vamos@lexisnexisrisk.com,attila.vamos@gmail.com

if [ -f coverityToken.dat ]
then
    echo "Get Coverity upload token."
    COVERITY_TOKEN=$(cat coverityToken.dat)
    echo "Done."
else
    echo "Send Email to ${RECEIVERS} about missing 'coverityToken'."
    echo -e "Hi,\n\nCoverity analysis upload failed on missing coverityToken.\n\nThanks\n\nOBT" | mailx -s "Missing coverityToken" -u root  ${RECEIVERS}
    exit -1
fi


if [[ -f ${COVERITY_REPORT_PATH}/${REPORT_FILE_NAME} ]]
then
    echo "Start Coverity scan upload."

    # To upload
    # When you upload the build can you also include the commit SHA in the version (Gavin)
    #

    echo "Get ${BRANCH_ID} branch SHA"
    pushd ~/build/CE/platform/HPCC-Platform/
          
    branchCrc=$( git log -1 | grep '^commit' | cut -s -d' ' -f 2)

    #branchCrc=db01fc58b205926f02dda2963a0c0e562b6331f3
            
    echo ${branchCrc}
    popd

    curl --form token=$COVERITY_TOKEN \
      --form email=${ADMIN_EMAIL_ADDRESS} \
      --form file=@${COVERITY_REPORT_PATH}/${REPORT_FILE_NAME} \
      --form version="${BRANCH_ID}-SHA:${branchCrc}" \
      --form description=" " \
      https://scan.coverity.com/builds?project=HPCC-Platform

    #echo "$res"
else
    echo "Coverity scan file not found."
fi        

echo "End."

