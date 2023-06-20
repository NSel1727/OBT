## Commented Code Removals

Line 3:
```
#find ~/OBT-*/ -name 'OBT-*' -type f -exec bash -c "echo '{}' ;tail -n 10 '{}'" \; | egrep '^'"${TODAY}"'|OBT'
```

Line 16:
```
#echo "$b"
```

