## Commented Code Removals

Line 14:
```
#cat ${LOGFILE} | egrep 'Built target|fetching and building|librdkafka([:space:]|$)' | sed "s/\[[ 0-9].*\%\] //g" | sed "s/Built target //g" | sed -e "s/fetching and building //g" -e "s/librdkafka/kafka/g" -e "s/^libmemcached-[\.0-9].*/libmemcached/g" | sort > modules.txt
```

Line 22:
```
#exit
```

Line 37:
```
#cmd="make -j 16 ${module}"
```

