#!/bin/bash

clear

echo "Create modules.txt..."
if [ ! -f modules.txt ]
then
    make clean
    rm -rf plugins
    LOGFILE=dependency-build-$(date "+%Y-%m-%d_%H-%M-%S").log
    echo "Logfile: ${LOGFILE}"

    make -k -j > ${LOGFILE} 2>&1 
    #cat ${LOGFILE} | egrep 'Built target|fetching and building|librdkafka([:space:]|$)' | sed "s/\[[ 0-9].*\%\] //g" | sed "s/Built target //g" | sed -e "s/fetching and building //g" -e "s/librdkafka/kafka/g" -e "s/^libmemcached-[\.0-9].*/libmemcached/g" | sort > modules.txt
    cat ${LOGFILE} | egrep 'Built target|fetching and building|librdkafka([[:space:]]|$)' | sed "s/\[[ 0-9].*\%\] //g" | sed "s/Built target //g" | sed -e "s/fetching and building //g" -e "s/librdkafka/kafka/g" -e "s/^libmemcached-[\.0-9].*/libmemcached/g" > modules.txt
fi

mv modules.txt modules.unsorted
cat modules.unsorted | sort > modules.txt

echo "Finished."
#exit

echo "Start dependency tests..."

modules=$(cat modules.txt | sed "s/Built target //g")

for module in $modules
do
    rm -fr generated
    echo "Module:${module}"
    cmd="make clean"
    msg=${cmd}
    ${cmd}
    rm -rf plugins

    #cmd="make -j 16 ${module}"
    cmd="make -d -j ${module}"

    msg=${msg}", ${cmd}"
    ${cmd} > checkDep.log 2>&1
    if [ $? -ne 0 ]
    then
        msg=${msg}"    Build failed"
        cp checkDep.log ${module}-checkDep.log
    else
        msg=${msg}"    Build pass"
    fi
    echo "${msg}"
done

echo "Finished."
