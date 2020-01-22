#!/bin/bash

#function to work with files - decompress or ignore
function checkfile() {
    #decompresse by bzip2 if the type is right
    if [ $(file -b "${1}" | head -n1 | cut -d " " -f1) == "bzip2" ]; then
        bzip2 -k -f -d $1
        let "Decompressed += 1"
        if [[ "$veb" > 0 ]]; then
            echo "Unpacking $1"
        fi
    #decompresse by gzip if the type is right
    elif [ $(file -b "${1}" | head -n1 | cut -d " " -f1) == "gzip" ]; then
        gunzip -k -f $1
        let "Decompressed += 1"
        if [[ "$veb" > 0 ]]; then
            echo "Unpacking $1"
        fi
    #decompresse by Zip if the type is right
    elif [ $(file -b "${1}" | head -n1 | cut -d " " -f1) == "Zip" ]; then
        unzip -o -q $1 -d $(dirname "${1}")
        let "Decompressed += 1"
        if [[ "$veb" > 0 ]]; then
            echo "Unpacking $1"
        fi
    else
        #ignore file becouse its not compressed or not in the decompressors list
        if [[ "$veb" > 0 ]]; then
            echo "Ignoring $1"
        fi
    fi
}

#function to check if to send file or to move to folder
function dirwork {
    local a file
    for a; do
        for file in "$a"; do
            #if it is folder
            if [[ -d $file ]]; then
                if [[ "$rec" > 0 ]]; then
                    echo "$file is a directory"
                    dirwork "$a"/*
                fi
            #if it is file
            else
                checkfile "${file}"
            fi
        done
    done
}

#function to set arguments from user
function unpack() {
#if there is recursive command
rec=0
#if there is vebrose command
veb=0
#number of decompressed files
Decompressed=0
#where to decompress files
decto=""
#array of urguments
myArray=("$@")
    for arg in "${myArray[@]}"; do
        #if if to print the data
        if [[ "$arg" == "-v" ]]; then
            let "veb += 1"
        #if to work recursive
        elif [[ "$arg" == "-r" ]]; then
            let "rec += 1"
        else
            decto="${arg}"
            dirwork "${arg}"
        fi
    done
    echo "Decompressed $Decompressed archive(s)"
}