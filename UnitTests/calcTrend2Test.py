#!/usr/bin/env python3

import numpy as np
import glob
import os

os.environ['testMode'] = '1'

from calcTrend2 import *

def getOptions():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-d", "--datapath", dest="dataPath",  default = './',  type="string", 
                      help="Data file path. Default is './'", metavar="DATA_PATH")
                      
    parser.add_option("-r", "--reportpath", dest="reportPath",  default = './',  type="string", 
                      help="Path to store formance report. Default is './'", metavar="TARGET_PATH")
                      
    parser.add_option("-t", "--threshold", dest="threshold", default=5.0, type="float", 
                      help="Trend threshold to determine significant increasing/decreasing trend. Default is 5.0%"
                      , metavar="THRESHOLD")

    parser.add_option("--pdfReport", dest="pdfReport", action="store_true", default = False, 
                      help="Enable PDF reports generation."
                      , metavar="PDF_REPORT")
                      
    parser.add_option("-v", "--verbose", dest="verbose", default=False, action="store_true", 
                      help="Show more info. Default is False"
                      , metavar="VERBOSE")
                      
    parser.add_option("--movingAverageWindow1", dest="movingAverageWindow1", default=7, type="int", 
                      help="Moving average 1 window size. Default is 7 days"
                      , metavar="MOVINGAVERAGEWINDOW1")

    parser.add_option("--disableMovingAverage1", dest="disableMovingAverage1", default=False, action="store_true", 
                      help="Disable to draw Moving average 1. Default is False"
                      , metavar="DISABLEMOVINGAVERAGE1")
                      
    parser.add_option("--movingAverageWindow2", dest="movingAverageWindow2", default=30, type="int", 
                      help="Moving average 2 window size. Default is 30 days"
                      , metavar="MOVINGAVERAGEWINDOW2")
                      
    parser.add_option("--disableMovingAverage2", dest="disableMovingAverage2", default=False, action="store_true", 
                      help="Disable to draw Moving average 2. Default is False"
                      , metavar="DISABLEMOVINGAVERAGE2")
                      
    parser.add_option("--enableSigma", dest="enableSigma", default=False, action="store_true", 
                      help="Enable to draw Sigma range. Default is False"
                      , metavar="ENABLESIGMA")
                    
    parser.add_option("--enableMin", dest="enableMin", default=False, action="store_true", 
                      help="Enable to draw Min values. Default is False"
                      , metavar="ENABLEMIN")
                      
    parser.add_option("--enableMax", dest="enableMax", default=False, action="store_true", 
                      help="Enable to draw Max values. Default is False"
                      , metavar="ENABLEMAX")

    parser.add_option("--enableTestPlotGeneration", dest="enableTestPlotGeneration", default=False, action="store_true", 
                      help="Enable to generate diagram for each test case. Default is False"
                      , metavar="ENABLETESTPLOTGENERATION")

    (options, args) = parser.parse_args()

    if options.dataPath == None:
        parser.print_help()
        return None
        
    return (options, args)
    
#
# Main
     
options = getOptions()

tr = TrendReport(options[0])

numSummaryFiles = len(glob.glob("perftest-*.summary"))
numCsvFiles = len(glob.glob("perftest-*.csv"))

tr.readData()
tr.processResults()

print("\n\nFILE CREATION TEST\n")

if len(glob.glob("perftest-*.summary")) - numSummaryFiles == 1: 
    print("Pass: Summary File Produced")
else:
    print("Error: Summary File Not Produced")

if len(glob.glob("perftest-*.csv")) - numCsvFiles == 1: 
    print("Pass: Csv File Produced")
else:
    print("Error: Csv File Not Produced")

print("\nCALCMOVINGAVERAGE TESTS\n")

inputs = [(2, [2, 3, 8]), (1, [1, 2, 3]), (4, [5, 8, 11, 7])]
expecteds = [[2, 2.5, 5.5], [1, 2, 3], [5, 6.5, 8, 7.75]]

i = 0
failed = 0

for input in inputs:
    averages = tr.calcMovingAverage(input[0], input[1])
    
    if averages != expecteds[i]:
        print("Error")
        print("Input:", input[0], input[1])
        print("Expected:", expecteds[i])
        print("Actual:", averages)
        failed = 1
    
    i += 1
    
if failed == 0:
    print("All tests passed!\n")

print("\nCALCTREND FUNCTION TEST\n")

inputs = [np.array([0.5, 2, 1]), np.array([10, 10, 10]), np.array([100, 50, 0.5])]
expecteds = ["increased", "unaltered", "decreased"] 
 
i = 0
failed = 0

for input in inputs:
    direction = tr.CalcTrend(input)['direction']
    
    if direction != expecteds[i]:
        print("Error")
        print("Input", input)
        print("Expected Direction", expecteds[i])
        print("Actual Direction", direction)
        failed = 1
    
    i += 1
        
if failed == 0:
    print("All tests passed!\n")
    
print("\nCREATEDATESERIES FUNCTION TEST\n")

inputs = [["2018.09.11", "2018.11.27", "2018.11.28"], ["2017.01.05", "2020.3.27", "2023.05.20"]]
expecteds = [[17785.0, 17862.0, 17863.0], [17171.0, 18348.0, 19497.0]]

i = 0
failed = 0

for input in inputs:
    series = tr.createDateSeries(input, 3)
    
    if series != expecteds[i]:
        print("Error")
        print("Input", input)
        print("Expected:", expecteds[i])
        print("Actual:", series)
        failed = 1
        
    i += 1
    
if failed == 0:
    print("All tests passed!\n")
    
print("\nSEPARATEANDWRAPTESTNAME FUNCTION TEST\n")
    
inputs = ["aggds3-keyedfilters(true)-multipart(true)-opremoteread(true)-usesequential(true)", "indexread_keyed-forceremotekeyedfetch(true)-forceremotekeyedlookup(true)-multipart(false)-uselocal(true)"]
expecteds = ["aggds3\n   keyedfilters(true), multipart(true), opremoteread(true), \n   usesequential(true), ",
"indexread_keyed\n   forceremotekeyedfetch(true), forceremotekeyedlookup(true), \n   multipart(false), uselocal(true), "]

i = 0
failed = 0

for input in inputs:
    name = tr.separateAndWrapTestName(input)
    
    if name != expecteds[i]:
        print("Error")
        print("Input", input)
        print(expecteds[i])
        print(name)
        failed = 1
        
    i += 1
    
if failed == 0:
    print("All tests passed!\n")
    
os.environ['testMode'] = '0'      

