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

function createTable {
    read -p "Enter Table Name: " tableName
    mkdir $tableName
    cd $tableName

    touch "${tableName}.txt"
    touch "${tableName}-meta.txt"

    read -p "Enter Number Of Columns: " cols

    num=0
    nameRecord=""
    dataTypeRecord=""
    while [ $num -lt $cols ]
    do 
        read -p "Col Name: " colName
        read -p "Col Datatype (string or num): " colType

        if [ $num -eq $((cols-1)) ]
        then
            nameRecord="${nameRecord}${colName}"
            dataTypeRecord="${dataTypeRecord}${colType}"
        else
            nameRecord="${nameRecord}${colName}:"
            dataTypeRecord="${dataTypeRecord}${colType}:"
        fi

        let num=$num+1
    done

    echo $dataTypeRecord >> "${tableName}-meta.txt"
    echo $nameRecord >> "${tableName}-meta.txt"

    cd ../

}

function listTables {
    ls 
}

function dropTable {
    read -p "Enter Table name: " rTable
    rm -r $rTable
}

function insertTable {
    read -p "Enter Table Name: " tableName
    typeset colNum
    colNum=$( head -1 ${tableName}/${tableName}-meta.txt | awk -F':' '{print NF}')
    
    typeset num=0
    typeset insertVal=""
    while [ $num -lt $colNum ]
    do
        typeset colName=$(tail -1 ${tableName}/${tableName}-meta.txt | cut -d ':' -f $((num+1)))
        typeset colDatatype=$(head -1 ${tableName}/${tableName}-meta.txt | cut -d ':' -f $((num+1)))
        read -p "Enter value of ${colName} in ${colDatatype}: " colValue
        
        if [ $num -eq $((colNum-1)) ]
        then
            insertVal="${insertVal}${colValue}"
        else
            insertVal="${insertVal}${colValue}:"
        fi

        let num=$num+1
    done

    echo ${insertVal} >> "${tableName}/${tableName}.txt"

}

function deleteRecord {
    typeset id tableName
    read -p "Enter Table Name: " tableName
    read -p "Enter Id to delete: " id
    sed -i "/^${id}/d" "${tableName}/${tableName}.txt"
}

function selectTable {
    typeset tableName colsNum

    read -p "Enter Table Name: " tableName

    tail -1 ${tableName}/${tableName}-meta.txt | sed 's/:/ /g' 
    sed 's/:/ /g'  ${tableName}/${tableName}.txt && echo

}

function updateTable {
    typeset tableName pk colName oldValue newValue colnum

    read -p "Enter Table Name: " tableName

    read -p "Enter Pk: " pk

    read -p "Enter col Name: " colName

    colnum=$(awk -F: '{ for (i=1; i<=NF; i++) { if ($i == "'"$colName"'") { print i; exit } } }' ${tableName}/${tableName}-meta.txt)
    oldValue=$( grep "^${pk}" ${tableName}/${tableName}.txt | cut -d ':' -f $colnum )

    read -p "Enter New Value: " newValue

    sed -i "/^$pkValue/s/$oldValue/$newValue/" ${tableName}/${tableName}.txt
}

function showTablesMenu {
    select choice2 in "Create Table" "List Tables" "Drop Tables" "Insert" "Select" "Delete" "Update" Quit
        do  
            case $choice2 in
            "Create Table") echo "Create Table"
            createTable
            ;;
            "List Tables") echo "List Tables"
            listTables
            ;;
            "Drop Tables") echo "Drop Tables"
            dropTable
            ;;
            "Insert") echo "Insert"
            insertTable
            ;;
            "Select") echo "Select"
            selectTable
            ;;
            "Delete") echo "Delete"
            deleteRecord
            ;;
            "Update") echo "Update"
            updateTable
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

