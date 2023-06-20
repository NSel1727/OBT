## Remove Commented Code

Lines 44-46:
```
#if [[ -f ~/cov-analysis-linux64-8.7.0/bin/cov-build ]]
              #if [[ -f ~/cov-analysis-linux64-2019.03/bin/cov-build ]]
              #if [[ -f ~/cov-analysis-linux64-2021.12.1/bin/cov-build ]]
```
              
Line 60:
```
#mv ${REPORT_PATH}/${REPORT_FILE_NAME} ${REPORT_PATH}/${REPORT_FILE_NAME}.prev
```

Lines 64-67:
```
#~/cov-analysis-linux64-6.6.1/bin/cov-build --dir cov-int make -j
            #~/cov-analysis-linux64-8.5.0.3/bin/cov-build --dir cov-int make -j
            #~/cov-analysis-linux64-2019.03/bin/cov-build --dir cov-int make -j ${NUMBER_OF_BUILD_THREADS}
            #~/cov-analysis-linux64-2021.12.1/bin/cov-build  --dir cov-int make -j ${NUMBER_OF_BUILD_THREADS}
```

## Other Changes

Remove Unused Variable:

```
NEXT_TEST_DAY=$(date -d "next Sunday +$COVERITY_TEST_DAY days")
```

Ensure Consistent Snake Case:

branchCrc -> BRANCH_CRC
curlParams -> CURL_PARAMS
