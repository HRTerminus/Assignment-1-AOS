#!/bin/bash

JOBQUEUE="job_queue.txt"
COMPLETED="completed_jobs.txt"
LOG="scheduler_log.txt"

touch "$JOBQUEUE" "$COMPLETED" "$LOG" 2>/dev/null

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

view_pending() {
    if [ ! -s "$JOBQUEUE" ]; then
        echo "There are currently 0 pending jobs."
        return
    fi
    echo "Pending Jobs:"
    echo "StudentID | Job Name | Est Time | Priority"
    cat "$JOBQUEUE"
}

submit_job() {
    read -p "Please enter a Student ID: " studentID
    read -p "Please enter a Job Name: " jobname
    read -p "Please enter an Estimated Execution Time (seconds): " estimatedtime
    read -p "Please enter a Priority (1-10): " priority
    if ! [[ "$priority" =~ ^[1-9]$|^10$ ]]; then
        echo "That is an invalid priority, enter a valid priority to continue."
        return
    fi
    echo "$studentID|$jobname|$estimatedtime|$priority" >> "$JOBQUEUE"
    log "Job submitted: $studentID $jobname Priority:$priority Est:$estimatedtime"
    echo "Job submitted."
}

priority_sched() {
    echo "Processing"
    sort -t'|' -k4 -nr "$JOBQUEUE" > temp.txt
    mv temp.txt "$JOBQUEUE"
    while [ -s "$JOBQUEUE" ]; do
        job=$(head -1 "$JOBQUEUE")
        IFS='|' read -r studentID jobname estimatedtime priority <<< "$jobname"
        echo "Executing: $jobname (Priority $priority)"
        sleep "$estimatedtime"
        echo "$jobname" >> "$COMPLETED"
        sed -i '1d' "$JOBQUEUE"
        log "Job selected has been executed: $studentID $jobname"
        echo "Completed: $jobname"
    done
	}
round_robin() {
    echo "Processing with Round Robin for 5 Seconds"
    awk -F'|' '{print $1"|"$2"|"$3"|"$4"|"$3}' "$JOBQUEUE" > temp_rr.txt
	"$JOBQUEUE"
    while [ -s temp_rr.txt ]; do
        job=$(head -1 temp_rr.txt)
        IFS='|' read -r studentID jobname estimatedtime priority remaining <<< "$jobname"
        echo "Running $jobname (SID $studentID) for 5 seconds"
        if [ "$remaining" -le 5 ]; then
            sleep "$remaining"
            echo "$studentID|$jobname|$estimatedtime|$priority" >> "$COMPLETED"
            log "Job executed using Round Robin: $studentID $jobname"
            echo "Completed: $jobname"
            sed -i '1d' temp_rr.txt
        else
            sleep 5
            new_rem=$((remaining - 5))
            sed -i '1d' temp_rr.txt
            echo "$studentID|$jobname|$estimatedtime|$priority|$new_rem" >> temp_rr.txt
        fi
    done
    rm -f temp_rr.txt
}

process_queue() {
    if [ ! -s "$JOBQUEUE" ]; then
        echo "There are no jobs to be processed."
        return
    fi
    echo "1. Round Robin"
    echo "2. Priority Scheduling"
    read -p "Option: " schedule
    case $schedule in
        1) round_robin ;;
        2) priority_sched ;;
        *) echo "Invalid" ;;
    esac
}

view_completed() {
    if [ ! -s "$COMPLETED" ]; then
        echo "There are no completed jobs."
        return
    fi
    echo "Completed Jobs:"
    cat "$COMPLETED"
}

exit_system() {
    read -p "Exit? (Y/N): " choice
    [[ "$choice" == [Yy] ]] && echo "Bye" && exit 
}

while true; do
    echo " High Performance Computing Job Scheduler"
    echo "1. View pending jobs"
    echo "2. Submit a job request"
    echo "3. Process job queue"
    echo "4. View completed jobs"
    echo "5. Exit"
    read -p "Option: " option
    case $option in
        1) view_pending ;;
        2) submit_job ;;
        3) process_queue ;;
        4) view_completed ;;
        5) exit_system ;;
        *) echo "This is an invalid option, please select a valid option." ;;
    esac
    echo ""
done
