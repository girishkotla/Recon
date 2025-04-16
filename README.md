# KillBill - Recon
Recon that separates results for you to ease the work

# Usage
## 1. Manual (./manual.sh)
``` bash
root@killbill:~/recon# ./manual.sh 
Enter root domain: <example.com>
Enter organization name: example
```
Results:
```
root@killbill:~/recon/TFH# ls
200.txt  301.txt  302.txt  401.txt  403.txt  404.txt  502.txt  503.txt  all_subs.txt  last_notified_metadata.txt  metadata.tmp  metadata.txt  resolved.txt  rootdomain.txt
```

## 2. Set a cron job to run the auto_cron.sh

crontab -e

Enter this:
0 4 * * * /root/recon/auto_cron.sh >> /root/recon/cron.log 2>&1

### Format:
```
* * * * * command_to_run
│ │ │ │ │
│ │ │ │ └─── Day of week (0 - 7) (Sunday = 0 or 7)
│ │ │ └───── Month (1 - 12)
│ │ └─────── Day of month (1 - 31)
│ └───────── Hour (0 - 23)
└─────────── Minute (0 - 59)
```
