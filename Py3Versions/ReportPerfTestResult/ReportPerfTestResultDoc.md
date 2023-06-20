## 2to3 Changes

**Note** Changes such as unnecessary extra parenthesis are ignored 

**Change on line 5**

Original:
```
import ConfigParser
```
Updated:
```
import configparser
```

**Change on line 69**

Original:
```
self.config = ConfigParser.ConfigParser()
```
Updated:
```
self.config = configparser.ConfigParser()
```

**Change on line 87**

Original:
```
print 'Attempt to acess missing attribute of {0}'.format(name)
```

Updated:
```
print('Attempt to acess missing attribute of {0}'.format(name))
```

**Change on line 385, 582**

Original:
```
print "processing file:"+file
```
Updated:
```
print("processing file:"+file)
```

**Change on line 443**

Original:
```
print "Process "+file
```
Updated:
```
print("Process "+file)
```

**Change on line 676**

Original:
```
print "Report sent. End."
```
Updated:
```
print("Report sent. End.")
```

## Post 2to3 Changes

Don't Read in Binary:

Original:
```
fp = open(summaryGraph[0], 'rb')                   
```
Updated:
```
fp = open(summaryGraph[0], 'r')      
```

Original:
```
fp = open(image, 'rb')                 
```
Updated:
```
fp = open(image, 'r') 
```

## Removed Commented Code

Line 41:
```
#from email.Utils import COMMASPACE, formatdate
```

Line 89:
```
#raise AttributeError(name)
```

Line 301:
```
#self.msg = MIMEMultipart('alternative')  # Doesn't work with some email client
```

Line 329:
```
#summary = PerformanceSummary(self.config) 
```

Line 471:
```
#img.add_header('Content-Disposition', 'attachment', filename='SummaryGraph.png')
```

Line 520:
```
#img.add_header('Content-Disposition', 'attachment', filename='graph{}.png'.format(index))
```

Lines 545-451:
```
# End HTML
#msgHTML += "<br><hr>\n"
#msgHTML += "Links to results in old OBT system (Wiki pages)<br>\n"
#msgHTML += "<ul>\n"
#msgHTML += "<li><a href=\"http://10.176.152.123/wiki/index.php/HPCC_Nightly_Builds\" target=\"_blank\">Nightly Builds Web Page</a></li>\n"
#msgHTML += "<li><a href=\"http://10.176.32.10/builds/\" target=\"_blank\">HPCC Builds Archive</a></li>\n"
#msgHTML += "</ul>\n"
```


