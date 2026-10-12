# PoC Team 1 Physical Evidence Challenge

Team:
1. Tasya Aulia Dermawan—5027241008
2. Evan Christian Nainggolan—5027241026
3. Jonathan Zelig Sutopo—5027241047
4. Rama Owarianto Putra Suharjito—5027231049
5. Salomo Seto—5027221063

---

List of commands used to solve the challenge:

```bash
sudo dc3dd if=/dev/sdb of=evidence_drive.raw hash=sha256 log=acquisition.log
mmls evidence_drive.raw
fls -o 2048 -r evidence_drive.raw | grep sys_audit.log
icat -o 2048 evidence_drive.raw 14
dc3dd if=foren_physical_evidence_team1_evidence_drive.raw of=carved_sector100.bin iskip=100 cnt=2 ssz=512
xxd carved_sector100.bin | head -n 4
```

---

## 1. Evidence Encapsulation & Preservation

To adhere to standard digital forencsics procedures, analysis must never be perfromed directly on physical evidence media. Connect the physical media with a read-only write-blocking software using `blockdev` and followed by a 1:1 bit-stream acquisition to create a raw forensic image file (`foren_physical_evidence_team1_evidence_drive.raw`) with real-time SHA-256 cryptographyic hashing to maintain evidence integrity and chain of custody.

```bash
blockdev --setro/dev/sdb
sudo dc3dd if=/dev/sdb of=evidence_drive.raw hash=sha256 log=acquisition.log
```

---

## 2. Analyzing the Raw Image

Before inspecting filesystems, the volume structure of the image was analyzed using The Sleuth Kit (TSK) `mmls` utility to identify partition boundaries and unallocated disk space.

```bash
$ mmls foren_physical_evidence_team1_evidence_drive.raw 
GUID Partition Table (EFI)
Offset Sector: 0
Units are in 512-byte sectors

      Slot      Start        End          Length       Description
000:  Meta      0000000000   0000000000   0000000001   Safety Table
001:  -------   0000000000   0000002047   0000002048   Unallocated
002:  Meta      0000000001   0000000001   0000000001   GPT Header
003:  Meta      0000000002   0000000033   0000000032   Partition Table
004:  000       0000002048   0008388607   0008386560   primary
005:  -------   0008388608   0500118191   0491729584   Unallocated
```

-  **Sector Unit Size:** Operating on standard 512-byte sectors.
- **Primary Partition Offset (Slot 004):** The active `ext4` Linux volume begins at **Sector 2048** ($2048 \times 512 = 1,048,576 \text{ bytes}$). All filesystem-level tools (`fls`, `icat`) must reference offset `2048`.
- **Pre-Partition Unallocated Gap (Slot 001):** Sectors `0` through `2047` (1 MiB total) are unallocated by the active filesystem. Standard operating system file managers ignore this region completely, making it an ideal primary target for low-level anti-forensic data hiding.

---

## 3. Analyizng the Filesystem Directory

Using TSK `fls` with partition offset `-o 2048`, the file hierarchy of the `ext4` volume was mapped without mounting the partition

```bash
$ fls -o 2048 -r foren_physical_evidence_team1_evidence_drive.raw
d/d 57345:	home
+ d/d 23:	billy
++ d/d 24:	Desktop
+++ r/r 54:	meeting_notes.txt
++ d/d 25:	Downloads
+++ d/d 26:	Software_Backups
++++ r/r 61:	node_modules_backup.tar.gz
++ d/d 27:	Music
+++ r/r 60:	lofi_track1.mp3
++ d/d 28:	Pictures
+++ r/r 59:	profile_photo.jpg
++ d/d 29:	Public
++ d/d 30:	Templates
++ d/d 31:	Videos
++ d/d 32:	Documents
+++ d/d 33:	Work_Projects
++++ d/d 34:	Q3_Financials
+++++ r/r 55:	q3_budget_draft.csv
+++ d/d 35:	Personal
++++ d/d 36:	Tax_Forms
+++++ r/r 56:	notes.txt
++ d/d 37:	Projects
+++ d/d 38:	internal_portal
++++ d/d 39:	src
+++++ r/r 57:	server.py
++++ d/d 40:	config
+++++ r/r 58:	app_settings.json
++++ d/d 41:	logs
+ d/d 42:	bob
++ d/d 43:	Desktop
+++ r/r 62:	ticket_IT-8842.txt
+++ r/r 63:	admin_todo.txt
++ d/d 44:	Documents
+++ d/d 45:	System_Audits
++++ r/r 64:	network_inventory.csv
++ d/d 46:	Downloads
+++ d/d 47:	Utilities
++++ r/r 65:	nmap_scan_results.txt
++ d/d 48:	Music
++ d/d 49:	Pictures
+++ r/r 66:	network_diagram.png
++ d/d 50:	Public
++ d/d 51:	Templates
++ d/d 52:	Videos
d/d 11:	lost+found
d/d 131073:	bin
d/d 131074:	boot
+ d/d 131075:	grub
d/d 131076:	dev
d/d 131077:	etc
+ d/d 131078:	systemd
++ d/d 131079:	system
+ d/d 131080:	pam.d
+ d/d 131081:	network
+ r/r 131082:	passwd
+ r/r 131083:	hostname
+ r/r 131084:	hosts
d/d 8193:	lib
d/d 8194:	lib64
d/d 16385:	media
d/d 16386:	mnt
d/d 24577:	opt
d/d 24578:	proc
d/d 32769:	root
d/d 32770:	srv
d/d 40961:	sys
d/d 40962:	tmp
d/d 49153:	usr
+ d/d 13:	bin
+ d/d 14:	lib
+ d/d 15:	local
++ d/d 16:	bin
+ d/d 17:	share
d/d 49154:	var
+ d/d 18:	log
++ d/d 19:	audit
++ d/d 20:	journal
++ r/r 53:	sys_audit.log
+ d/d 21:	spool
+ d/d 22:	backups
V/V 262145:	$OrphanFiles
+ -/r * 67:	OrphanFile-67
+ -/r * 68:	OrphanFile-68
```

- User accounts `/home/billy` (Inode 23) and `/home/bob` (Inode 42) are populated with standard workstation data.
-  `/var/log/sys_audit.log` is mapped directly to **Inode 53** (`++ r/r 53: sys_audit.log`).
- Orphan deleted files (`OrphanFile-67`, `OrphanFile-68`) represent red herring artifacts created during system preparation.

---

## 4. Analzying the Evidence

Extracting and inspecting Inode 53 (`sys_audit.log`) using `icat` revealed system audit logs left behind during Bob's re-imaging task 

```bash
# Checking log files
icat -o 2048 foren_physical_evidence_team1_evidence_drive.raw 53
2026-09-28 08:00:12 [INFO] systemd[1]: Storage mount initialized on /dev/sdb1.
2026-09-28 08:02:15 [INFO] storage_mgr: Processing scheduled ticket #IT-8842 (Re-image Workstation).
2026-09-28 08:05:22 [INFO] storage_mgr: Ext4 partition /dev/sdb1 formatted with corporate baseline.
2026-09-28 08:06:01 [INFO] storage_mgr: GPT partition table aligned to 2048 sector boundary.
2026-09-28 08:06:45 [DEBUG] storage_mgr: Pre-allocation check OK. Sector offset 0x0000C800 reserved. Mask 0x5A applied.
2026-09-28 08:07:00 [INFO] systemd[1]: Re-image task complete. Drive ready for redeployment.
```

### Anomalies identified from the logs

Line 5 logs an unusual low-level reservation during formatting:
`[DEBUG] storage_mgr: Pre-allocation check OK. Sector offset 0x0000C800 reserved. Mask 0x5A applied.`

1. **Target Byte Offset Calculation:**
   $$\text{0x0000C800} = 51,200 \text{ bytes}$$
   $$\text{Sector Index} = \frac{51,200 \text{ bytes}}{512 \text{ bytes/sector}} = \mathbf{\text{Sector } 100}$$
2. **Obfuscation Parameters:** XOR Key = `0x5A`.
3. **Anti-Forensic Location:** Sector 100 resides directly inside the **Slot 001 Unallocated Gap** (Sectors 34–2047) before the active partition boundary at Sector 2048.

---

## 5. Handling Evidence

To retrieve the hidden raw payload from Sector 100, `dc3dd` was executed with direct sector skipping parameters

```bash
$ dc3dd if=foren_physical_evidence_team1_evidence_drive.raw of=carved_sector100.bin iskip=100 cnt=1 ssz=512

dc3dd 7.3.1-dirty started at 2026-10-12 03:53:25 +0700
compiled options:
command line dc3dd if=foren_physical_evidence_team1_evidence_drive.raw of=carved_sector100.bin iskip=100 cnt=1 ssz=512
sector size: 512 bytes (set)
         512 bytes ( 512 ) copied ( 100% ),    0 s, 5 K/s                     

input results for file `foren_physical_evidence_team1_evidence_drive.raw':
   1 sectors in

output results for file `carved_sector100.bin':
   1 sectors out

dc3dd completed at 2026-10-12 03:53:25 +0700
```

**Command Parameter Breakdown**
- **`if=...`**: Input source forensic image file.
- **`of=carved_sector100.bin`**: Destination output binary file.
- **`iskip=100`**: Skips the first 100 input sectors ($100 \times 512 = 51,200 \text{ bytes}$) to land precisely at Sector 100.
- **`cnt=1`**: Reads 1 sector (512 bytes) containing the payload block.
- **`ssz=512`**: Configures the logical sector size explicitly to 512 bytes.

### Inspecting Raw Bytes

Converting `carved_sector100.bin` to plain hex via `xxd`

```bash
$ xxd -ps carved_sector100.bin >  hex.txt
$ cat hex.txt 84f7e4b54e5a5a5a5a5a4e7d1c07ca22a1f1775a5a5a775a5a5a495a5a5a
293f39283f2e053f2c333e3f34393f742e222e1c161b1d213b342e33053c
35283f342933392905283f33373b3d3f0539352c3f2805292e3528230568
6a686c270a115b584e594e5a5a5a5a5a4e7d1c07ca22a1f1775a5a5a775a
5a5a495a5a5a5a5a5a5a5a5a5a5ada5b5a5a5a5a293f39283f2e053f2c33
3e3f34393f742e222e0a115f5c5a5a5a5a5b5a5b5a1b5a5a5a045a5a5a5a
a0000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000
```

**Mathematical Header Verification**

$$\text{Raw Encrypted Bytes: } 84 \text{ } F7 \text{ } E4 \text{ } B5$$
$$84 \oplus 5\text{A} = \text{DE}, \quad F7 \oplus 5\text{A} = \text{AD}, \quad E4 \oplus 5\text{A} = \text{BE}, \quad B5 \oplus 5\text{A} = \text{EF}$$

Applying key `0x5A` restores the corrupted magic header `DE AD BE EF`

---

## 6. Decryption & Evidence Recovery

A Python inline script was executed to read `hex.txt`, convert hex string representations back into binary bytes, and apply single-byte XOR key `0x5A`

```bash
$ python3 -c '
key = 0x5A
raw_hex = open("hex.txt").read().replace("\n", "").replace(" ", "")
data = bytes.fromhex(raw_hex)
decrypted = bytes([b ^ key for b in data])
print(decrypted)
'
b"\xde\xad\xbe\xef\x14\x00\x00\x00\x00\x00\x14'F]\x90x\xfb\xab-\x00\x00\x00-\x00\x00\x00\x13\x00\x00\x00secret_evidence.txtFLAG{anti_forensics_reimage_cover_story_2026}PK\x01\x02\x14\x03\x14\x00\x00\x00\x00\x00\x14'F]\x90x\xfb\xab-\x00\x00\x00-\x00\x00\x00\x13\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x01\x00\x00\x00\x00secret_evidence.txtPK\x05\x06\x00\x00\x00\x00\x01\x00\x01\x00A\x00\x00\x00^\x00\x00\x00\x00\x00ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
```

### Evidence Flag

`FLAG{anti_forensics_reimage_cover_story_2026}`

---

## 7. Forensic Artifact Summary

- **Evidence Location:** Physical Unallocated Sector 100 (`/dev/sdb` offset `0x0000C800` / $51,200 \text{ bytes}$).
- **Obfuscation Scheme:** Single-byte XOR (`0x5A`) + Zip Magic Header Alteration (`0xDEADBEEF`).
- **Embedded Payload:*- Zip Archive containing `secret_evidence.txt`.
- **Recovered Flag:*- `FLAG{anti_forensics_reimage_cover_story_2026}`.
