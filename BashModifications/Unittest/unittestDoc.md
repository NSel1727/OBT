## Removed Commented Code

Line 35:
```
#echo "param:'"$1"'
```

Line 182:
```
#result=$( sudo unbuffer ${UNITTEST_BIN} ${UNITTEST_EXEC_PARAMS} $unittest 2>&1 )
```

Line 249:
```
#results=($( cat ${UNITTEST_RESULT_FILE} | egrep -i '\<ok|run:|excep|[[:digit:]]+\)\stest|\-\s'  | egrep -v 'Digisign IException thrown' ))
```

Line 253:
```
#cat ${UNITTEST_RESULT_FILE} | egrep -i '^ok|Run:' | while read res
```

Line 260:
```
#WriteLog "Result: ${RESULT}" "$UNITTEST_LOG_FILE"
```

Line 267:
```
#FAILED=$(( $FAILED + $UNIT_FAILED))
```

Line 287:
```
#WriteLog "TestResult:unit:total:${UNIT_TOTAL} passed:${UNIT_PASSED} failed:${UNIT_FAILED} errors:${UNIT_ERRORS} timeout:${UNIT_TIMEOUT}"  "$UNITTEST_LOG_FILE"
```

Line 366:
```
#gdb --batch --quiet -ex "set interactive-mode off" -ex "thread apply all bt" -ex "quit" ${UNITTEST_BIN} $core >> "$core.trace" 2>&1
```

## Other Changes

Make Constant:

```
SED_INPUT="s/^[[:space:]]*Run:[[:space:]]*\([0-9]*\)[[:space:]]*Failures:[[:space:]]*\([0-9]*\)[[:space:]]*Errors:[[:space:]]*\([0-9]*\)[[:space:]]*Timeout:[[:space:]]*\([0-9]*\)[[:space:]]*$/"
```

```
SED_INPUT="s/^[[:space:]]*Run:[[:space:]]*\([0-9]*\)[[:space:]]*Failures:[[:space:]]*\([0-9]*\)[[:space:]]*Errors:[[:space:]]*\([0-9]*\)[[:space:]]*$/"
```
```
UNIT_TOTAL=$( echo "${RESULT}" | sed -n $SED_INPUT"\1/p")
```
