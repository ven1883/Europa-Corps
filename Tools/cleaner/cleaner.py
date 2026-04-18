import os
import re
from lxml import etree

# Paths
SRC_ROOT = os.path.join("Tools", "cleaner", "src")
LANG_FILE = os.path.join("Tools", "cleaner", "tar", "langfile.xml")
OUT_FILE = os.path.join("Tools", "cleaner", "tmp", "organized_langfile.xml")

# Regex to match lang entries
NAME_RE = re.compile(r'<entityname\.([a-zA-Z0-9_]+)>(.*?)</entityname\.\1>', re.DOTALL)
DESC_RE = re.compile(r'<entitydescription\.([a-zA-Z0-9_]+)>(.*?)</entitydescription\.\1>', re.DOTALL)

# 1. Read the lang file
with open(LANG_FILE, encoding="utf-8") as f:
    lang_text = f.read()

lang_names = dict(NAME_RE.findall(lang_text))
lang_descs = dict(DESC_RE.findall(lang_text))

missing_names = []
missing_descs = []
organized = {}

def collect_items_from_file(foldername, filename, filepath):
    with open(filepath, encoding="utf-8") as f:
        raw = f.read()
    try:
        parser = etree.XMLParser(remove_blank_text=False, recover=True)
        tree = etree.fromstring(raw.encode("utf-8"), parser=parser)
    except Exception as e:
        print(f"[ERROR] Failed to parse: {filepath}\nReason: {e}")
        return []

    items = []
    current_category = None
    for elem in tree.iter():
        if isinstance(elem, etree._Comment):
            content = elem.text.strip()
            if not content.startswith("+++") and content:
                current_category = content
        elif elem.tag == "Item":
            ident = elem.get("identifier")
            if not ident:
                continue
            if ident not in lang_names:
                missing_names.append(ident)
            if ident not in lang_descs:
                missing_descs.append(ident)
            items.append((current_category, ident))
    return items

# Walk all folders in SRC_ROOT
for subfolder in os.listdir(SRC_ROOT):
    subpath = os.path.join(SRC_ROOT, subfolder)
    if not os.path.isdir(subpath):
        continue
    for filename in os.listdir(subpath):
        if not filename.endswith(".xml"):
            continue
        filepath = os.path.join(subpath, filename)
        items = collect_items_from_file(subfolder, filename, filepath)
        group_key = f"{subfolder}_{os.path.splitext(filename)[0]}"
        for category, ident in items:
            folder_group = organized.setdefault(group_key, {})
            cat_group = folder_group.setdefault(category or "Uncategorized", [])
            if ident not in [i[0] for i in cat_group]:
                cat_group.append((ident, lang_names.get(ident, None), lang_descs.get(ident, None)))

# 3. Write the output
os.makedirs(os.path.dirname(OUT_FILE), exist_ok=True)
with open(OUT_FILE, "w", encoding="utf-8", newline="\n") as f:
    f.write('<?xml version="1.0" encoding="utf-8"?>\n')
    f.write('<infotexts language="English">\n')
    for group, cats in organized.items():
        f.write(f'    <!--{group}-->\n')
        for cat, items in cats.items():
            f.write(f'        <!--{cat}-->\n')
            for ident, name, desc in items:
                if name:
                    f.write(f'            <entityname.{ident}>{name}</entityname.{ident}>\n')
                if desc:
                    f.write(f'            <entitydescription.{ident}>{desc}</entitydescription.{ident}>\n')
    f.write('</infotexts>\n')

# Print errors if any
if missing_names or missing_descs:
    print("[WARNING] Missing language entries:")
    for ident in sorted(set(missing_names)):
        print(f" - Missing name: {ident}")
    for ident in sorted(set(missing_descs)):
        print(f" - Missing description: {ident}")
else:
    print("All identifiers have associated names and descriptions.")

print(f"Organized langfile written to {OUT_FILE}")
