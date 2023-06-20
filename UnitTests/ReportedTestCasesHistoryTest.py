#!/usr/bin/env python3

import ReportedTestCasesHistory as RTCH
import datetime as dt
import os

os.environ['testMode'] = '1'

path = '.'
fileName = "RTCHInput.csv"

myFile = open(fileName, "w")

myFile.write(str(dt.date.today()) + ",Test1,A,Bad,True\n" + str(dt.date.today() - dt.timedelta(1)) + ",Test2,B,Good,True")

myFile.close()
rtch = RTCH.ReportedTestCasesHistory(fileName,  5,  True)

print("DATEISINRANGE TESTS\n")

dates = [dt.date.today(), dt.date.today() - dt.timedelta(5), dt.date.today() - dt.timedelta(8)]

expecteds = [True, False, False]

i = 0
failed = 0

for date in dates:
    date = str(date)
    if rtch.dateIsInRange(date) != expecteds[i]:
        print("Error with date", date)
        print("Expected Result:", expecteds[i])
        print("Actual Result:", not(expecteds[i]))
        failed = 1          
        
    i += 1
    
if failed == 0:
    print("All tests passed!\n")
    
rtch.readFile()

print("\nREADFILE TEST\n")

testNames = rtch.testNames

failed = 0

if testNames[0] != "Test1#A":
    print("Error:")
    print("Expected test name: Test1#A")
    print("Actual test name:", testNames[0])
    failed = 1
    
if testNames[1] != "Test2#B":
    print("Error:")
    print("Expected test name: Test2#B")
    print("Actual test name:", testNames[1])
    failed = 1 

if failed == 0:
    print("All tests passed!\n")
    
print("\nSTATS TEST\n")

rtch.buildHistoryTable()

stats = rtch.stats

expecteds = [2, 1, 0, 0, 0, 1, 1, 0]
i = 0
failed = 0

for key in stats:
    val = stats[key]
    
    if val != expecteds[i]:
        print("Error:")
        print("Field:", key)
        print("Expected:", expecteds[i])
        print("Actual:", val)
        failed = 1
        
    i += 1
    
if failed == 0:
    print("All tests passed!\n")
    
os.environ['testMode'] = '0'
