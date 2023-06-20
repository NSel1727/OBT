## Removed Commented Code

Line 60:
```
#lineCount=0
```

Lines 64-73:
```
    #if [[ ${lineCount} -eq 0 ]]
    #then
    #    WriteHeaders
    #fi

    #lineCount=$(( ${lineCount} + 1))
    #if [[ ${lineCount} -eq ${HEADER_ON_EVERY_LINES} ]]
    #then
    #    #lineCount=0
    #fi
```
                
## Remove Unused Variable

```
HEADER_ON_EVERY_LINES=30
```

