## 2to3 Changes

**Note**: Changes such as uneeded extra parenthesis are not included

**Change on line 9**

Original:
```
import urllib2
```
Updated:
```
import urllib.request, urllib.error, urllib.parse
```

**Change on line 24**

Original:
```
self.config = ConfigParser.ConfigParser()
```
Updated:
```
self.config = configparser.ConfigParser()
```

**Change on line 40**

Original:
```
except ConfigParser.NoSectionError:
```
Updated:
```
except configparser.NoSectionError:
```

**Change on line 271**

Original:
```
print(format % tuple([Msg]+map(str,Args)) )
```
Updated:
```
print((format % tuple([Msg]+list(map(str,Args))) ))
```

**Change on line 364**

Original:
```
response_stream = urllib2.urlopen(wuQuery)
```
Updated:
```
response_stream = urllib.request.urlopen(wuQuery)
```

**Change on line 432, 473, 544**

Original:
```
response_stream = urllib2.urlopen(url)
```
Updated:
```
response_stream = urllib.request.urlopen(url)
```

**Change on line 448, 452, 636, 640**

Original:
```
except urllib2.HTTPError as ex:
```
Updated:
```
except urllib.error.HTTPError as ex:
```

## Removed Commented Code

Lines 294-295:
```
#if len(nameItems) > 3:
    #version = nameItems[3]
```

Line 323:
```
#break
```

Line 383:
```
#versionInfo += value + '('+debugValue['Value']+')'
```

