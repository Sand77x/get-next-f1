#!/usr/bin/python3

from pathlib import Path
from datetime import datetime, timezone
from urllib.request import urlopen
import json
import csv
import sys

# !!IMPORTANT 
# first argument is the year to cache!
URL = f"https://api.jolpi.ca/ergast/f1/{sys.argv[1]}.json"

CACHE_DIR = Path.home() / ".cache/get-next-f1/"
CACHE_TSV = CACHE_DIR / "season.tsv"

def get_data():
    with urlopen(URL) as resp:
        return json.load(resp)

def fmt_useful_info():
    data = get_data()
    race_table = data['MRData']['RaceTable']
    season_year = race_table['season']
    races_data = race_table['Races']
    races_dict = [
        { 
            "location": ra['Circuit']['Location']['locality'],
            "fp1": ra.get('FirstPractice'),
            "fp2": ra.get('SecondPractice'),
            "fp3": ra.get('ThirdPractice'),
            "sq": ra.get('SprintQualifying'),
            "sprint": ra.get('Sprint'),
            "quali": ra.get('Qualifying'),
            "race": { "date": ra['date'], "time": ra['time'] },
        } 
        for ra in races_data
    ]

    for ra in races_dict:
        for key in ra:
            if key != "location" and ra[key] is not None:
                dt = datetime.fromisoformat(
                    f"{ra[key]['date']}T{ra[key]['time'].rstrip('Z')}"
                )
                ra[key] = int(dt.replace(tzinfo=timezone.utc).timestamp())
    
    return {
        "year": season_year,
        "races": races_dict,
    }
    

def write_cache():
    info = fmt_useful_info()

    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    with open(CACHE_TSV, "w") as file:
        writer = csv.writer(file, delimiter="\t", lineterminator="\n")
        writer.writerow([info['year']])

        for ra in info['races']:
            if ra['sprint'] is None:
                writer.writerow([ra['location'], "NO", ra['fp1'], ra['fp2'], ra['fp3'], ra['quali'], ra['race']])
            else:
                writer.writerow([ra['location'], "YES", ra['fp1'], ra['sq'], ra['sprint'], ra['quali'], ra['race']])

write_cache()
