import os
import glob
import cv2
import xml.etree.ElementTree as ET

# --- CONFIGURATION ---
# Directory containing old sprite sheets (PNG files)
SRC_DIR = 'Tools\\ripper\\src'
# Directory containing XML data files with sourcerect definitions
XML_DIR = 'Tools\\ripper\\tar'
# Output directory for ripped sprites
OUT_DIR = 'Tools\\ripper\\tmp'

# Ensure the output directory exists
os.makedirs(OUT_DIR, exist_ok=True)

# Iterate through all XML files in the TAR directory (recursively)
xml_paths = glob.glob(os.path.join(XML_DIR, '**', '*.xml'), recursive=True)
for xml_path in xml_paths:
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Process each <Item> by identifier
    for item in root.findall('.//Item[@identifier]'):
        identifier = item.get('identifier')

        # For each Sprite or InventoryIcon within this Item
        for tag in ('Sprite', 'InventoryIcon'):
            for elem in item.findall(f'.//{tag}'):
                texture = elem.get('texture')
                sheet_name = os.path.basename(texture)
                src_path = os.path.join(SRC_DIR, sheet_name)
                if not os.path.exists(src_path):
                    print(f"[!] Missing sprite sheet: {src_path}")
                    continue

                # Load the sprite sheet image
                sheet = cv2.imread(src_path, cv2.IMREAD_UNCHANGED)
                if sheet is None:
                    print(f"[!] Failed to load image: {src_path}")
                    continue

                # Parse the sourcerect: x, y, width, height
                try:
                    sx, sy, sw, sh = map(int, elem.get('sourcerect').split(','))
                except Exception as e:
                    print(f"[!] Invalid sourcerect in {xml_path}: {e}")
                    continue

                # Crop the sprite
                sprite_img = sheet[sy:sy+sh, sx:sx+sw]

                # Build and save the output filename
                tag_lower = tag.lower()
                out_name = f"{identifier}_{tag_lower}_{sx}_{sy}.png"
                out_path = os.path.join(OUT_DIR, out_name)
                cv2.imwrite(out_path, sprite_img)

print(f"All sprites ripped to: {OUT_DIR}")
