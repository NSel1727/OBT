 #!/bin/bash
 
if [ -f WatchDogResults.txt ] 
then
    rm WatchDogResults.txt
fi

watchDogStartCmd="python3 WatchDog.py -p 'git-*' -t 40 -r 100 -v"
$watchDogStartCmd >> WatchDogResults.txt

if [ -f WatchDogResults.txt ] 
then
    echo "WatchDog Results File Created"
fi

