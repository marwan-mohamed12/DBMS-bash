#!/bin/bash

PS3="Select Option: "

select choice in "Create DB" "List DB" "Connect to DB" "Drop DB" Exit
do
    case $choice in
        "Create DB") echo "Create DB"
        ;;
        "List DB") echo "List DB"
        ;;
        "Connect to DB") echo "Connect to DB"
        select choice2 in "Create Table" "List Tables" "Drop Tables" "Insert" "Select" "Delete" "Update" Quit
        do  
            case $choice2 in
            "Create Table") echo "Create Table"
            ;;
            "List Tables") echo "List Tables"
            ;;
            "Drop Tables") echo "Drop Tables"
            ;;
            "Insert") echo "Insert"
            ;;
            "Select") echo "Select"
            ;;
            "Delete") echo "Delete"
            ;;
            "Update") echo "Update"
            ;;
            Quit) break
            ;;
            *) echo "$choice2 is not valid"
            ;;
            esac
        done

        ;;
        "Drop DB") echo "Drop DB"
        ;;
        Exit) exit 0
        ;;
        *) echo "$choice is not valid"
        ;;
    esac
done

