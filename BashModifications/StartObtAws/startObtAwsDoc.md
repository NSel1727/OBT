## Removed Commented Code

Line 137:
```
#INSTANCE_NAME=${INSTANCE_NAME//PR/PR-}
```

Lines 169-171:
```
# BASE_TAG=${param//baseTest=/}
                # BASE_TAG=${BASE_TAG//\"/}
                # WriteLog "Execute base test with tag: ${BASE_TAG}" "$LOG_FILE"
```
                
## Other Changes

Removed Unused Variables:
```
AVERAGE_SESSION_TIME=1.0 # Hours
```

Consistent Multi-Word Variable Snake Case:

errorCode -> ERROR_CODE
errorTitle -> ERROR_TITLE
errorMsg -> ERROR_MSG
instanceName -> INSTANCE_NAME
commitId -> COMMIT_ID
runningInstanceID -> RUNNING_INSTANCE_ID
publicIP -> PUBLIC_IP
timeStamp -> TIME_STAMP
instanceId -> INSTANCE_ID
instanceInfo -> INSTANCE_INFO
volumeId -> VOLUME_ID
tryCount -> TRY_COUNT
