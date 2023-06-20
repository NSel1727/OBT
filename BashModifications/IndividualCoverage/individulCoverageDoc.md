## Commented Code Removals

Line 46:
```
#TARGET=hthor
```

Line 58:
```
#IFS=:$'\n'
```

Line 61:
```
#local testCases
```

Line 78:
```
#ut=${version#=}
```

Line 87:
```
#echo "excluded on "$plat
```

Lines 106-107:
```
#echo ${testCases[@]}
#declare -pa testCases;
```
                
Lines 144-146:
```
# WriteLog "Zip coverage data file for $1" "${COVERAGE_LOG_FILE}"
# WriteLog "CMD: zip -r ${COVERAGE_ROOT}/coverage_$1_gcxx.zip /home/ati/HPCC-Platform-build/ -i *.gc*" "${COVERAGE_LOG_FILE}"
# zip -r  ${COVERAGE_ROOT}/coverage_$1_gcxx.zip /home/ati/HPCC-Platform-build/ -i *.gc*
```
    
Line 180:
```
#cmd="./ecl-test query -t $2 $1"
```

Line 287:
```
#res=$( $cmd 2>&1 )
```

## Other Changes

Remove Unused Variables

```
ECL_FILE_DIR=${TEST_HOME}/ecl/
```
