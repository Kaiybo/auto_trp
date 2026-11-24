#!/usr/bin/env python3
"""Builds an installable zip: tools/out/AutoTRP-<version>.zip with the AutoTRP folder inside.

Usage: python3 tools/build_zip.py
Unzip into World of Warcraft/<your Forever folder>/Interface/AddOns/.
"""
import os, re, zipfile

root = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
addon = os.path.join(root, "AutoTRP")
toc = open(os.path.join(addon, "AutoTRP.toc"), encoding="utf-8").read()
version = re.search(r"^## Version:\s*(\S+)", toc, re.M).group(1)
out_dir = os.path.join(root, "tools", "out")
os.makedirs(out_dir, exist_ok=True)
dest = os.path.join(out_dir, "AutoTRP-%s.zip" % version)
with zipfile.ZipFile(dest, "w", zipfile.ZIP_DEFLATED) as z:
    for folder, _, files in os.walk(addon):
        for name in sorted(files):
            path = os.path.join(folder, name)
            z.write(path, os.path.relpath(path, root))
    for extra in ("README.md", "CHANGELOG.md", "LICENSE"):
        p = os.path.join(root, extra)
        if os.path.exists(p):
            z.write(p, os.path.join("AutoTRP", extra))
print(dest)
