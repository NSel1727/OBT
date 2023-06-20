## Removed Commented Code

Line 348:
```
#clusterTotalTimes = self.numOfRuns[cluster] * [0]
```

Lines 353-354:
```
#if not testname.startswith('80ab_scalesort-scale(16)'):
    #continue
```

Line 488:
```
#percentage = (data[1] - data[0]) / data[0] * 100
```

Line 526:
```
#data1 = [32.53, 31.74,  32.45,  32.38,  31.75,  32.18,  31.71,  31.9]
```

Line 613:
```
#print("cluster:%s, test: %s" % (cluster,  test))
```
(This print is called by myPrint)

Line 652:
```
#ax.plot_date(dates2, self.results[cluster][test]['Values'][-dataPoints:], linestyle = '--', color=diagramColors['value'])
```

Line 724:
```
#ax.grid(True, which='both')
```

Line 753:
```
#plt.show()
```

Line 789:
```
#headerData.extend(self.defaultHeaderData)
```

Line 861:
```
#print("%3d/%3d: cluster:%s, test:%s, mean:%f sec, sigma:%f sec, fluctuation:%f, alpha:%f" % (testIndex, numberOfTests, cluster, test, self.results2[cluster][test]['avg'], self.results2[cluster][test]['sigma'], fluctuation, self.results2[cluster][test]['all']['alpha']))
```

Lines 864-873:
```
## Only for generate example diagram
#                    if test.startswith('01da'):
#                        self.enableTrend = False
#                        self.enableMean = False
#                        self.enableSigma = False
#                        self.disableMovingAverage1 = True
#                        self.disableMovingAverage2 = True
#                        if plt:
#                            self.manageTestCase(cluster,  test,  'Result of ')
#                        break
```

Lines 896-899:
```
#elif test.startswith('02cd') or test.startswith('02ea') or test.startswith('02eb') or \
                #test.startswith('04ae') or test.startswith('04cd') or test.startswith('04cf') or \
                #elif test.startswith('05bc') or test.startswith('06bc'):
                    #pass
```

Line 984:
```
#print("Unexpected error:" + str(sys.exc_info()[0]) + " (line: "
 + str(inspect.stack()[0][2]) + ")" )
```

Line 1033: 
```
#plt.show()
```

## Other Changes

Removed Unused Import:

```
from __future__ import absolute_import
```

Removed the need to divide these variables by 100 multiple times
```
# Convert from percentage to fraction
self.badThreshold /= 100.0
self.goodThreshold /= 100.0
```

Shorter max statement

Original:
```
if self.numOfRuns[cluster] < len(self.results2[cluster][testname]['Days']):
    self.numOfRuns[cluster] = len(self.results2[cluster][testname]['Days'])
```
Updated:
```
self.numOfRuns[cluster] = max(self.numOfRuns[cluster], len(self.results2[cluster][testname]['Days']))
```

Update Import:

Original
```
    from ReportedTestCasesHistory3 import ReportedTestCasesHistory
```

Updated:
```
    from ReportedTestCasesHistory import ReportedTestCasesHistory
```
