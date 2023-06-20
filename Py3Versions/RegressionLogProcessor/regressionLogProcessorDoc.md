## 2to3 Changes

**Change on line 58**

Original:
```
return (map(str.strip, itemsTemp))
```
Update:
```
return (list(map(str.strip, itemsTemp)))
```

**Change on line 382**

Original:
```
print "End of process."
```
Update:
```
print("End of process.")
```

**Change on line 481**

Original:
```
print header
```
Update:
```
print(header)
```

**Change on line 490**

Original:
```
print "\t" + subHeader
```
Update:
```
print("\t" + subHeader)
```

**Change on line 510**

Original:
```
print "\t\t" + item
```
Update:
```
print("\t\t" + item)
```

**Change on line 534**

Original:
```
print "Start ProcessResults()...
```
```
Update:
```
print("Start ProcessResults()...")
```

**Change on line 566**

Original:
```
print "End ProcessResults().
```
```
Update:
```
print("End ProcessResults().")
```

**Change on line 677**

Original:
```
print "Start..."
```
Update:
```
print("Start...")
```

**Change on line 736**

Original:
```
print "Logfile: +fullPath
```
Update:
```
print("Logfile:"+fullPath)
```

**Change on line 749**

Original:
```
print "End."  
```
Update:
```
print("End.") 
```

## Post 2to3 Changes

**Fix on line 80**

Original:
```
file = open(filename, 'rb')
```
Update:
```
file = open(filename, 'r')
```

**Fix on line 549**

Original:
```
inFile = open(self.knownProblemFileName, "rb")
```
Update:
```
inFile = open(self.knownProblemFileName, "r")
```

## Removed Commented Code

Lines 14-16:
```
#idIndex = {}
#testCases=[]
#maxTestNameLen=0
```
                
Lines 18-19:
```
#htmlReport=[]
#suite=''
```

Lines 189-210:
```
# Dead code
#                    elif 'version' in items[3]:
#                        print (index)
#                        # This is a 'Test:' line of a versioned test
#                        testName = items[2].strip()+'('+items[4].strip()
#                        testNameLen = len(testName)
#                        if testNameLen > self.maxTestNameLen:
#                            self.maxTestNameLen = testNameLen
#                        items[1] = items[1].strip()
#                        self.testCases[index-1][items[1]]=testName
#                        id = hash(testName)
#                        self.testCases[index-1]['id']=id
#                        self.idIndex[id] = index-1
#                    elif len(items) >= 5 and 'Fail' in items[1]:
#                        print (index)
#                        # This can be the 'Fail' line with many items
#                        results = items[1].lstrip(' ').replace('No WUID','No_WUID').replace('(', '').replace('sec)', '').split(' ')
#                        self.testCases[index-1]['Result']=results[0]
#                        self.testCases[index-1]['Wuid']=results[1]
#                        self.testCases[index-1]['Elapstime']=results[2]
#                        if 'Fail' in results[0]:
#                            pass
```

Line 275:
```
#elif line.startswith('Output of'):
```

Line 312:
```
#elif line.startswith('--- '):
```

Line 652:
```
#self.knownProblems = {}
```

Line 657:
```
#self.knownProblems[items[0]+'-'+items[4]]={'Test': items[0],  'Date':items[1],  'Problem':items[2],  'Code':items[3],  'Target':items[4]}
```

Lines 685-689:
```
#filenames = [
                    #path+'setup_hthor.14-12-03-00-14-38.log', 
                    #path+'setup_roxie.14-12-03-00-17-10.log', 
                    #path+'setup_thor.14-12-03-00-15-28.log'
                #]
```

Line 696:
```
#files = [path + 'thor.16-11-11-01-13-28.log']
```

Line 702:
```
#files = ['/home/ati/HPCCSystems-regression/log/thor.15-02-17-12-35-48.log']
```

Line 706:
```
#path = '/home/ati/shared/Chris\' results/candidate-5.2.0rc3singlenode/'
```

Line 711:
```
#path+'hthor.17-11-22-01-40-39.log',
```

Line 713:
```
#path+'roxie.17-11-22-01-52-49.log'
```

## Other Changes

Original:
```
if 'version' in error[0]:
    testName = items[2].strip() +'('+items[4].strip()
else:
    testName = items[2].strip()
```
Updated:
```
testName = items[2].strip()
if 'version' in error[0]:
    testName += '(' + items[4].strip()
```

Make Constant:
```
prev = index - 1
```
