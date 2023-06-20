 #!/bin/bash
 
if [ -f utils.sh ]
then   
    . ./utils.sh
else
    . ./../utils.sh
fi

compare()
{
    Expected=$1
    Actual=$2
    
    if [ "$Expected" != "$Actual" ]
    then
        echo "Error:"
        echo "Expected:" $Expected
        echo "Actual:" $Actual
        
        Failed=1
   fi
}

# Unit Tests for SecToTimeStr

echo "SecToTimeStr Tests"
echo 

Failed=0

Actual=$(SecToTimeStr 5)
Expected="5 sec (00:00:05)"

compare "$Expected" "$Actual"

Actual=$(SecToTimeStr 100)
Expected="100 sec (00:01:40)"

compare "$Expected" "$Actual"

Actual=$(SecToTimeStr 12500)
Expected="12500 sec (03:28:20)"

compare "$Expected" "$Actual"

if [ $Failed -eq 0 ]
then
    echo "All Test Passed!"
fi

# Unit Test for ElementIn 

echo
echo "ElementIn Tests"
echo 

myArr=("1" "8" "3")

ElementIn "8" ${myArr[@]}

if [ $? == "1" ]
then
    echo "Test 1 Passed"
else
    echo "Test 1 Failed"
fi

myArr=("7" "23" "10")

ElementIn "15" ${myArr[@]}

if [ $? == "0" ]
then
    echo "Test 2 Passed"
else
    echo "Test 2 Failed"
fi

