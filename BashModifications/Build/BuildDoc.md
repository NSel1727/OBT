## Commented Code Removals

Line 254:
```
#subRes=$( SubmoduleUpdate "--init" )
```

Line 365:
```
#WriteLog "Regression exclusion:${REGRESSION_EXCLUDE_CLASS} (class), ${REGRESSION_EXCLUDE_FILES} (file)" "${OBT_BUILD_LOG_FILE}"
```

Line 417:
```
#BOOST_PKG="boost_1_71_0.tar.gz"
```

Lines 455-457:
```
#mkdir -p ${BUILD_HOME}/downloads
#res=$( cp -v  $HOME/$BOOST_PKG ${BUILD_HOME}/downloads/  2>&1 )
#WriteLog "res: ${res}" "${OBT_BUILD_LOG_FILE}"
```
                
Line 553:
```
#chmod 777 ${STAGING_DIR}/${SHORT_DATE}
```

## Other Changes

Add Consistency in Snake Case:

buildResult -> Build_Result
changesInInstalled -> Changes_In_Installed
changesInDownloads -> Changes_In_Downloads

