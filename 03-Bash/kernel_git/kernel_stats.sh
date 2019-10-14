#!/bin/bash

# $1 - linux kernel sources path

if [ $# -lt 1 ]
then
    echo "set kernel path as parametr"
    exit 1
fi

# count *.c files
declare -i C_COUNT
declare -i CPP_COUNT
declare -i PY_COUNT
C_COUNT=0
CPP_COUNT=0
PY_COUNT=0

for c_file in $(find "$1" -name "*.c" -type f)
do 
    C_COUNT=$(( $C_COUNT + 1 ))
done
for cpp_file in $(find "$1" -name "*.cpp" -type f)
do 
    CPP_COUNT=$(( $CPP_COUNT + 1 ))
done
for c_file in $(find "$1" -name "*.py" -type f)
do 
    PY_COUNT=$(( $PY_COUNT + 1 ))
done

echo "*.c :$C_COUNT"
echo "*.cpp :$CPP_COUNT"
echo "*.c :$PY_COUNT"

declare -i REVERT_COUNT
REVERT_COUNT=0

cd "$1"
git checkout master 2&>1 /dev/null
for revert_commit in $(git log --oneline | grep revert)
do
    REVERT_COUNT=$(( $REVERT_COUNT + 1 ))
done

echo "revert commit count: $REVERT_COUNT"

git ls-files '*.py' | while read py_file
do
    echo "in file $py_file this autors :"
    echo "$(git blame --line-porcelain $py_file | grep '^author ' | sed 's/^author //' | sort -f | uniq -c | sort -nr)"
done
