#!/bin/bash

SUBMISSION="submissions"
LOG="submission_attempt_log.txt"
LOGIN_ATTEMPT="login_attempt_log.txt"
USERNAME=Admin
PASSWORD=Adminpassword

mkdir -p $SUBMISSION

declare -A FAIL_COUNT
declare -A LAST_ATTEMPT

while true
do
    echo ""
    echo "  Assignment Submission system  "
    echo "1. Submit an assignment"
    echo "2. Check if a file already submitted"
    echo "3. Check all submissions"
    echo "4. Simulate login"
    echo "5. Exit"
    read -p "Choose an option 1-5: " choice

    case $choice in

    1)
        read -p "Choose a file to submit: " file

        if [ ! -f "$file" ]; then
            echo "That file does not exist"
            continue
        fi

        ext="${file##*.}"
        if [[ "$ext" != "pdf" && "$ext" != "docx" ]]; then
            echo "Invalid file type, please submit .pdf or .docx"
            continue
        fi

        size=$(stat -c%s "$file")
        if [ $size -gt 5242880 ]; then
            echo "File is too large and exceeds 5 MB, please submit a file less than 5 MB"
            continue
        fi

        filename=$(basename "$file")

        if [ -f "$SUBMISSION/$filename" ]; then
            if cmp -s "$file" "$SUBMISSION/$filename"; then
                echo "That is a duplicate submission, submit a different file."
                continue
            fi
        fi

        cp "$file" "$SUBMISSION/"
        echo "$(date) - Submitted: $filename" >> $LOG
        echo "File has been submitted successfully"
        ;;

    2)
        read -p "Enter a filename to check: " checkfile

        if [ -f "$SUBMISSION/$checkfile" ]; then
            echo "File has already been submitted"
        else
            echo "No submission has been found, please submit a file."
        fi
        ;;

    3)
        echo "Submitted files:"
        ls $SUBMISSION
        ;;

    4)
        read -p "Username: " user
        read -p "Password: " pass

        current_time=$(date +%s)

        if [ "${FAIL_COUNT[$user]}" -ge 3 ]; then
            echo "Account locked"
            continue
        fi

        if [ ! -z "${LAST_ATTEMPT[$user]}" ]; then
            diff=$((current_time - LAST_ATTEMPT[$user]))
            if [ $diff -lt 60 ]; then
                echo "Suspicious: repeated login attempts"
            fi
        fi

        LAST_ATTEMPT[$user]=$current_time

	if [ "$user" == "$USERNAME" ] && [ "$pass" == "$PASSWORD" ]; then
    	echo "Login is successful"
    	FAIL_COUNT[$user]=0
    	echo "$(date) - $user login success" >> $LOGIN_ATTEMPT
	else
   	 echo "Login failed"
    	FAIL_COUNT[$user]=$((FAIL_COUNT[$user]+1))
    	echo "$(date) - $user login failed" >> $LOGIN_ATTEMPT
	fi
	;;

   	5)
        read -p "Are you sure you want to exit? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            echo "Bye"
            break
	else
		echo "staying in system"
        fi
        ;;

    *)
        echo "Not an option"
        ;;
    esac
done
