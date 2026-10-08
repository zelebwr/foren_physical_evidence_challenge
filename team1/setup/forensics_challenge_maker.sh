#!/usr/bin/env bash
set -e

DISK_DEV="/dev/sdb"
PART_DEV="/dev/sdb1"
MOUNT_DIR="/mnt/ext"

echo "=========================================================="
echo "  DIGITAL FORENSICS LAB BUILDER - MASTER RESET & DEPLOY   "
echo "=========================================================="

# -----------------------------------------------------------------------------
# STEP 1: SAFETY UNMOUNT & ZERO-FILL WIPEOUT
# -----------------------------------------------------------------------------
echo "[*] Step 1: Unmounting any active partition mounts..."

sudo fuser -k -9 /dev/sdb /dev/sdb1 2>/dev/null || true

sudo umount -f ${DISK_DEV}* 2>/dev/null || true
sudo umount -f "${MOUNT_DIR}" 2>/dev/null || true

sudo sync
sudo udevadm settle

echo "[*] Zeroing GPT header, unallocated sectors, and old payload (Sectors 0-4096)..."
sudo dd if=/dev/zero of="${DISK_DEV}" bs=512 count=4096 status=none conv=fdatasync

sudo blockdev --rereadpt "${DISK_DEV}" 2>/dev/null || true
sudo udevadm settle

# -----------------------------------------------------------------------------
# STEP 2: RE-PARTITION & FORMAT FRESH EXT4 FILESYSTEM
# -----------------------------------------------------------------------------
echo "[*] Step 2: Creating fresh GPT partition table..."
sudo parted --script "${DISK_DEV}" --script mklabel gpt
sudo parted --script "${DISK_DEV}" --script mkpart primary ext4 2048s 4GiB

sudo partprobe "${DISK_DEV}"
sudo udevadm settle

echo "[*] Formatting ${PART_DEV} with fresh ext4 filesystem..."
sudo mkfs.ext4 -F -L "CONFIDENTIAL" "${PART_DEV}"

# -----------------------------------------------------------------------------
# STEP 3: MOUNT & BUILD LINUX FHS SCAFFOLDING
# -----------------------------------------------------------------------------
echo "[*] Step 3: Mounting ${PART_DEV} to ${MOUNT_DIR}..."
sudo mkdir -p "${MOUNT_DIR}"
sudo mount "${PART_DEV}" "${MOUNT_DIR}"

echo "[*] Building Linux Filesystem Hierarchy Standard (FHS)..."

# Root system directories (Brace expansion outside double-quotes)
sudo mkdir -p "${MOUNT_DIR}"/bin
sudo mkdir -p "${MOUNT_DIR}"/boot/grub
sudo mkdir -p "${MOUNT_DIR}"/dev
sudo mkdir -p "${MOUNT_DIR}"/etc/{systemd/system,pam.d,network}
sudo mkdir -p "${MOUNT_DIR}"/lib
sudo mkdir -p "${MOUNT_DIR}"/lib64
sudo mkdir -p "${MOUNT_DIR}"/media
sudo mkdir -p "${MOUNT_DIR}"/mnt
sudo mkdir -p "${MOUNT_DIR}"/opt
sudo mkdir -p "${MOUNT_DIR}"/proc
sudo mkdir -p "${MOUNT_DIR}"/root
sudo mkdir -p "${MOUNT_DIR}"/srv
sudo mkdir -p "${MOUNT_DIR}"/sys
sudo mkdir -p "${MOUNT_DIR}"/tmp
sudo mkdir -p "${MOUNT_DIR}"/usr/{bin,lib,local/bin,share}
sudo mkdir -p "${MOUNT_DIR}"/var/{log/{audit,journal},spool,backups}

sudo chmod 1777 "${MOUNT_DIR}/tmp"

# User Home Directories
BILLY_HOME="${MOUNT_DIR}/home/billy"
BOB_HOME="${MOUNT_DIR}/home/bob"

sudo mkdir -p "${BILLY_HOME}"/{Desktop,Downloads/Software_Backups,Music,Pictures,Public,Templates,Videos}
sudo mkdir -p "${BILLY_HOME}"/Documents/{Work_Projects/Q3_Financials,Personal/Tax_Forms}
sudo mkdir -p "${BILLY_HOME}"/Projects/internal_portal/{src,config,logs}

sudo mkdir -p "${BOB_HOME}"/{Desktop,Documents/System_Audits,Downloads/Utilities,Music,Pictures,Public,Templates,Videos}

# -----------------------------------------------------------------------------
# STEP 4: POPULATE SYSTEM CONFIGS, USER FILES & BREADCRUMB LOGS
# -----------------------------------------------------------------------------
echo "[*] Step 4: Generating system configuration files and audit logs..."

# /etc Files
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

# Breadcrumb System Audit Log
sudo bash -c "cat << 'EOF' > '${MOUNT_DIR}/var/log/sys_audit.log'
2026-09-28 08:00:12 [INFO] systemd[1]: Storage mount initialized on /dev/sdb1.
2026-09-28 08:02:15 [INFO] storage_mgr: Processing scheduled ticket #IT-8842 (Re-image Workstation).
2026-09-28 08:05:22 [INFO] storage_mgr: Ext4 partition /dev/sdb1 formatted with corporate baseline.
2026-09-28 08:06:01 [INFO] storage_mgr: GPT partition table aligned to 2048 sector boundary.
2026-09-28 08:06:45 [DEBUG] storage_mgr: Pre-allocation check OK. Sector offset 0x0000C800 reserved. Mask 0x5A applied.
2026-09-28 08:07:00 [INFO] systemd[1]: Re-image task complete. Drive ready for redeployment.
EOF"

echo "[*] Populating files for user 'billy'..."
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

# Escaped double-quotes inside app_settings.json to prevent string collision with bash -c
sudo bash -c "cat << 'EOF' > '${BILLY_HOME}/Projects/internal_portal/config/app_settings.json'
{
  \"app_name\": \"Internal Enterprise Portal\",
  \"version\": \"2.4.1\",
  \"port\": 8080,
  \"db_host\": \"192.168.1.50\",
  \"db_port\": 5432,
  \"debug\": false
}
EOF"

# Binary / Media Noise Files
sudo dd if=/dev/urandom of="${BILLY_HOME}/Pictures/profile_photo.jpg" bs=1K count=12 status=none
sudo dd if=/dev/urandom of="${BILLY_HOME}/Music/lofi_track1.mp3" bs=1K count=24 status=none
sudo dd if=/dev/urandom of="${BILLY_HOME}/Downloads/Software_Backups/node_modules_backup.tar.gz" bs=1K count=64 status=none

echo "[*] Populating files for user 'bob'..."
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

sudo dd if=/dev/urandom of="${BOB_HOME}/Pictures/network_diagram.png" bs=1K count=18 status=none

# -----------------------------------------------------------------------------
# STEP 5: TIMESTAMPS & DECOY ORPHAN INODES
# -----------------------------------------------------------------------------
echo "[*] Step 5: Applying backdated timestamps across 2026..."
sudo touch -d "2026-04-12 11:15:00" "${BILLY_HOME}/Projects/internal_portal/src/server.py"
sudo touch -d "2026-06-20 09:30:22" "${BILLY_HOME}/Projects/internal_portal/config/app_settings.json"
sudo touch -d "2026-08-14 14:22:10" "${BILLY_HOME}/Documents/Work_Projects/Q3_Financials/q3_budget_draft.csv"
sudo touch -d "2026-09-10 18:05:00" "${BILLY_HOME}/Desktop/meeting_notes.txt"
sudo touch -d "2026-09-27 16:40:00" "${BOB_HOME}/Desktop/ticket_IT-8842.txt"
sudo touch -d "2026-09-28 08:07:00" "${MOUNT_DIR}/var/log/sys_audit.log"

echo "[*] Creating and deleting decoy files for orphan inode carving..."
sudo bash -c "echo 'DB_PASSWORD=SuperSecretPass2026!' > '${BOB_HOME}/Downloads/Utilities/db_credentials_old.txt'"
sudo bash -c "echo 'Confidential Payroll Master File Draft' > '${BILLY_HOME}/Documents/Work_Projects/payroll_draft.docx'"
sudo sync
sudo rm "${BOB_HOME}/Downloads/Utilities/db_credentials_old.txt"
sudo rm "${BILLY_HOME}/Documents/Work_Projects/payroll_draft.docx"

echo "[*] Setting ownerships..."
sudo chown -R 1001:1001 "${BILLY_HOME}"
sudo chown -R 1002:1002 "${BOB_HOME}"

# -----------------------------------------------------------------------------
# STEP 6: UNMOUNT & INJECT PAYLOAD INTO RAW SECTOR 100
# -----------------------------------------------------------------------------
echo "[*] Step 6: Flushing filesystem buffers and unmounting..."
sudo sync
sudo umount "${MOUNT_DIR}"

echo "[*] Generating corrupted + XOR-encrypted ZIP payload..."
python3 -c '
import io, zipfile

key = 0x5A
payload_text = "FLAG{anti_forensics_reimage_cover_story_2026}"

# Build minimal zip file in memory
buffer = io.BytesIO()
with zipfile.ZipFile(buffer, "w") as zf:
    zf.writestr("secret_evidence.txt", payload_text)
data = bytearray(buffer.getvalue())

# Corrupt magic bytes (50 4B 03 04 -> DE AD BE EF)
data[0:4] = b"\xDE\xAD\xBE\xEF"

# Single-byte XOR encrypt (0x5A)
encrypted = bytes([b ^ key for b in data])

with open("payload.bin", "wb") as f:
    f.write(encrypted)
'

echo "[*] Injecting payload.bin into unallocated Sector 100 on ${DISK_DEV}..."
sudo dc3dd if=payload.bin of="${DISK_DEV}" seek=100 bs=512 status=off conv=notrunc 2>/dev/null || sudo dd if=payload.bin of="${DISK_DEV}" seek=100 bs=512 status=none conv=notrunc
rm payload.bin

sudo sync

echo "=========================================================="
echo "  [+] LAB BUILD COMPLETE! DRIVE IS CLEAN & READY FOR HANDOFF "
echo "=========================================================="
