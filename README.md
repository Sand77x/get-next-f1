### Get next F1 race
Short script(s) I wrote that just outputs the next F1 session in this format
``` sh
location session_name timestamp
```
Example:
``` sh
Melbourne fp1 12345677  
Shanghai sq 12345677  
```  

Timestamp is in unix time (seconds since epoch). Use it however you like via `./get-next.sh`, I use this to have f1 data in my i3status bar xd.   
There's only 2 files so if you want custom functionality it should be really easy to fork it yourself. Sorry for bad code lol.  

### Installation
``` sh
git clone https://github.com/Sand77x/get-next-f1.git 
cd get-next-f1
chmod +x cache.py
chmod +x get-next.sh
```
### API
Uses the Ergast API to get data for the current season, then caches it so repeated calls are fast. Well, we only cache once a year basically.
### Caching
The python script is for caching purposes, if you want a TSV file of all sessions in the current season, execute the file via `./cache.py` and check `$HOME/.cache/f1/season.tsv`. Each column means __location__, __is_sprint__, then __timestamps for sessions 1 - 5__ respectively (session 2 and 3 are either fp2/fp3 or sq/sprint).
```
2026
Melbourne	NO	1772760600	1772773200	1772847000	1772859600	1772942400
Shanghai	YES	1773372600	1773387000	1773457200	1773471600	1773558000
Suzuka	NO	1774578600	1774591200	1774665000	1774677600	1774760400
Sakhir	NO	1775820600	1775833200	1775910600	1775923200	1776006000
Jeddah	NO	1776432600	1776445200	1776519000	1776531600	1776618000
Miami	YES	1777653000	1777667400	1777737600	1777752000	1777838400
Montreal	YES	1779467400	1779481800	1779552000	1779566400	1779652800
...
```
