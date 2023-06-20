TODAY="$(date +%Y.%m.%d)"

#find ~/OBT-*/ -name 'OBT-*' -type f -exec bash -c "echo '{}' ;tail -n 10 '{}'" \; | egrep '^'"${TODAY}"'|OBT'

IFS=$'\n'

fs=$( find ~/OBT-*/ -name 'OBT-*' -type f -print )
for f in ${fs[@]}
do
    echo "$f"
    lines=$( echo " $(tail -n 10 $f | egrep '^'${TODAY} )" )
    for line in ${lines[@]}
    do
        echo "line:$line"
        b=$( echo "$line" | cut  -f 1,3 )
        #echo "$b"
    done

done

unset IFS

