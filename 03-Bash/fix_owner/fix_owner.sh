#!/bin/bash

file="/etc/passwd"
IFS=$'\n'
for user_line in $(cat $file)
do
    declare -i user_id
    user_id=$(echo $user_line | cut -d ':' -f3)
    if [ $user_id -lt 1000 ]; then
        continue
    fi
    user_name=$(echo $user_line | cut -d ':' -f1)
    user_home=$(echo $user_line | cut -d ':' -f6)
    user_group=$(echo $user_line | cut -d ':' -f4)

    # echo "$user_name=$user_id:$user_group-$user_home"

    find $user_home -maxdepth 1 > homeFileList

    declare -i once
    once=0
    tmpFile="homeFileList"
    for homeFile in $(cat $tmpFile)
    do
        if [ $once -eq 0 ]; then 
            once=1
            continue
        fi

        fileOwner=$(stat -c '%U' $homeFile)
        if [ "$fileOwner" != "$user_name" ]; then
            echo "the $homeFile does not belong to you"
            echo "want to appropriate?"
            echo -n "y/n :"
            read decision
            if [ $decision == "y" ]; then
                echo "try to modify owner"
                sudo chown $user_name $homeFile
                if [ $(stat -c '%U' $homeFile) = "$user_name" ];then
                    echo "successfully assigned"
                else
                    cho "failed to assign"
                fi
            fi
        fi
    done

done