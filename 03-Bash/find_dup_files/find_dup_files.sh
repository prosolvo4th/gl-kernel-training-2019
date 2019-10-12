#!/bin/bash +x

# set default dir
sourceDir=$(pwd)

# set new source dir if available
if [ $# -ne 0 ]; then
    if [ $1 = "-h" -o $1 = "--help" ]; then
        echo "$0 [-h | --help | DIRECTORY] "
        echo "$0 - srcipt check files in DIRECTORY with same md5 sum"
        echo "      -h | --help - print this help"
        exit 0
    else
        sourceDir=$1
    fi
fi

cd $sourceDir
# create list of files in dir
find . * -maxdepth 0 -type f > fileList

# check if file list created
if [ ! -e fileList ]; then
    echo cant create fileList
    exit 1
fi

#create file with checksum for each file
cat fileList | while read line
do
    tmp=$(md5sum "$line") 
    echo $tmp | cut -d ' ' -f1 > "$line".md5sum
done

# compare contents of *.md5sum files
cat fileList | while read md5File1
do
    declare -i sameFile
    sameFile=0
    cat fileList | while read md5File2
    do
        # ignore the same file
        if [ $sameFile -eq 0 ]; then
            if [ "$md5File1" != "$md5File2" ]; then
                # search the filename in fileList
                continue
            else
                # finded the same file in fileList
                sameFile=1
                continue
            fi
        fi
    
        if [ $(cat "$md5File1".md5sum) = $(cat "$md5File2".md5sum) ]; then
            tmp=$(wc -c $md5File1)
            file1Size=$(echo $tmp | cut -d ' ' -f1)
            tmp=$(wc -c $md5File2)
            file2Size=$(echo $tmp | cut -d ' ' -f1)
            echo "sum eq : $md5File1 - $file1Size | $md5File2 - $file2Size"
        fi
    done
done

# clean up
cat fileList | while read md5File
do
    rm "$md5File".md5sum
done
rm fileList
