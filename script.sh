#!/bin/bash

#----------------------- Start Utils Fuctions---------------------------------------

function validateParamName {
    
    if [ -z "$1" ]
    then
        echo "The name field cannot be left empty"
        return 1
    elif [[ "$1" =~ ^[0-9] ]]
    then
        echo "Name should not begin with a number"
        return 1
    elif [[ "$1" = *" "* ]]
    then
        echo "Name Shouldn't Have Spaces"
        return 1
    elif [[ "$1" =~ [^a-zA-Z0-9_] ]]
    then
        echo "Name Shouldn't Have Special Characters"
        return 1
    fi

}



#----------------------- End Utils Fuctions-----------------------------------------

#----------------------- Start Fuctions Area-----------------------------------------

function createDb {
    
    typeset status DbName
    
    while true
    do
        read -p "Enter the Db name: " DbName
        validateParamName $DbName
        if [ $? -eq 0 ] 
        then
            break
        fi
    done
    
    if [ -d "databases/$DbName" ]
    then
        echo "A Database with same name already exist"
    else
        mkdir databases/$DbName
        echo "Database Created Successfully"
    fi
    
}

function listDbs {
    if [ -n "$(ls databases/)" ]
    then
        echo "Databases List : "
        ls databases/
    else
        echo "No Databases Found"
    fi
}

function connectDb {
    
    typeset DbName

    if [ -z "$(ls databases/ )" ]
    then
        echo "No Databases Found To connect"
        return
    fi
    
    while true
    do
        read -p "Db name: " DbName
        validateParamName $DbName
        if [ $? -eq 0 ] 
        then
            break
        fi
    done
    
    if [ ! -d "databases/$DbName" ]
    then
        echo "Database Not Found"
    else
        cd databases/$DbName
        echo "You are connected to $DbName database"
        showTablesMenu
    fi
    
}

function DropDb {
    
    typeset DbName

    if [ -z "$(ls databases/ )" ]
    then
        echo "No Databases Found To Remove"
        return
    fi
    
    while true
    do
        read -p "Db name: " DbName
        validateParamName $DbName
        if [ $? -eq 0 ] 
        then
            break
        fi
    done
    
    if [ ! -d "databases/$DbName" ]
    then
        echo "Database Not Found"
    else
        rm -r databases/$DbName
        echo "$DbName deleted successfully"
    fi
    
}

function createTable {
    
    typeset tableName cols num=0 nameRecord="" dataTypeRecord=""
    
    while true
    do
        read -p "Enter Table Name: " tableName
        validateParamName $tableName
        if [ $? -eq 0 ] 
        then
            break
        fi
    done
    
    if [ -d "/$tableName" ]
    then
        echo "Table Already Exists"
        return
    fi
    
    mkdir $tableName
    cd $tableName
    
    touch "${tableName}.txt"
    touch "${tableName}-meta.txt"

    while true
    do 
        read -p "Enter Number Of Columns: " cols
        if [[ ! $cols =~ ^[0-9]+$ ]]
        then
            echo "Cols number must be a number"
            exit
        elif [ $cols -eq 0 ]
        then 
            echo "Cols number should be greater than 0"
            exit
        fi
        break
    done
    
    typeset colName colType
    while [ $num -lt $cols ]
    do
        read -p "Col Name: " colName

        echo "Choose an option (1-2): "
        select colType in "string" "integer" 
        do 
            case $colType in
                "integer" | "string" ) break ;;
                *) echo "Invalid Choice" ;;
            esac
        done

        
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
    if [ -z "$(ls)" ] 
    then
        echo "No Tables To Show, Database Is Empty."
    else 
        ls
    fi
}

function dropTable {
    typeset tableName

    if [ -z "$(ls)" ] 
    then
        echo "No Tables To Drop, Database Is Empty."
    else 
        read -p "Enter Table name: " tableName
        if [ ! -d "/$tableName"] 
        then
            echo "Table Doesn't Exist"
            return
        else
            rm -r "/$tableName"
        fi
    fi
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
    select choice2 in "Create Table" "List Tables" "Drop Tables" "Insert" "Select" "Delete" "Update" "Quit"
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
            "Quit")
                cd ../..
                break
            ;;
            *) echo "$choice2 is not valid"
            ;;
        esac
    done
}

#----------------------- End Fuctions Area-----------------------------------------

#----------------------- Start Script Main body------------------------------------
PS3="Select Option: "

select choice in "Create DB" "List All DBs" "Connect to DB" "Drop DB" "Exit"
do
    case $choice in
        "Create DB") createDb
        ;;
        "List All DBs") listDbs
        ;;
        "Connect to DB") connectDb
        ;;
        "Drop DB") DropDb 
        ;;
        "Exit") exit
        ;;
        *) echo "$choice is not valid"
        ;;
    esac
done
#----------------------- End Script Main body------------------------------------

