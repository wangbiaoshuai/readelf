#!/bin/sh

elf_file_1=$1
elf_file_2=$2
#func=$3
func_1=()
func_2=()
tmp_file="/tmp/elf_analysis.tmp"
func_asse_1=()
func_asse_2=()
func_asse=()

system_method[0]="_init"
system_method[1]="_start"
system_method[2]="__libc_csu_fini"
system_method[3]="__libc_csu_init"
system_method[4]="data_start"
system_method[5]="_fini"


if [ ! -e "$elf_file_1" ] || [ ! -e "$elf_file_2" ]
then
    echo "$elf_file_1 or $elf_file_2 is not exit."
    exit 1
fi

function clean_nop()
{
    tmp_asse=()
    local k=0
    local i=0
    while [ $i -lt ${#func_asse[*]} ]
    do
        var=${func_asse[$i]}
        var1=${var%nop*}
        if [ "$var1" != "$var" ]
        then
            let i++
            continue
        fi

        tmp_asse[k]=${func_asse[$i]}
        let k++
        let i++
    done

    func_asse=()
    local i=0
    while [ $i -lt ${#tmp_asse[*]} ]
    do
        func_asse[i]=${tmp_asse[i]}
        let i++
    done
    return 0
}

function get_func_asse()
{
    local elf_file=$1
    local func=$2
    local start=`nm -n $elf_file | \egrep "\s[T|t]\s.*$func" | awk '{print $1}'`
    local end=`nm -n $elf_file | \egrep -A1 "\s[T|t]\s.*$func" | awk '{getline; print $1}'`
    local class_name=${func%%:*}
    local func_name=$func
    if [ "$class_name" != "$func_name" ]
    then
        func_name=${func##*:}
        start=`nm -n $elf_file | \egrep "$class_name.*$func_name" | awk '{print $1}'`
        end=`nm -n $elf_file | \egrep -A1 "$class_name.*$func_name" | awk '{getline; print $1}'`
    fi

    if [ "$start" = "" ] || [ "$end" = "" ]
    then
        #调试#########################################################
#        echo -e "$func is not a method in $elf_file.\n"
        #调试结束####################################################
        return 1
    fi

    #调试##################################################
#    echo "start-address: 0x$start, end-address: 0x$end"
    #调试结束##############################################
    objdump -d $elf_file --start-address="0x$start" --stop-address="0x$end" > $tmp_file
    if [ "$?" != "0" ]
    then
        echo "$elf_file: objdump error."
        exit 1
    fi
    tmp=`\grep -n "$start" $tmp_file`
    num=${tmp%%:*}

    awk -F\t "NR>$num" $tmp_file > tmp

    local i=0
    while read LINE
    do
        func_asse[$i]=${LINE#*:}
        let i++
    done < tmp
    rm -rf tmp

    clean_nop

    #用于调试
    echo "$func_name in $elf_file:"
    local i=0
    while [ $i -lt ${#func_asse[*]} ]
    do
        echo "${func_asse[i]}"
        let i++
    done
    echo
    return 0
}

function compare_func_asse()
{
    echo -n -e "\e[32mresult: "
    len1=${#func_asse_1[*]}
    len2=${#func_asse_2[*]}

    if [ $len1 -eq 0 ] && [ $len2 -eq 0 ]
    then
        echo -e "$func is not exit.\e[0m"
        return 3
    fi

    if [ $len1 -eq 0 ] && [ $len2 -ne 0 ]
    then
        echo -e "$func is new.\e[0m"
        return 1
    fi

    if [ $len1 -ne 0 ] && [ $len2 -eq 0 ]
    then
        echo -e "$func is deleted.\e[0m"
        return 2
    fi

    if [ $len1 -ne $len2 ]
    then
        echo -e "$func is changed.\e[0m"
        return 4
    fi
    
    local i=0
    while [ $i -lt ${#func_asse_1[*]} ]
    do
        var1=${func_asse_1[i]}
        var2=${func_asse_2[i]}
        if [ "$var1" != "$var2" ]
        then
            echo -e "$func is changed.\e[0m"
            return 4
        fi
        let i++
    done
    echo -e "$func is same.\e[0m"
    return 0
}

function get_method_status()
{
    local func=$3
    get_func_asse $elf_file_1 $func
    local i=0
    while [ $i -lt ${#func_asse[*]} ]
    do
        func_asse_1[i]=${func_asse[i]}
        let i++
    done
    func_asse=()

    get_func_asse $elf_file_2 $func
    local i=0
    while [ $i -lt ${#func_asse[*]} ]
    do
        func_asse_2[i]=${func_asse[i]}
        let i++
    done

    compare_func_asse
    if [ "$?" = "0" ]
    then
        func_asse_1=()
        func_asse_2=()
        func_asse=()
        i=0
        return 0
    else
        func_asse_1=()
        func_asse_2=()
        func_asse=()
        i=0
        return 1
    fi
}

function get_functions()
{
    elf_1=$1
    elf_2=$2
    nm -n "$elf_1" | c++filt | \egrep "\s[T|W]\s" | awk '{print $3}' > tmp

    local i=0
    while read LINE
    do
        tmp_func=${LINE%%(*}
        local j=0
        local flag=0
        while [ $j -lt ${#system_method[*]} ]
        do
            tmp_func_2=${system_method[j]}
            if [ "$tmp_func" = "$tmp_func_2" ]
            then
                flag=1
                break
            fi
            let j++
        done
        if [ $flag -eq 0 ]
        then
            func_1[i]=$tmp_func
            let i++
        fi
    done < tmp

    nm -n "$elf_2" | c++filt | \egrep "\s[T|W]\s" | awk '{print $3}' > tmp
    local i=0
    while read LINE
    do
        tmp_func=${LINE%%(*}
        local j=0
        local flag=0
        while [ $j -lt ${#system_method[*]} ]
        do
            tmp_func_2=${system_method[j]}
            if [ "$tmp_func" = "$tmp_func_2" ]
            then
                flag=1
                break
            fi
            let j++
        done
        if [ $flag -eq 0 ]
        then
            func_2[i]=$tmp_func
            let i++
        fi
    done < tmp
    rm -rf tmp
}

function main()
{
    functions=()
    get_functions $elf_file_1 $elf_file_2

    #用于调试######################################
#    echo "$elf_file_1:"
#    local i=0
#    while [ $i -lt ${#func_1[*]} ]
#    do
#        echo "${func_1[i]}"
#        let i++
#    done
#    echo
#
#    echo "$elf_file_2:"
#    local i=0
#    while [ $i -lt ${#func_2[*]} ]
#    do
#        echo "${func_2[i]}"
#        let i++
#    done
#    echo
    #调试结束#######################################

    local k=0
    local i=0
    while [ $i -lt ${#func_1[*]} ]
    do
        get_method_status $elf_file_1 $elf_file_2 ${func_1[i]}
        let i++
    done

    local i=0
    while [ $i -lt ${#func_2[*]} ]
    do
        local j=0
        local flag=0
        while [ $j -lt ${#func_1[*]} ]
        do
            var1=${func_2[i]}
            var2=${func_1[j]}
            if [ "$var1" = "$var2" ]
            then
                flag=1
                break
            fi
            let j++
        done
        if [ $flag -eq 0 ]
        then
            get_method_status $elf_file_1 $elf_file_2 ${func_2[i]}
        fi
        let i++
    done
    return 0
}

main
#get_method_status $elf_file_1 $elf_file_2 $3

exit 0
