#!/bin/bash
LOG="system_monitoring_log.txt"
ARCHIVE="ArchiveLogs"

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

while true; do
	echo ""
	echo "        -Core System Metrics and tools-           "
	echo "1. CPU and Memory Usage"
	echo "2. TOp 10 Most Consuming Processes"
	echo "3. Terminate a Process"
	echo "4. Disk and Log files"
	echo "5. Exit application"
	read -p "Choose 1-5: " choice

case $choice in
	1)
	echo "System Usage"
	echo ""
	echo "CPU Information and usage:"
        top -bn1 | grep "^%Cpu"

	echo "Memory Information and usage:"
        free -m
        log "Displayed System Usage"
	echo ""
        ;;

        2)
        ps aux --sort=-user,pid,%cpu,%mem,comm | head -11 | cut -c -240
        log "Displayed top 10 Most Consuming Processes"
        ;;

        3)
        read -p "Please choose which PID you want to terminate: " pidNO
        if [ "$pidNO" -le 10 ]; then 
        echo "Cannot terminate a core system process"
        log "Attempted to terminate a core system PID "

        else
        read -p "Confirm (Y/N): " x
        [[ "$x" == [Yy] ]] && kill "$pid" && log "Terminated selected  $pid"
        fi
        ;;

        4)
        read -p "Directory: " dir
        if [ -d "$dir" ]; then
        du -sh "$dir"
        mkdir -p "$ARCHIVE"
        for f in $(find "$dir" -name "*.log" -size +50M); do
	gzip -c "$f" > "$ARCHIVE/$(basename "$f")_$(date +%s).gz"
        log "Archived $f"
        done
        [ $(du -sm "$ARCHIVE" | cut -f1) -gt 1024 ] && echo "WARNING: ArchiveLogs >1GB" && log "Archive too big"

        else
        echo "Directory does not exist"
        fi
        ;;

        5)
        read -p "Exit? (Y/N): " x
        [[ "$x" == [Yy] ]] && echo "Bye" && exit 
	;;
esac
done
