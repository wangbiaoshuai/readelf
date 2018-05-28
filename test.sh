#!/bin/sh

array=()
j=0
for i in {a..z}
do
    array[j]="$i"
    let j++
done

if [[ "x" =~ "${array[*]}" ]]
then
    echo "yes"
fi

echo "${array[*]}"
result=`echo ${array[*]} | grep z`
if [ "$result" != "" ]
then
    echo "Y"
fi

for var in ${array[@]}
do
    echo "$var"
done

exit 0
