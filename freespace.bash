#!/bin/bash

#function rename file
function rename_file() {
    mv "${filename}" fc-"${filename}"
    touch -c fc-"${filename}"
    let "renamed += 1"
}

#function compress file
function compress_file() {
    zip -j -rm ${mydir}/fc-`echo "${filename}" | cut -d'.' -f1`.zip $1
    let "compressed += 1"
}

#function compress file
function remove_file() {
    rm $1
    let "removed += 1"
}

#function to work with files - compress or ignore
function checkfile() {
    filename="${1##*/}"
    mydir=$(dirname "${1}")
    #echo $((($(date +%s) - $(date +%s -r "$1")) / 60)) minutes files
    #echo ${time} minutes setted
    if [[ ! $(file -b "${1}" | head -n1 | cut -d " " -f1) =~ ^(bzip2|gzip|Zip)$ ]]
    then
        compress_file "${1}"
    else
        if [[ ${filename:0:3} == "fc-" ]] && [[ $((($(date +%s) - $(date +%s -r "$1")) / 60)) > "${time}" ]]
        then
            remove_file "${1}"
        elif [[ ${filename:0:3} != "fc-" ]]; then
            rename_file "${1}"
        else
            echo "${filename} ignoring"
        fi
    fi
}

#function to check if to send file or to move to folder
function dirwork {
    if [[ "$recursive" > 0 ]]; then
        echo "execuet find"
        for myf in $(find . -type f); do
             checkfile "${myf}"
        done
    fi
}

#function to set arguments from user
function freespace() {
N=0
#if there is recursive command
recursive=0
#if there is time command
time=48
#number of compressed files
compressed=0
#number of renamed files
renamed=0
#number of removed files
removed=0
#array of arguments
myArray=("$@")
    #echo ${myArray[@]}
    for arg in "${myArray[@]}"; do
        #if if to set time
        if [ "$arg" == "-t" ]
        then
            time=${myArray[$N+1]}
        #if to work recursive
        elif [[ "$arg" == "-r" ]]
        then
            let "recursive += 1"
        elif [[ -f $arg ]] && [[ "$recursive" = 0 ]]
        then
            echo "checkfile ${arg}"
            checkfile "${arg}"
        elif [[ -d $arg ]] && [[ "$recursive" = 0 ]]
        then
            for file in ${arg}/*; do
                #if it is file
                if [[ -f $file ]]; then
                   echo "${file}"
                   checkfile "${file}"
                fi
            done
        fi
        let N+=1
        done
        dirwork
        echo "Compressed $compressed archive(s)"
        echo "Renamed $renamed archive(s)"
        echo "Removed $removed archive(s)"
}

#freespace -t 1 -r *
#freespace UNIXHomeworkReference.pdf
#freespace bash