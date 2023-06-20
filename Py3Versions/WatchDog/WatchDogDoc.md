**Note:** The only changes 2to3 added were unnecessary extra parenthesis, so these changes are ignored.

## Removed Commented Code

Line 3:
```
#import os
```

Line 188:
```
#selfName = os.path.basename(sys.argv[0])
```

Lines 202-203:
```
#psCmd = "sudo ps aux | grep '["+process[0]+"]"+process[2:]+"'"
#psCmd += " | awk '{print $2 \",\" $12}' "
```

Line 206:
```
#psCmd += " | awk '{print $1 \",\" $5}' "
```

## Other Changes

**Removed Unneeded Import**

```
    from sets import Set 
```

Used built in set() instea of Set()

**Added Function to Get Result String**

```
def getResult(myProc, inputStr):
    (myStdout,  myStderr) = myProc.communicate(inputStr)
    return myStdout + myStderr
```

Calling it:
```
result = getResult(myProc, "Boglarka990405")
```

