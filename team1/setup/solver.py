import zipfile, os

# Read carved raw sector data
with open("carved_sector100.bin", "rb") as f:
    raw = f.read()

# 1. Reverse XOR Key 0x5A
decrypted = bytearray([b ^ 0x5A for b in raw])

print(f"[*] Corrupted Header (Hex): {decrypted[:4].hex().upper()}")

# 2. Repair Magic Bytes (0xDEADBEEF -> PK\x03\x04 / 0x504B0304)
decrypted[0:4] = b"\x50\x4B\x03\x04"

# 3. Save repaired archive
with open("repaired_evidence.zip", "wb") as f:
    f.write(decrypted)

# 4. Extract Zip
try:
    with zipfile.ZipFile("repaired_evidence.zip", "r") as z:
        z.extractall("unpacked_evidence")
        print("[+] SUCCESS! Flag recovered:")
        with open("unpacked_evidence/secret_evidence.txt", "r") as flag_file:
            print("    " + flag_file.read())
except Exception as e:
    print(f"[-] Decryption failed: {e}")

# Cleanup test files
os.remove("carved_sector100.bin")
os.remove("repaired_evidence.zip")
