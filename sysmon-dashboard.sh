#!/bin/bash

# System Resource Monitor Dashboard

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# Box drawing characters
TL='╔'
TR='╗'
BL='╚'
BR='╝'
H='═'
V='║'

# Function to print a line
print_line() {
    local width=$1
    local char=$2
    printf "${char}%.0s" $(seq 1 $width)
}

# Function to print centered header
print_header() {
    local text="$1"
    local width=80
    local text_len=${#text}
    local padding=$(( (width - text_len - 2) / 2 ))
    
    echo -e "${CYAN}${TL}$(print_line $((width-2)) $H)${TR}${NC}"
    printf "${CYAN}${V}${NC}"
    printf "%*s" $padding
    echo -ne "${WHITE}${BOLD}${text}${NC}"
    printf "%*s" $((width - text_len - padding - 2))
    echo -e "${CYAN}${V}${NC}"
    echo -e "${CYAN}${BL}$(print_line $((width-2)) $H)${BR}${NC}"
}

# Function to print section header
print_section() {
    local text="$1"
    echo ""
    echo -e "${YELLOW}${BOLD}▶ ${text}${NC}"
    echo -e "${YELLOW}$(print_line 80 '─')${NC}"
}

# Function to draw progress bar
draw_bar() {
    local percentage=$1
    local width=40
    local color=$2
    local filled=$(( percentage * width / 100 ))
    local empty=$(( width - filled ))
    
    printf "${color}"
    printf '█%.0s' $(seq 1 $filled)
    printf "${GRAY}"
    printf '░%.0s' $(seq 1 $empty)
    printf "${NC}"
}

# Function to get color based on percentage
get_color() {
    local val=$1
    if [ $val -lt 50 ]; then
        echo "$GREEN"
    elif [ $val -lt 80 ]; then
        echo "$YELLOW"
    else
        echo "$RED"
    fi
}

# Function to format bytes
format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$(( bytes / 1024 ))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$(( bytes / 1048576 ))MB"
    else
        echo "$(( bytes / 1073741824 ))GB"
    fi
}

# Clear screen
clear

# Get system information
HOSTNAME=$(hostname)
UPTIME=$(uptime -p | sed 's/up //')
KERNEL=$(uname -r)
OS=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2)

# Print header
print_header "SYSTEM RESOURCE MONITOR"

# System Information
print_section "SYSTEM INFORMATION"
echo -e "  ${WHITE}Hostname:${NC}        ${CYAN}$HOSTNAME${NC}"
echo -e "  ${WHITE}OS:${NC}              ${CYAN}$OS${NC}"
echo -e "  ${WHITE}Kernel:${NC}          ${CYAN}$KERNEL${NC}"
echo -e "  ${WHITE}Uptime:${NC}          ${GREEN}$UPTIME${NC}"

# CPU Information
print_section "CPU USAGE"

# Get CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
CPU_USAGE_INT=${CPU_USAGE%.*}
CPU_COLOR=$(get_color $CPU_USAGE_INT)

# Get CPU info
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
CPU_CORES=$(nproc)
CPU_FREQ=$(lscpu | grep "CPU MHz" | awk '{print $3}' | head -1)
CPU_FREQ_INT=${CPU_FREQ%.*}

echo -e "  ${WHITE}Model:${NC}           ${CYAN}$CPU_MODEL${NC}"
echo -e "  ${WHITE}Cores:${NC}           ${CYAN}$CPU_CORES${NC}"
echo -e "  ${WHITE}Frequency:${NC}       ${CYAN}${CPU_FREQ_INT} MHz${NC}"
echo ""
echo -e "  ${WHITE}Usage:${NC}           ${CPU_COLOR}${BOLD}${CPU_USAGE}%${NC}"
echo -n "  "
draw_bar $CPU_USAGE_INT "$CPU_COLOR"
echo ""

# Load Average
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo -e "  ${WHITE}Load Average:${NC}    ${CYAN}$LOAD${NC}"

# Memory Information
print_section "MEMORY USAGE"

# Get memory info
MEM_TOTAL=$(free -m | awk 'NR==2{print $2}')
MEM_USED=$(free -m | awk 'NR==2{print $3}')
MEM_FREE=$(free -m | awk 'NR==2{print $4}')
MEM_AVAILABLE=$(free -m | awk 'NR==2{print $7}')
MEM_PERCENT=$(( MEM_USED * 100 / MEM_TOTAL ))
MEM_COLOR=$(get_color $MEM_PERCENT)

# Swap info
SWAP_TOTAL=$(free -m | awk 'NR==3{print $2}')
SWAP_USED=$(free -m | awk 'NR==3{print $3}')
if [ $SWAP_TOTAL -gt 0 ]; then
    SWAP_PERCENT=$(( SWAP_USED * 100 / SWAP_TOTAL ))
else
    SWAP_PERCENT=0
fi
SWAP_COLOR=$(get_color $SWAP_PERCENT)

echo -e "  ${WHITE}Total:${NC}           ${CYAN}${MEM_TOTAL} MB${NC}"
echo -e "  ${WHITE}Used:${NC}            ${MEM_COLOR}${MEM_USED} MB${NC}"
echo -e "  ${WHITE}Free:${NC}            ${GREEN}${MEM_FREE} MB${NC}"
echo -e "  ${WHITE}Available:${NC}       ${GREEN}${MEM_AVAILABLE} MB${NC}"
echo ""
echo -e "  ${WHITE}Memory Usage:${NC}    ${MEM_COLOR}${BOLD}${MEM_PERCENT}%${NC}"
echo -n "  "
draw_bar $MEM_PERCENT "$MEM_COLOR"
echo ""
echo ""
echo -e "  ${WHITE}Swap Total:${NC}      ${CYAN}${SWAP_TOTAL} MB${NC}"
echo -e "  ${WHITE}Swap Used:${NC}       ${SWAP_COLOR}${SWAP_USED} MB${NC}"
if [ $SWAP_TOTAL -gt 0 ]; then
    echo -e "  ${WHITE}Swap Usage:${NC}      ${SWAP_COLOR}${BOLD}${SWAP_PERCENT}%${NC}"
    echo -n "  "
    draw_bar $SWAP_PERCENT "$SWAP_COLOR"
    echo ""
fi

# Disk Usage
print_section "DISK USAGE"

df -h | grep -E '^/dev/' | while read line; do
    FILESYSTEM=$(echo $line | awk '{print $1}')
    SIZE=$(echo $line | awk '{print $2}')
    USED=$(echo $line | awk '{print $3}')
    AVAIL=$(echo $line | awk '{print $4}')
    USE_PERCENT=$(echo $line | awk '{print $5}' | sed 's/%//')
    MOUNT=$(echo $line | awk '{print $6}')
    
    DISK_COLOR=$(get_color $USE_PERCENT)
    
    echo ""
    echo -e "  ${CYAN}${BOLD}$MOUNT${NC} ${GRAY}($FILESYSTEM)${NC}"
    echo -e "  ${WHITE}Size:${NC}            ${CYAN}$SIZE${NC}"
    echo -e "  ${WHITE}Used:${NC}            ${DISK_COLOR}$USED${NC}"
    echo -e "  ${WHITE}Available:${NC}       ${GREEN}$AVAIL${NC}"
    echo -e "  ${WHITE}Usage:${NC}           ${DISK_COLOR}${BOLD}${USE_PERCENT}%${NC}"
    echo -n "  "
    draw_bar $USE_PERCENT "$DISK_COLOR"
    echo ""
done

# Network Statistics
print_section "NETWORK STATISTICS"

# Get primary network interface
PRIMARY_IF=$(ip route | grep default | awk '{print $5}' | head -1)

if [ ! -z "$PRIMARY_IF" ]; then
    # Get IP addresses
    IPV4=$(ip -4 addr show $PRIMARY_IF | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    IPV6=$(ip -6 addr show $PRIMARY_IF | grep -oP '(?<=inet6\s)[0-9a-f:]+' | grep -v "^fe80" | head -1)
    
    echo -e "  ${WHITE}Interface:${NC}       ${CYAN}$PRIMARY_IF${NC}"
    echo -e "  ${WHITE}IPv4:${NC}            ${CYAN}$IPV4${NC}"
    if [ ! -z "$IPV6" ]; then
        echo -e "  ${WHITE}IPv6:${NC}            ${CYAN}$IPV6${NC}"
    fi
    
    # Network traffic (if interface exists in /proc/net/dev)
    if [ -f /proc/net/dev ]; then
        RX_BYTES=$(cat /proc/net/dev | grep "$PRIMARY_IF" | awk '{print $2}')
        TX_BYTES=$(cat /proc/net/dev | grep "$PRIMARY_IF" | awk '{print $10}')
        
        RX_FORMATTED=$(format_bytes $RX_BYTES)
        TX_FORMATTED=$(format_bytes $TX_BYTES)
        
        echo ""
        echo -e "  ${WHITE}Received:${NC}        ${GREEN}$RX_FORMATTED${NC}"
        echo -e "  ${WHITE}Transmitted:${NC}     ${BLUE}$TX_FORMATTED${NC}"
    fi
    
    # Active connections
    CONNECTIONS=$(ss -tun | grep ESTAB | wc -l)
    echo ""
    echo -e "  ${WHITE}Active Connections:${NC} ${CYAN}$CONNECTIONS${NC}"
fi

# Top Processes
print_section "TOP 5 PROCESSES BY CPU"
echo ""
printf "  ${WHITE}%-8s %-8s %-8s %-40s${NC}\n" "PID" "CPU%" "MEM%" "COMMAND"
echo -e "  ${WHITE}$(print_line 78 '─')${NC}"

ps aux --sort=-%cpu | head -6 | tail -5 | while read line; do
    PID=$(echo $line | awk '{print $2}')
    CPU=$(echo $line | awk '{print $3}')
    MEM=$(echo $line | awk '{print $4}')
    CMD=$(echo $line | awk '{print $11}' | cut -c1-40)
    
    CPU_INT=${CPU%.*}
    CPU_COLOR=$(get_color $CPU_INT)
    
    printf "  ${CYAN}%-8s${NC} ${CPU_COLOR}%-8s${NC} ${YELLOW}%-8s${NC} ${WHITE}%-40s${NC}\n" "$PID" "$CPU%" "$MEM%" "$CMD"
done

print_section "TOP 5 PROCESSES BY MEMORY"
echo ""
printf "  ${WHITE}%-8s %-8s %-8s %-40s${NC}\n" "PID" "CPU%" "MEM%" "COMMAND"
echo -e "  ${WHITE}$(print_line 78 '─')${NC}"

ps aux --sort=-%mem | head -6 | tail -5 | while read line; do
    PID=$(echo $line | awk '{print $2}')
    CPU=$(echo $line | awk '{print $3}')
    MEM=$(echo $line | awk '{print $4}')
    CMD=$(echo $line | awk '{print $11}' | cut -c1-40)
    
    MEM_INT=${MEM%.*}
    MEM_COLOR=$(get_color $MEM_INT)
    
    printf "  ${CYAN}%-8s${NC} ${YELLOW}%-8s${NC} ${MEM_COLOR}%-8s${NC} ${WHITE}%-40s${NC}\n" "$PID" "$CPU%" "$MEM%" "$CMD"
done

# System Services
print_section "SYSTEM SERVICES STATUS"
echo ""

# Check important services
SERVICES=("ssh" "fail2ban" "ufw" "cron" "systemd-resolved")

for service in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^${service}.service"; then
        if systemctl is-active --quiet $service; then
            echo -e "  ${GREEN}●${NC} ${WHITE}${service}${NC} ${GREEN}running${NC}"
        else
            echo -e "  ${RED}●${NC} ${WHITE}${service}${NC} ${RED}stopped${NC}"
        fi
    fi
done

# Quick Actions
print_section "QUICK ACTIONS"
echo -e "  ${WHITE}Detailed CPU info:${NC}       ${CYAN}htop${NC} or ${CYAN}top${NC}"
echo -e "  ${WHITE}Detailed memory info:${NC}    ${CYAN}free -h${NC}"
echo -e "  ${WHITE}Disk usage by directory:${NC} ${CYAN}du -sh /*${NC}"
echo -e "  ${WHITE}Network connections:${NC}     ${CYAN}ss -tunap${NC}"
echo -e "  ${WHITE}Kill process:${NC}            ${CYAN}kill -9 <PID>${NC}"
echo -e "  ${WHITE}Reboot system:${NC}           ${CYAN}sudo reboot${NC}"

# Footer
echo ""
echo -e "${CYAN}$(print_line 80 '═')${NC}"
echo -e "${WHITE}  Real-time system monitoring  |  Run ${CYAN}sysmon${WHITE} anytime  |  Press Ctrl+C to exit${NC}"
echo -e "${CYAN}$(print_line 80 '═')${NC}"
echo ""
echo -e "${CYAN}                        ╔══════════════════════════════╗${NC}"
echo -e "${CYAN}                        ║${NC} ${BOLD}${MAGENTA}★${NC} ${BOLD}${WHITE}Created by${NC} ${BOLD}${CYAN}mikegilkim${NC} ${BOLD}${MAGENTA}★${NC} ${CYAN}║${NC}"
echo -e "${CYAN}                        ║${NC}   ${BLUE}facebook.com/mikegilkim${NC}   ${CYAN}║${NC}"
echo -e "${CYAN}                        ╚══════════════════════════════╝${NC}"
echo ""
