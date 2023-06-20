## Commented Code Removals

Lines 7-8:
```
#LOCAL_IP_STR=$( echo $LOCAL_IP | sed -n "s/^.*inet[[:space:]]\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*$/\1 \2 \3 \4/p" | xargs printf "%03d" )
#echo "padded and merged LOCAL IP String: $LOCAL_IP_STR"
```
