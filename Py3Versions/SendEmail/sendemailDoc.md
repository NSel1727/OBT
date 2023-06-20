## 2to3 Changes

**Change on line 5**

Original:
```
import ConfigParser
```
Update:
```
import configparser
```

**Change on line 21**

Original:
```
self.config = ConfigParser.ConfigParser()
```
Update:
```
self.config = configparser.ConfigParser()
```

## Remove Commented Code

Line 33:
```
#os.chdir( logDir )
```

## Post 2to3 Changes

Remove Unused Imports:
```
import glob
```
```
from email.Utils import COMMASPACE, formatdate
```

Remove Unused Variables:
```
logDir = config.get( 'Environment', 'PerformanceResultDir' ) 
```

Add Error Handling:
```
import sys
import inspect
import traceback
```
```
print(("Unexpected error:" + str(sys.exc_info()[0]) + " (line: "
 + str(inspect.stack()[0][2]) + ")" ))
traceback.print_stack()
```

