## Removed Commented Code

Line 3:
```
#echo "logfile:"$1
```

Line 54:
```
#WriteLog "Params ($#): $@" "$logFile"
```

Lines 56-58:
```
#WriteLog "BASH_SOURCE: ${BASH_SOURCE[@]}" "$logFile"
#WriteLog "BASH_LINENO: ${BASH_LINENO[@]}" "$logFile"
#WriteLog "FUNCNAME: ${FUNCNAME[@]}" "$logFile"
```
    
Line 169:
```
#WriteLog "Used ports before HPCC started:\n ${portUsage}\n----------------------" "$logFile"
```

