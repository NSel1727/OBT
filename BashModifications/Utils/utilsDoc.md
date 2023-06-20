## Removed Commented Code

Line 24:
```
#freeMem=$( free | grep -E "^(Mem)" | awk '{ print $7 }' )
```

Line 31:
```
#freeMemGB=$(  free -g | grep -E "^(Mem)" | awk '{print $7"GB from "$2"GB" }' )
```

Line 134:
```
#echo "End of OBT"
```

Line 192, 196:
```
#exit -1
```

