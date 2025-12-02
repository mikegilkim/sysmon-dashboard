# 📊 System Resource Monitor

Real-time Linux system monitoring in your terminal. Fast, and simple.


## Install

```bash
curl -sSL https://raw.githubusercontent.com/mikegilkim/sysmon-dashboard/main/install.sh | sudo bash
```

## Usage

```bash
sysmon
```

## What You Get

- 💻 **CPU Usage** - Real-time usage, cores, frequency, load average
- 🧠 **Memory Stats** - RAM and SWAP with visual progress bars
- 💾 **Disk Usage** - All mounted drives with usage percentages
- 🌐 **Network Info** - Interface stats, traffic, active connections
- ⚡ **Top Processes** - CPU and memory hogs identified
- 🔧 **Service Status** - Key system services health check

## Features

✅ Color-coded alerts (Green → Yellow → Red)  
✅ Zero dependencies (pure Bash)  
✅ Works on all Linux distros  
✅ < 1 second refresh time  
✅ One command installation  

## Sample UI

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                      SYSTEM RESOURCE MONITOR                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

▶ CPU USAGE
────────────────────────────────────────────────────────────────────────────────
  Model:           Intel(R) Xeon(R) CPU @ 2.40GHz
  Cores:           2
  Usage:           15.2%
  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

▶ MEMORY USAGE
────────────────────────────────────────────────────────────────────────────────
  Total:           2048 MB
  Used:            1234 MB
  Memory Usage:    60%
  ████████████████████████░░░░░░░░░░░░░░░░
```

## Requirements

- Linux (Ubuntu, Debian, CentOS, RHEL, Arch)
- Bash 4.0+
- Root/sudo access for installation

## Manual Install

```bash
wget https://raw.githubusercontent.com/mikegilkim/sysmon-dashboard/main/sysmon-dashboard.sh
chmod +x sysmon-dashboard.sh
sudo mv sysmon-dashboard.sh /usr/local/bin/sysmon-dashboard
echo "alias sysmon='/usr/local/bin/sysmon-dashboard'" >> ~/.bashrc
source ~/.bashrc
```

## Why This Tool?

Replaces: `top`, `htop`, `free`, `df`, `netstat`, `ps aux`  
With: One simple command - `sysmon`

Perfect for:
- Quick system health checks
- Server monitoring
- Performance troubleshooting
- Learning system administration

## License

MIT - Use it anywhere, modify it however you want.

---
