#!/usr/bin/python3
import os
myOutput = os.popen("make dotest").read()
stdOutput = os.popen("lexer test.cl").read()

beginIndex = myOutput.index("#name")
myOutput = myOutput[beginIndex:]

while True:
    myEnd = myOutput.index("\n")
    stdEnd = stdOutput.index("\n")
    if myOutput[0 : myEnd] != stdOutput[0 : stdEnd]:
        print("my flex ", myOutput[0 : myEnd])
        print("std flex", stdOutput[0 : stdEnd])
        print("")
    myOutput = myOutput[myEnd + 1 :]
    stdOutput = stdOutput[stdEnd + 1 :]
    
