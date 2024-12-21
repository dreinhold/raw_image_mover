#!/bin/bash
# Dylan Reinhold 12/18/2024
# Simple script to traverse 1 level into /data folder
# move any raw (CR3) files to a subfolder named raw

date_formated()
{
	date "+%Y-%m-%d %H:%M:%S"
}

logline()
{
	mesg=$@
	echo $(date_formated) $mesg
}

logline Started

BASE=$1
if [ -z $BASE ]
then
	BASE=/data
fi
logline Base is $BASE

move_files()
{
    logline "Looking for any raw files to move"
    find "$BASE" -maxdepth 1 -type d | while read -r dir; do
        # Check if there are any .CR3 files in the directory
        if [ "$(ls "$dir"/*.CR3 2> /dev/null)" ]; then
            # Create the 'raw' subfolder if it doesn't exist
            mkdir -p "$dir/raw"

            # Move all .CR3 files into the 'raw' subfolder
	    logline "move $dir/*.CR3 $dir/raw/"
            mv "$dir"/*.CR3 "$dir/raw"
        fi
    done
}

move_files
curr_ts=$(date +%s)
event_seen=0
while [ 1 ] 
do
	echo "/data" > /tmp/watch_list
	ls -d /data/* >> /tmp/watch_list

	#event=$(inotifywait -r --format '%e' /data)
	event=$(inotifywait --fromfile /tmp/watch_list -t 60)
	# When an event fires, just track that it happened in flag
	# Set inotfy to timeout after 60 seconds only if a pending event flag
	# was set move the files, this will allow the move to wait until there is 
	# one minute without file changes to start
	if [ -z "$event" ]
	then
	    if [ $event_seen == 1 ]
	    then
		logline "Moving files after timeout"
	        move_files
	        event_seen=0
            fi
	else
		# This is a file event flag for next timeout
		event_seen=1
	        logline "Event $event"
	fi
done

logline Ended
