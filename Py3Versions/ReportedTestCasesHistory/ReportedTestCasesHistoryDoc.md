## 2to3 Changes

**Note:** Unneeded extra parenthesis changes ignored

**Change on line 12**

Original:
```
from itertools import izip
```
Update: Import Removed

**Change on line 96**

Original:
```
return izip(*[iter(iterable)]*n)
```
Update:
```
return zip(*[iter(iterable)]*n)
```

## Removed Commented Code

Lines 3-6:
```
#import os
#import time
#import glob
#import re
```
            
Lines 8-9:
```
#import inspect
#import traceback
```
            
Line 99:
```
#self.stats = { 'Bad': 0,  'Ugly': 0, 'Ugly and Bad': 0, 'Good': 0, 'Known': 0, 'Active': 0 }
```

Lines 219-223:
```
#except KeyError as e:
    #                # If exception occured that means this test is not reported at the last day
    #                # It becomes neutral
    #                self.stats['Neutral'] += 1
    #                PrintException(repr(e))
```

Line 293:
```
#if (checkDate > self.newestDay) or (checkDate > lastDate):
```

## Other Changes

**Change on line 102**

Original:
```
file = open(self.inFileName, 'rb')
```
Fixed:
```
file = open(self.inFileName, 'r')
```

Use PrintException in readFile:
```
except Exception as e:
    PrintException(repr(e))
```

Add Function to Print History Info:
```
def printHistory(rtch):
    print('---------------------------------------')
    print(rtch.getHistoryTable())
    print('---------------------------------------\n')
    print(rtch.getHistoryHtml())
    print('---------------------------------------')
```
```
    printHistory(rtch)
```

