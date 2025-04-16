Here's a cleaner and more polished version of your `README.md` with improved formatting, consistency, and clarity:

# 🔪 KillBill - Recon

Automated recon that separates and organizes results to make your workflow easier.

---

## 🚀 Usage

### 1. Manual Mode (`./manual.sh`)

Run the script and follow the prompts:

```bash
root@killbill:~/recon# ./manual.sh
Enter root domain: <example.com>
Enter organization name: <org>
```

#### 📂 Results will be saved in:
```
/root/recon/<org>/
```

Example file list:
```
200.txt  301.txt  302.txt  401.txt  403.txt  404.txt  502.txt  503.txt  all_subs.txt  last_notified_metadata.txt  metadata.tmp  metadata.txt  resolved.txt rootdomain.txt
```

---

### 2. ✈️ Auto Mode (via Cron Job)

To automate recon daily at 4:00 AM, add the following line to your crontab:

```bash
crontab -e
```

```bash
0 4 * * * /root/recon/auto_cron.sh >> /root/recon/cron.log 2>&1
```

📌 **Crontab format reference:**
```
* * * * * command_to_run
│ │ │ │ │
│ │ │ │ └─── Day of week (0 - 7) (Sunday = 0 or 7)
│ │ │ └───── Month (1 - 12)
│ │ └─────── Day of month (1 - 31)
│ └───────── Hour (0 - 23)
└─────────── Minute (0 - 59)
```

---

Happy Hunting 🕵️‍♂️💥
