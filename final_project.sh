#!/usr/bin/bash
#Include the bash shebang

clear   #Clear the CLI before starting (like flushing)

#Like in C, these are constant definitions, they cannot be changed within the script except in the same line
readonly SUDO="root"
readonly ACCESS_USER="User" #Access Mode: User
readonly ACCESS_ADMIN="Admin" #Access Mode: Admin
readonly COUNTER_START=1
readonly COUNTER_END_USER=3
readonly COUNTER_END_ADMIN=6

readonly STATE_INPUT=0
readonly STATE_SYSTEM=1
readonly STATE_SYNC=2
readonly STATE_NETWORK=3
readonly STATE_DEVICES=4
readonly STATE_REB_SHUT=5
readonly STATE_LOG=6

readonly CPU_USER_SPACE=1
readonly CPU_KERNEL_SPACE=3
readonly CPU_IDLE=4

readonly PERCENTAGE=100

declare access_mode=$ACCESS_USER  #Default access mode is user (will be overwritten)
declare selection_counter=$COUNTER_START #To show the numbers of selection precisely, we'll keep up by incrementing the counter
declare current_state=$STATE_INPUT  #State machine design, starting with state "Input"

function read_input()
{
    local input_value
    read -r -p "$1" input_value
    echo "$input_value"
}

function read_state_input()
{
    declare counter_end
    if [ "$access_mode" == "$ACCESS_ADMIN" ];
    then
        counter_end=$COUNTER_END_ADMIN
    elif [ "$access_mode" == "$ACCESS_USER" ];
    then
        counter_end=$COUNTER_END_USER
    fi
    local input_value
    input_value=$(read_input "Your choice: ")
    while [[ ! "$input_value" =~ ^[0-9]+$  || "$input_value" -gt "$counter_end" ]]; do
        input_value=$(read_input "ERROR! Please re-enter: ")
    done

    echo "$input_value"
}

function print_cli()
{
    declare counter_end
    if [ "$access_mode" == "$ACCESS_ADMIN" ];
    then
        counter_end=$COUNTER_END_ADMIN
    elif [ "$access_mode" == "$ACCESS_USER" ];
    then
        counter_end=$COUNTER_END_USER
    fi

    echo "Please select one of the options below:"
    for counter in $(seq "$COUNTER_START" "$counter_end"); do
        case "$counter" in
            "$STATE_SYSTEM")
                printf "%s] Display System's Info\n" "$STATE_SYSTEM"
            ;;
            "$STATE_SYNC")
                printf "%s] Directory Sync over Network\n" "$STATE_SYNC"
            ;;
            "$STATE_NETWORK")
                printf "%s] Display Network's Info\n" "$STATE_NETWORK"
            ;;
            "$STATE_DEVICES")
                printf "%s] Display & Control Devices' Info\n" "$STATE_DEVICES"
            ;;
            "$STATE_REB_SHUT")
                printf "%s] Reboot/Shutdown\n" "$STATE_REB_SHUT"
            ;;
            "$STATE_LOG")
                printf "%s] Log Kernel Info\n" "$STATE_LOG"
            ;;
        esac
    done
}

function display_sysinfo()
{
    local value_catcher=0
    local cpu_usage=0

    for line in $(cat /proc/stat); do

        echo "$line" >> "$HOME/Desktop/file.txt"

        if [[ $value_catcher == "$CPU_USER_SPACE" || $value_catcher == "$CPU_KERNEL_SPACE" || $value_catcher == "$CPU_IDLE" ]]
        then
            echo "$line"
            case "$value_catcher" in
                "$CPU_USER_SPACE")
                    cpu_usage="$line"
                ;;
                "$CPU_KERNEL_SPACE")
                    ((cpu_usage+="$line"))
                    echo "$cpu_usage"
                ;;
                "$CPU_IDLE")
                    cpu_usage=$(echo "$cpu_usage * $PERCENTAGE / $line" | bc -l)
                    echo "$cpu_usage"
                ;;
            esac
            
            ((value_catcher++))
        else
            if [ $value_catcher -le "$CPU_IDLE" ]
            then
                ((value_catcher++))
                continue
            else
                break
            fi
        fi

    done

    current_state=$STATE_LOG

}

function feature_selector()
{
    case "$1" in
        "$STATE_INPUT")
            print_cli
            current_state=$(read_state_input)
            
            #echo "$current_state"

        ;;
        "$STATE_SYSTEM")
            display_sysinfo
        ;;
        "$STATE_SYNC")
            
        ;;
        "$STATE_NETWORK")
            
        ;;
        "$STATE_DEVICES")
            
        ;;
        "$STATE_REB_SHUT")
            
        ;;
        "$STATE_LOG")
            
        ;;
    esac
    
}

if [ "$USER" != "$SUDO" ];   #If the shell variable USER is NOT root (i.e. sudo)
then
    access_mode=$ACCESS_USER      #Make it user
else
    access_mode=$ACCESS_ADMIN     #Else, make it admin
fi

printf "=======================================\nWelcome to the Informatics Application!\n=======================================\n\nYour current access mode is: %s Mode!\n" "$access_mode"
while true; do
    feature_selector "$current_state"
done

