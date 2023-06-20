## 2to3 Changes

**Change on line 2**

Original:
```
from __future__ import print_function
```
Update: This is removed due to not applying to Python 3

**Change on line 10**

Original:
```
import ConfigParser
```
Update:
```
import configparser
```

**Change on line 44**

Original:
```
self.config = ConfigParser.ConfigParser()
```
Update:
```
self.config = configparser.ConfigParser()
```

## Removed Commented Code

Line 5:
```
#import mimetypes
```

Line 22:
```
#from regressionLogProcessor import RegressionLogProcessor
```

Line 52:
```
#print(self._buildDate)
```

Line 358:
```
#print( line, end='' )
```

Lines 506-507:
```
#else:
    #self._globalExclusion = "(N/A)"
```
                    
Line 527:
```
#print ("logFileDirectory:" + self.logFileDirectory)
```

Line 574:
```
#p3 = re.compile('.*otal:([0-9]+)\s*passed:([0-9]+)\s*failed:([0-9]+)\s*errors:([0-9]+)\s*timeout:([0-9]+).*$')
```

Line 608:
```
#print(m2.groups())
```

Line 758:
```
#self.msg['Subject'] = "HPCC Nightly Build " + self.config.buildDate + " Result: " + self.status
```

Line 785:
```
#self.msgHTML += "<tr><td>Global exclusion:</td><td>" + self.results[self.buildTaskIndex].globalExclusion + "</td></tr>\n"
```

Line 822:
```
#self.msgHTML += "<table cellspacing=\"0\" cellpadding=\"5\" border=\"1\" bordercolor=\"#828282\">\n"
```

Line 1010:
```
#self.msg['Subject'] = subjectStatus + subjectError + ". HPCC " + self.config.reportObtSystemEnv + " OBT " + self.config.buildType +" result on branch " + self.results[self.buildTaskIndex].gitBranchName + ' (' + self.config.buildDate.replace(' ', '_').replace(':','-') + ")"
```

Lines 1062-1063:
```
#self.msgHTML += "<li><a href=\"http://10.176.152.123/wiki/index.php/HPCC_Nightly_Builds\" target=\"_blank\">Nightly Builds Web Page</a></li>\n"
#self.msgHTML += "<li><a href=\"http://10.176.152.123/data2/nightly_builds/HPCC/5.0/\" target=\"_blank\">Nightly Builds Archive</a></li>\n"
```
   
Line 1068:
```
#self.msg.attach( MIMEText( self.msgText, 'plain' )) 
```
         
Line 1154:
```
#options.dateString='2018-06-08'
```

Lines 1157-1160:
```
#config = BuildNotificationConfig("2018-02-18")
#config = BuildNotificationConfig("2018-03-23")
#config = BuildNotificationConfig("2018-06-24")
#config = BuildNotificationConfig("2018-09-02")
```
    
## Post 2to3 Changes

Added class and function for coloring:
```
class SpanMaker():
    @classmethod
    def makeSpan(cls, color, result):
        return "<span style=\"color:" + color + "\">" + result + "</span><br>\n"
```

