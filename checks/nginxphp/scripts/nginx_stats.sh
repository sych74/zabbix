#!/bin/bash
 
### DESCRIPTION
# $1 - host name (not use)
# $2 - measured metrics
# $3 - http reference to statistics page
 
### OPTIONS VERIFICATION
if [[ -z "$1" || -z "$2" ]]; then
	exit 1
 fi
 
if [[ "$3" = "none" ]]; then
	exit 1
 fi
 
### PARAMETERS
METRIC="$2"  # measured metrics
STATURL="$3" # nginx statistics address
 
CURL=/usr/bin/curl
 
CACHETTL="55" # Time of cache existing in seconds (less than update interval)
CACHE="/tmp/nginxstat-`echo $STATURL | md5sum | cut -d" " -f1`.cache"
 
### RUN
## Cache check:
# cache creating time (0 if cache file is not existing or has 0 size)
if [ -s "$CACHE" ]; then
	TIMECACHE=`stat -c"%Z" "$CACHE"`
 else
	TIMECACHE=0
 fi
# текущее время
TIMENOW=`date '+%s'`
# If cache is not actual than update it (exit if error)
if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
	$CURL -s "$STATURL" > $CACHE || exit 1
 fi
 
 
## Get metrics:
if [ "$METRIC" = "active" ]; then
	cat $CACHE | grep "Active connections" | cut -d':' -f2
 fi
if [ "$METRIC" = "accepts" ]; then
	cat $CACHE | sed -n '3p' | cut -d" " -f2
 fi
if [ "$METRIC" = "handled" ]; then
	cat $CACHE | sed -n '3p' | cut -d" " -f3
 fi
if [ "$METRIC" = "requests" ]; then
	cat $CACHE | sed -n '3p' | cut -d" " -f4
 fi
if [ "$METRIC" = "reading" ]; then
	cat $CACHE | grep "Reading" | cut -d':' -f2 | cut -d' ' -f2
 fi
if [ "$METRIC" = "writing" ]; then
	cat $CACHE | grep "Writing" | cut -d':' -f3 | cut -d' ' -f2
 fi
if [ "$METRIC" = "waiting" ]; then
	cat $CACHE | grep "Waiting" | cut -d':' -f4 | cut -d' ' -f2
 fi
 
exit 0
