#!/bin/bash

#----------------------- Star Fuctions Area-----------------------------------------

function createDb {
    mkdir databases/$1
}

function listDbs {
    ls databases/
}

function connectDb {
    cd databases/$1
}

function DropDb {
    rm -r databases/$1
}

function showTablesMenu {
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
}

#----------------------- End Fuctions Area-----------------------------------------

#----------------------- Start Script Main body------------------------------------
PS3="Select Option: "

select choice in "Create DB" "List DB" "Connect to DB" "Drop DB" Exit
do
    case $choice in
        "Create DB") echo "Create DB"
        read -p "Enter the Db name: " DbName
        createDb $DbName
        ;;
        "List DB") echo "List DB"
        listDbs
        ;;
        "Connect to DB") echo "Connect to DB"
        read -p "Db name: " DbName
        connectDb $DbName
        showTablesMenu
        ;;
        "Drop DB") echo "Drop DB"
        read -p "Db name: " DbName
        DropDb $DbName
        ;;
        Exit) exit 0
        ;;
        *) echo "$choice is not valid"
        ;;
    esac
done
#----------------------- End Script Main body------------------------------------

