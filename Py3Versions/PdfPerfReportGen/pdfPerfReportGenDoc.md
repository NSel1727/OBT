## 2to3 Changes

**Change on line 129**

Original:
```
lp.xValueAxis.valueSteps = range(dataPoints)
```
Update:
```
lp.xValueAxis.valueSteps = list(range(dataPoints))
```

## Post 2to3 Changes

Outdated Import:
```
from reportlab.lib.pagesizes import A4, landscape, cm
```
Explanation: cm belongs to units now
Updated:
```
from reportlab.lib.units import mm, cm
```

Created Constant for Style:
```defaultStyle = [
                # Header
                ('SPAN',  (0, 0),  (0, 1)),
                ('VALIGN',  (0, 0),  (0, 1),  'MIDDLE'), 
                ('SPAN',  (1, 0),  (3, 0)),
                ('ALIGN',  (1, 0),  (3, 0),  'CENTER'), 
                ('SPAN',  (4, 0),  (6, 0)),
                ('ALIGN',  (4, 0),  (6, 0),  'CENTER'),  
                ('SPAN',  (7, 0),  (9, 0)), 
                ('ALIGN',  (7, 0),  (9, 0),  'CENTER'),
                ('ALIGN',  (1, 1),  (9, 1),  'CENTER'),
                ('BOX',(0,0),(1,-1),1,colors.blue),
                ('BOX',(1,0),(3,-1),1,colors.blue),
                ('BOX',(4,0),(6,-1),1,colors.blue),
                ('BOX',(7,0),(9,-1),1,colors.blue), 
                # Body
                ('GRID',(0,0),(-1,-1),0.5,colors.grey),
                ('ALIGN',  (0, 2),  (0, -1),  'LEFT'),
                ('ALIGN',  (1, 2),  (1, -1),  'RIGHT'),
                ('ALIGN',  (3, 2),  (3, -1),  'RIGHT'),
                ('ALIGN',  (4, 2),  (4, -1),  'RIGHT'),
                ('ALIGN',  (6, 2),  (6, -1),  'RIGHT'),
                ('ALIGN',  (7, 2),  (7, -1),  'RIGHT'),
                ('ALIGN',  (9, 2),  (9, -1),  'RIGHT'),
               ]
```

Simplify Function:

Original:
```
def formatter(val):
    retVal = aDiagramData[1][val]
    return retVal
```
Updated:
```
def formatter(val):
    return aDiagramData[1][val]
```

               
## Removed Comments

Lines 53-61, 247-255:
```
  #('BOX',(1,3),(3,3),3 ,colors.red),
                #('BACKGROUND',(4,3),(6,3), colors.red),
                #('BACKGROUND',(7,6),(9,6), colors.limegreen)
                #('BOX',(0,0),(-1,-1), 1,colors.black),
                #('LINEABOVE',(1,2),(-2,2),1,colors.blue),
                #('LINEBEFORE',(2,1),(2,-2),1,colors.pink),
                #('BACKGROUND', (0, 0), (0, 1), colors.pink),
                #('BACKGROUND', (1, 1), (1, 2), colors.lavender),
                #('BACKGROUND', (2, 2), (2, 3), colors.orange),
```
                
Lines 105-108:
```
#data = [
                #((1,1), (2,2), (2.5,1), (3,3), (4,5)),
                #((1,2), (2,3), (2.5,2), (3.5,5), (4,6))
                #]
```
                
Line 121:
```
#lp.categoryAxis.categoryNames = aDiagramData[1]
```

Line 261:
```
#self.setTableHeader()
```

