# DLL comparison tools

This folder contains a small utility to help analyze and compare two Windows
DLL/PE files and produce a JSON report helpful for finding differences and
indicators of packing/injection.

Files:
- compare_dlls.py: main analysis script (requires `pefile`)
- requirements.txt: Python dependency list

How to run:

1. Install dependencies (recommended in a virtualenv):

   python3 -m pip install -r scripts/requirements.txt

2. Run the analyzer comparing two files and save the JSON report:

   python3 scripts/compare_dlls.py --a MinoriPatch.dll --b MinoriPatch.dll.new --out report.json

3. Inspect `report.json` for:
   - hashes (sha256/md5)
   - imports/exports
   - extracted strings (sample)
   - detected common packer signatures (UPX/ASPack/etc)
   - suspicious APIs often used for DLL injection
   - PDB path (if embedded)

How this helps find the injector

- After you get the JSON report, pick a handful of distinctive strings from
  `b['strings_sample']` or the `pdb_path`/unique function names and search for
  them on GitHub (search code). That often locates an open-source injector or
  a loader that embeds the DLL.

- Look for reflective loader indicators (string "ReflectiveLoader") or the
  presence of remote-process APIs (WriteProcessMemory, CreateRemoteThread,
  VirtualAllocEx) in the import table of the injector/loader — these are
  strong hints about how the DLL was injected.

If you want, I can:
- Commit additional helpers (e.g., a script that extracts a short list of the
  most-unique strings suitable for searching on GitHub), or
- Run a GitHub code search for distinctive strings (if you want me to try,
  tell me which strings to search for or I can pick some from the generated
  report).
