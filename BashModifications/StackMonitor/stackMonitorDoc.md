## Removed Commented Code

Line 6:
```
#LOG_FILE_NAME=/dev/stdout
```

Line 28:
```
#echo "pid: '${pid}' $( date +%Y-%m-%d-%H-%M-%S ):"
```

## Other Changes

Remove Uneeded Variable:

Original:
```
CPU_INFO=1
```
```
if [[ CPU_INFO -eq 1 ]]
then
    echo "CPU info:"  >> ${LOG_FILE_NAME}
    cat /proc/cpuinfo >> ${LOG_FILE_NAME}
    echo "================================"  >> ${LOG_FILE_NAME}
fi
```

Updated:
```
echo "CPU info:"  >> ${LOG_FILE_NAME}
cat /proc/cpuinfo >> ${LOG_FILE_NAME}
echo "================================"  >> ${LOG_FILE_NAME}
```

If statement is removed becuase the variable is always set to 1. Since it is not used anywhere else, the variable is removed.

