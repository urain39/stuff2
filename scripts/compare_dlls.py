#!/usr/bin/env python3
"""
compare_dlls.py

Small utility to compare two Windows PE DLLs and extract helpful artifacts for
static analysis: hashes, imports, exports, sections, debug (PDB) path, strings,
and simple heuristics for packers / injection techniques.

Usage:
  python3 compare_dlls.py --a MinoriPatch.dll --b MinoriPatch.dll.new --out report.json

Output: JSON report with the collected data for both files and a summary diff.

Requires: pefile
Install: pip3 install pefile

This script is intended to be run locally in a safe environment. It does not
execute the DLLs.
"""

import argparse
import hashlib
import json
import os
import re
from collections import defaultdict

try:
    import pefile
except Exception as e:
    raise SystemExit("pefile is required. Install with: pip install pefile")

MIN_STR_LEN = 4
INJECTION_APIS = [
    "CreateRemoteThread",
    "CreateRemoteThreadEx",
    "WriteProcessMemory",
    "VirtualAllocEx",
    "VirtualProtectEx",
    "OpenProcess",
    "NtUnmapViewOfSection",
    "LoadLibraryA",
    "LoadLibraryW",
    "SetWindowsHookEx",
    "QueueUserAPC",
    "SetThreadContext",
    "ResumeThread",
]

PACKER_SIGS = [
    "UPX",
    "ASPack",
    "MEW",
    "Themida",
    "MPRESS",
    "PECompact",
]


def hash_file(path):
    h_sha256 = hashlib.sha256()
    h_md5 = hashlib.md5()
    with open(path, "rb") as f:
        while True:
            chunk = f.read(8192)
            if not chunk:
                break
            h_sha256.update(chunk)
            h_md5.update(chunk)
    return {"sha256": h_sha256.hexdigest(), "md5": h_md5.hexdigest()}


def extract_strings(path, min_len=MIN_STR_LEN):
    printable = set()
    with open(path, "rb") as f:
        data = f.read()
    # find ascii strings
    for s in re.findall(b"[ -~]{%d,}" % min_len, data):
        try:
            printable.add(s.decode("utf-8", errors="ignore"))
        except Exception:
            continue
    return sorted(printable)


def analyze_pe(path):
    r = {}
    r.update(hash_file(path))
    pe = pefile.PE(path, fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT'] if 'IMAGE_DIRECTORY_ENTRY_IMPORT' in pefile.DIRECTORY_ENTRY else 1])
    # Basic headers
    r["timestamp"] = getattr(pe.FILE_HEADER, 'TimeDateStamp', None)
    # Sections
    r["sections"] = [s.Name.decode(errors='ignore').rstrip('\x00') + (" (executable)" if s.Characteristics & 0x20000000 else "") for s in pe.sections]

    # Imports
    imports = defaultdict(list)
    try:
        for entry in pe.DIRECTORY_ENTRY_IMPORT:
            dll = entry.dll.decode(errors='ignore')
            for imp in entry.imports:
                name = imp.name.decode(errors='ignore') if imp.name else ("ordinal_%d" % imp.ordinal)
                imports[dll].append(name)
    except Exception:
        pass
    r["imports"] = imports

    # Exports
    exports = []
    try:
        if hasattr(pe, 'DIRECTORY_ENTRY_EXPORT'):
            for exp in pe.DIRECTORY_ENTRY_EXPORT.symbols:
                exports.append(exp.name.decode(errors='ignore') if exp.name else ("ordinal_%d" % exp.ordinal))
    except Exception:
        pass
    r["exports"] = exports

    # Debug / PDB
    pdb = None
    try:
        if hasattr(pe, 'DIRECTORY_ENTRY_DEBUG'):
            for dbg in pe.DIRECTORY_ENTRY_DEBUG:
                dbg_data = dbg.struct
                # For CodeView (type 2) the address of raw data points to CV info
                if dbg_data.Type == 2:
                    off = dbg_data.AddressOfRawData
                    # attempt to read a reasonably sized chunk
                    raw = pe.get_memory_mapped_image()[off:off + 512]
                    m = re.search(b"RSDS(.{16})(.+?)\x00", raw, re.DOTALL)
                    if m:
                        pdb = m.group(2).decode(errors='ignore')
    except Exception:
        pass
    r["pdb_path"] = pdb

    # Strings
    strs = extract_strings(path)
    r["strings_sample"] = strs[:200]

    # Heuristics
    r["suspicious_apis_present"] = [api for api in INJECTION_APIS if any(api in funcs for funcs in imports.values())]
    r["packer_signatures_found"] = [sig for sig in PACKER_SIGS if any(sig in s for s in strs[:2000])]
    r["has_upx_section"] = any(s for s in r["sections"] if "UPX" in s.upper())
    r["has_reflective_loader_string"] = any("ReflectiveLoader" in s or "Reflective" in s for s in strs[:2000])

    try:
        pe.close()
    except Exception:
        pass
    return r


def diff_reports(a, b):
    out = {}
    out['a_sha256'] = a.get('sha256')
    out['b_sha256'] = b.get('sha256')
    out['sha256_diff'] = a.get('sha256') != b.get('sha256')
    # imports diff: dll->functions
    import_keys = set(list(a.get('imports', {}).keys()) + list(b.get('imports', {}).keys()))
    imports_diff = {}
    for k in import_keys:
        a_funcs = set(a.get('imports', {}).get(k, []))
        b_funcs = set(b.get('imports', {}).get(k, []))
        if a_funcs != b_funcs:
            imports_diff[k] = {"only_in_a": sorted(list(a_funcs - b_funcs)), "only_in_b": sorted(list(b_funcs - a_funcs))}
    out['imports_diff'] = imports_diff
    # strings diff (top samples)
    a_strs = set(a.get('strings_sample', []))
    b_strs = set(b.get('strings_sample', []))
    out['strings_only_in_a'] = sorted(list(a_strs - b_strs))[:50]
    out['strings_only_in_b'] = sorted(list(b_strs - a_strs))[:50]
    out['suspicious_apis_in_a'] = a.get('suspicious_apis_present', [])
    out['suspicious_apis_in_b'] = b.get('suspicious_apis_present', [])
    out['pdb_a'] = a.get('pdb_path')
    out['pdb_b'] = b.get('pdb_path')
    out['packer_signs_a'] = a.get('packer_signatures_found')
    out['packer_signs_b'] = b.get('packer_signatures_found')
    out['has_upx_a'] = a.get('has_upx_section')
    out['has_upx_b'] = b.get('has_upx_section')
    out['has_reflective_loader_a'] = a.get('has_reflective_loader_string')
    out['has_reflective_loader_b'] = b.get('has_reflective_loader_string')
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--a", required=True, help="path to first dll")
    ap.add_argument("--b", required=True, help="path to second dll")
    ap.add_argument("--out", required=False, default=None, help="output json report file")
    args = ap.parse_args()

    if not os.path.exists(args.a) or not os.path.exists(args.b):
        raise SystemExit("Both files must exist")

    print("Analyzing", args.a)
    a = analyze_pe(args.a)
    print("Analyzing", args.b)
    b = analyze_pe(args.b)

    report = {"file_a": os.path.abspath(args.a), "file_b": os.path.abspath(args.b), "a": a, "b": b}
    report['diff'] = diff_reports(a, b)

    out_text = json.dumps(report, indent=2, ensure_ascii=False)
    if args.out:
        with open(args.out, 'w', encoding='utf-8') as f:
            f.write(out_text)
        print("Wrote report to", args.out)
    else:
        print(out_text)


if __name__ == '__main__':
    main()
