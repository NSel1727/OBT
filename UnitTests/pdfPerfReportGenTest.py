#!/usr/bin/env python3

import pdfPerfReportGen as perf
import os

fileName = "spreadsheet_demo2.pdf"

if os.path.isfile(fileName):
    os.remove(fileName)

pdfReport = perf.PdfPerfReportGen()
pdfReport.demo()

if not os.path.isfile(fileName):
    print("Error: spreadsheet not created")
else:
    print("Success: spreadsheet created")
