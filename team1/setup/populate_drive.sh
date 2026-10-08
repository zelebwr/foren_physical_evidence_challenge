#!/usr/bin/env bash
set -e

TARGET_DEV="/dev/sdb1"
MOUNT_DIR="/mnt/ext"

echo "[*] Step 1: Checking mount point ${MOUNT_DIR}..."

# Ensure target mount point directory exists
sudo mkdir -p "${MOUNT_DIR}"

# Check if mounted; mount if necessary
if ! mountpoint -q "${MOUNT_DIR}"; then
    echo "[*] Mounting ${TARGET_DEV} to ${MOUNT_DIR}..."
    sudo mount "${TARGET_DEV}" "${MOUNT_DIR}"
else
    echo "[+] ${TARGET_DEV} is already mounted at ${MOUNT_DIR}."
fi

echo "[*] Building complete Linux Root Filesystem Hierarchy (FHS)..."

# 1. Standard Linux Root Directories
sudo mkdir -p "${MOUNT_DIR}/bin"
sudo mkdir -p "${MOUNT_DIR}/boot/grub"
sudo mkdir -p "${MOUNT_DIR}/dev"
sudo mkdir -p "${MOUNT_DIR}"/etc/{systemd/system,pam.d,network}
sudo mkdir -p "${MOUNT_DIR}/lib"
sudo mkdir -p "${MOUNT_DIR}/lib64"
sudo mkdir -p "${MOUNT_DIR}/media"
sudo mkdir -p "${MOUNT_DIR}/mnt"
sudo mkdir -p "${MOUNT_DIR}/opt"
sudo mkdir -p "${MOUNT_DIR}/proc"
sudo mkdir -p "${MOUNT_DIR}/root"
sudo mkdir -p "${MOUNT_DIR}/srv"
sudo mkdir -p "${MOUNT_DIR}/sys"
sudo mkdir -p "${MOUNT_DIR}/tmp"
sudo mkdir -p "${MOUNT_DIR}"/usr/{bin,lib,local/bin,share}
sudo mkdir -p "${MOUNT_DIR}"/var/{log/{audit,journal},spool,backups}

# Set standard restricted sticky-bit permission on /tmp
sudo chmod 1777 "${MOUNT_DIR}/tmp"

echo "[*] Creating user home directories for Billy and Bob..."

# 2. XDG Standard Subdirectories for User "billy"
BILLY_HOME="${MOUNT_DIR}/home/billy"
sudo mkdir -p "${BILLY_HOME}/Desktop"
sudo mkdir -p "${BILLY_HOME}"/Documents/{Work_Projects/Q3_Financials,Personal/Tax_Forms}
sudo mkdir -p "${BILLY_HOME}/Downloads/Software_Backups"
sudo mkdir -p "${BILLY_HOME}/Music"
sudo mkdir -p "${BILLY_HOME}/Pictures"
sudo mkdir -p "${BILLY_HOME}/Public"
sudo mkdir -p "${BILLY_HOME}/Templates"
sudo mkdir -p "${BILLY_HOME}/Videos"
sudo mkdir -p "${BILLY_HOME}"/Projects/internal_portal/{src,config,logs}

# 3. XDG Standard Subdirectories for User "bob"
BOB_HOME="${MOUNT_DIR}/home/bob"
sudo mkdir -p "${BOB_HOME}/Desktop"
sudo mkdir -p "${BOB_HOME}/Documents/System_Audits"
sudo mkdir -p "${BOB_HOME}/Downloads/Utilities"
sudo mkdir -p "${BOB_HOME}/Music"
sudo mkdir -p "${BOB_HOME}/Pictures"
sudo mkdir -p "${BOB_HOME}/Public"
sudo mkdir -p "${BOB_HOME}/Templates"
sudo mkdir -p "${BOB_HOME}/Videos"

echo "[*] Populating System Configuration & Log files..."

# 1. /etc Configuration Files
sudo bash -c "cat << 'EOF' > '${MOUNT_DIR}/etc/passwd'
root:x:0:0:root:/root:/bin/bash
billy:x:1001:1001:Billy Smith,,,:/home/billy:/bin/bash
bob:x:1002:1002:Bob Miller,,,:/home/bob:/bin/bash
EOF"

sudo bash -c "cat << 'EOF' > '${MOUNT_DIR}/etc/hostname'
confidential-workstation
EOF"

sudo bash -c "cat << 'EOF' > '${MOUNT_DIR}/etc/hosts'
127.0.0.1   localhost
127.0.1.1   confidential-workstation
192.168.1.50 internal-db.local
EOF"

# 2. System Audit Log (Crucial Investigator Breadcrumb)
sudo bash -c "cat << 'EOF' > '${MOUNT_DIR}/var/log/sys_audit.log'
2026-09-28 08:00:12 [INFO] systemd[1]: Storage mount initialized on /dev/sdb1.
2026-09-28 08:02:15 [INFO] storage_mgr: Processing scheduled ticket #IT-8842 (Re-image Workstation).
2026-09-28 08:05:22 [INFO] storage_mgr: Ext4 partition /dev/sdb1 formatted with corporate baseline.
2026-09-28 08:06:01 [INFO] storage_mgr: GPT partition table aligned to 2048 sector boundary.
2026-09-28 08:06:45 [DEBUG] storage_mgr: Pre-allocation check OK. Sector offset 0x0000C800 reserved. Mask 0x5A applied.
2026-09-28 08:07:00 [INFO] systemd[1]: Re-image task complete. Drive ready for redeployment.
EOF"

echo "[*] Populating Billy's Home Directory (/home/billy)..."

# Billy's Desktop & Work Files
sudo bash -c "cat << 'EOF' > '${BILLY_HOME}/Desktop/meeting_notes.txt'
Sprint Planning - Oct 2026
- Finalize internal portal API endpoints
- Update PostgreSQL database connection pool
- Hand over server audit logs to Bob
EOF"

sudo bash -c "cat << 'EOF' > '${BILLY_HOME}/Documents/Work_Projects/Q3_Financials/q3_budget_draft.csv'
Department,Quarter,Budget_USD,Approved_By,Status
Software Eng,Q3,220000,M_Jenkins,Approved
IT Security,Q3,85000,Bob_Miller,Pending
DevOps,Q3,110000,M_Jenkins,Approved
EOF"

sudo bash -c "cat << 'EOF' > '${BILLY_HOME}/Documents/Personal/Tax_Forms/notes.txt'
Remember to submit 2025 income tax declaration before end of month.
EOF"

# Billy's Code Base
sudo bash -c "cat << 'EOF' > '${BILLY_HOME}/Projects/internal_portal/src/server.py'
import os
import json

def load_config():
    with open('../config/app_settings.json', 'r') as f:
        return json.load(f)

if __name__ == '__main__':
    config = load_config()
    print(f'[+] Starting server on port {config[\"port\"]}...')
EOF"

sudo bash -c "cat << 'EOF' > '${BILLY_HOME}/Projects/internal_portal/config/app_settings.json'
{
  "app_name": "Internal Enterprise Portal",
  "version": "2.4.1",
  "port": 8080,
  "db_host": "192.168.1.50",
  "db_port": 5432,
  "debug": false
}
EOF"

# Dummy Media / Binary Files for Billy
sudo dd if=/dev/urandom of="${BILLY_HOME}/Pictures/profile_photo.jpg" bs=1K count=12 2>/dev/null 
sudo dd if=/dev/urandom of="${BILLY_HOME}/Music/lofi_track1.mp3" bs=1K count=24 2>/dev/null
sudo dd if=/dev/urandom of="${BILLY_HOME}/Downloads/Software_Backups/node_modules_backup.tar.gz" bs=1K count=64 2>/dev/null

echo "[*] Populating Bob's Home Directory (/home/bob)..."

# Bob's IT Ticket Work Item
sudo bash -c "cat << 'EOF' > '${BOB_HOME}/Desktop/ticket_IT-8842.txt'
TICKET ID: IT-8842
Assignee: Bob Miller
Task: Wipe and re-image external NVMe drive /dev/sdb from workstation #10 for re-allocation.
Notes: Verify GPT sector alignment and apply baseline standard image.
EOF"

sudo bash -c "cat << 'EOF' > '${BOB_HOME}/Desktop/admin_todo.txt'
- Complete ticket #IT-8842
- Audit user privileges on confidential-workstation
- Verify syslog retention policies
EOF"

sudo bash -c "cat << 'EOF' > '${BOB_HOME}/Documents/System_Audits/network_inventory.csv'
Hostname,IP_Address,OS,Role,Status
confidential-workstation,192.168.1.10,Fedora 41,Workstation,Active
internal-db,192.168.1.50,Ubuntu 24.04,Database,Active
border-fw,192.168.1.1,pfSense,Firewall,Active
EOF"

sudo bash -c "cat << 'EOF' > '${BOB_HOME}/Downloads/Utilities/nmap_scan_results.txt'
Nmap scan report for 192.168.1.50
Host is up (0.00042s latency).
PORT     STATE SERVICE
22/tcp   open  ssh
5432/tcp open  postgresql
EOF"

# Dummy Media Files for Bob
sudo dd if=/dev/urandom of="${BOB_HOME}/Pictures/network_diagram.png" bs=1K count=18 2>/dev/null

echo "[*] Backdating file timestamps..."
sudo touch -d "2026-04-12 11:15:00" "${BILLY_HOME}/Projects/internal_portal/src/server.py"
sudo touch -d "2026-06-20 09:30:22" "${BILLY_HOME}/Projects/internal_portal/config/app_settings.json"
sudo touch -d "2026-08-14 14:22:10" "${BILLY_HOME}/Documents/Work_Projects/Q3_Financials/q3_budget_draft.csv"
sudo touch -d "2026-09-10 18:05:00" "${BILLY_HOME}/Desktop/meeting_notes.txt"
sudo touch -d "2026-09-27 16:40:00" "${BOB_HOME}/Desktop/ticket_IT-8842.txt"
sudo touch -d "2026-09-28 08:07:00" "${MOUNT_DIR}/var/log/sys_audit.log"

echo "[*] Creating and deleting decoy files to populate orphan inodes..."
sudo bash -c "echo 'DB_PASSWORD=SuperSecretPass2026!' > '${BOB_HOME}/Downloads/Utilities/db_credentials_old.txt'"
sudo bash -c "echo 'Confidential Payroll Master File Draft' > '${BILLY_HOME}/Documents/Work_Projects/payroll_draft.docx'"

# Flush writes so inodes record before deletion
sudo sync

# Delete decoys
sudo rm "${BOB_HOME}/Downloads/Utilities/db_credentials_old.txt"
sudo rm "${BILLY_HOME}/Documents/Work_Projects/payroll_draft.docx"

echo "[*] Setting ownership and permissions..."
sudo chown -R 1001:1001 "${BILLY_HOME}"
sudo chown -R 1002:1002 "${BOB_HOME}"

echo "[*] Flushing disk buffers and cleanly unmounting..."
sudo sync
sudo umount "${MOUNT_DIR}"

echo "[+] Drive filesystem structure cleanly populated and ready!"
