url = 'https://localhost:8080/UNICORE/rest/core'
try:
    from urllib3 import disable_warnings
    disable_warnings()
except:
    pass

import requests, sys
try:
    r = requests.get(verify=False, 
                headers={'Accept': 'application/json'},
                url=url)
    r.json()
    if r.status_code==200:
        sys.exit(0)
except Exception:
    pass
sys.exit(1)
