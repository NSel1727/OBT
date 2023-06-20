## Removed Commented Code

Line 40:
```
#DATE="${DATE_SHORT}_$TIMESTAMP{}"
```

Line 95:
```
#clear
```

Line 107:
```
#ARCHIVE_NAME=$1
```

Line 109:
```
#param=${param//-/}
```

Line 136:
```
#ARCHIVE_NAME=internal
```

Line 143:
```
#MOVE_OBT_CONSOLE_LOG_TO_ZIP_FLAG=-m
```

Line 344:
```
#zip ${FULL_ARCHIVE_TARGET_DIR}/${ARCHIVE_NAME} -r ${HPCC_LOG_DIR} >> ${FULL_ARCHIVE_TARGET_DIR}/${ARCHIVE_NAME}.log 
```

Lines 407-409:
```
#base=$( dirname $core )
                #lastSubdir=${base##*/}
                #comp=${lastSubdir##my}
```
                
## Other Changes

Modified CheckAndZip to have Default Parameters:
```
    flags=${1:-${MOVE_TO_ZIP_FLAG}}
    target=${2:-${FULL_ARCHIVE_TARGET_DIR}/${ARCHIVE_NAME}}
    sourceDir=${3:-${ARCHIVE_NAME}}
    source=$4
    log=${5:-${FULL_ARCHIVE_TARGET_DIR}/${ARCHIVE_NAME}.log}
```

Calling Default Parameters Example:
```
CheckAndZip "" "" "" "obt-*.log" ""
```

