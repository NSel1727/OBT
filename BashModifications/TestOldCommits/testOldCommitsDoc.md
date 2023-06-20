## Removed Commented Code

Line 56:
```
#sha=$( git log --after="$sourceDate 00:00" --before="$testDate 00:00$" --merges | grep -A3 'commit' | head -n 1 | cut -d' ' -f2 )
```

Line 63:
```
#sha=$( git log --after="$sourceDate 00:00" --before="$testDate 00:00$" --merges | grep -A3 'commit' | head -n 1 | cut -d' ' -f2 )
```

Lines 101-104:
```
# back 4 weeks
    #firsTestDate=$( date -I -d "$lastTestDate - 27 days")
    # back one week
    #firsTestDate=$( date -I -d "$lastTestDate - 6 days")
```
    
Line 111:
```
#sudo service ntpd stop
```

Lines 117-118:
```
# backward
#until [[ "$testDate" < "$firsTestDate" ]]
```

Lines 135-138:
```
# magic with date set it back to original test date (one minute after midnight)
                #sudo date -s "$testDate 00:01:00"

                #date
```
                
Lines 143-146:
```
#  Restore the correct date with NTPD 
                #sudo ntpdate $TIME_SERVER
                #sudo ntpd -gq
                #date
```
                
Line 163:
```
#sudo service ntpd start
```

## Other Changes

Remove Unused Variables:
```
TIME_SERVER=$( grep ^server /etc/ntp.conf | head -n 1 | cut -d' ' -f2 )
```
```
CWD=$( pwd ) 
```

Consistent Multi-Word Variable Snake Case:

sourcePath -> SOURCE_PATH
testDate -> TEST_DATE
sourceDate -> SOURCE_DATE
firsTestDate -> FIRST_TEST_DATE
lastTestDate -> LAST_TEST_DATE
testSha -> TEST_SHA
dayCount -> DAY_COUNT
daySkip -> DAY_SKIP
targetFile -> TARGET_FILE
