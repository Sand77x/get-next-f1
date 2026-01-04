#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cache_script="$script_dir/cache.py"
cache_file="$HOME/.cache/get-next-f1/season.tsv"

now=$(date +%s)
current_year=$(date +%Y)

# create cache if not exist
if [ ! -f "$cache_file" ]; then
    "$cache_script" "$current_year"
fi

{
    read -r cached_year || cached_year=0

    # refresh if cache is behind real year
    if (( cached_year < current_year )); then
        "$cache_script" "$current_year"
        exec "$0"
    fi

    saw_race=0

    while IFS=$'\t' read -r loc spr s1 s2 s3 s4 s5; do
        saw_race=1

        (( now > s5 )) && continue

        sessions=("fp1" "fp2" "fp3" "quali" "race")
        timestamps=("$s1" "$s2" "$s3" "$s4" "$s5")

        # if sprint, map sessions accordingly
        if [ "$spr" = "YES" ]; then
            sessions[1]="sq"
            sessions[2]="sprint"
        fi

        for i in "${!sessions[@]}"; do
            if (( now < timestamps[i] )); then
                echo "$loc ${sessions[i]} ${timestamps[i]}"
                exit
            fi
        done
    done

    # if season done but API is not updated
    if (( ! saw_race )); then
        echo "Season done!"
        exit 0
    fi

    # if season done and API is updated
    next_year=$((cached_year + 1))
    "$cache_script" "$next_year"
    exec "$0"

} < "$cache_file"
