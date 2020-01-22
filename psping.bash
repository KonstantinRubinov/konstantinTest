#!/bin/bash

#function to check processes by user arguments
function checkprocess() {
    startping=0
    #if to check with user name
    if [[ "$user" != "" ]]; then
        echo "Pinging '$processname' for user '$user'"
    #if to check by process name
    else
        echo "Pinging '$processname' for any user"
    fi
    #do by pings limit (if exists)
    while [[ "$startping" != "$pings" ]]; do
        let "startping += 1"
        #if there is username and processname
        if [[ "$user" != "" ]] && [[ "$processname" != "" ]] ; then
            procnum=$(pgrep -u $user $processname | wc -l)
            echo "$processname: $procnum instance(s)..."
        #if there is only username
        elif [[ "$user" != "" ]] ; then
            procnum=$(pgrep -u "$(user)" | wc -l)
            echo "$processname: $procnum instance(s)..."
        #if there is only processname
        elif [[ "$processname"  != "" ]] ; then
            procnum=$(pgrep -x $processname  | wc -l)
            echo "$processname: $procnum instance(s)..."
        fi
        #wait by timeout
        sleep $timeout
    done
}

#function to set arguments from user
function psping() {
    #number of pings... -1 means until ctrl+c
    pings=-1
    #timeout 1 by default
    timeout=1
    #username
    user=""
    #processname
    processname=""
    #number of processes
    procnum=0
    myArray=("$@")
    N=0
    for arg in "${myArray[@]}"; do
        #if there is number of pings
        if [ "$arg" == "-c" ]
        then
            pings=${myArray[$N+1]}
        #if there is timeout
        elif [ "$arg" == "-t" ]
        then
            timeout=${myArray[$N+1]}
        #if there is username
        elif [ "$arg" == "-u" ]
        then
            user=${myArray[$N+1]}
        fi
        let N+=1
    done
    #set process name
    processname=${myArray[-1]}
    checkprocess
}