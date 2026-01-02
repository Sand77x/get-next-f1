#!/usr/bin/env bash

# echoes next race info to STDOUT
# format: location session_name timestamp
# EX. Melbourne fp1 12345677
# Note: timestamp is in unix time (seconds since epoch)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_SCRIPT="$SCRIPT_DIR/cache.py"
CACHE="$HOME/.cache/f1/season.tsv"

now=$(date +%s)  
current_year=$(date +%Y)

if [ -f "$CACHE" ]; then
    cached_year=$(head -n1 "$CACHE")
else
    cached_year=0
fi

if [ "$current_year" -ne "$cached_year" ]; then
    "$CACHE_SCRIPT"
fi

sessions=("fp1" "fp2" "fp3" "sq" "sprint" "quali" "race")

while IFS=$'\t' read -r loc spr s1 s2 s3 s4 s5 s6 s7; do
    # Map s1..s7 to session timestamps
    timestamps=("$s1" "$s2" "$s3" "$s4" "$s5" "$s6" "$s7")

    for i in "${!sessions[@]}"; do
        session_name="${sessions[i]}"
        ts="${timestamps[i]}"

        if [ "$now" -lt "$((ts))" ]; then
            echo "$loc $session_name $ts"
            exit
        fi
    done
done < "$CACHE"
