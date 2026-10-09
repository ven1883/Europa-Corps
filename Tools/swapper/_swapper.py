import os
import re
import difflib
import xml.etree.ElementTree as ET

SRC_DIR = "Text\\swapper\\src"
TAR_DIR = "Text\\swapper\\tar"
OUT_DIR = "Text\\swapper\\tmp"
DIFF_SUFFIX = ".diff.txt"
PREVIEW_MODE = True	# Set to False to remove previews

def get_tag_text_dict(xml_path):
		"""Parses an XML file and returns a dict of {tag: text}."""
		tree = ET.parse(xml_path)
		root = tree.getroot()
		return {elem.tag: elem.text for elem in root}

def patch_xml_content(original_content, replacements):
		"""Replace tag content while preserving comments and formatting."""
		def replace_tag(match):
				tag = match.group(1)
				original_text = match.group(2)
				if tag in replacements:
						new_text = replacements[tag]
						if new_text != original_text:
								return f"<{tag}>{new_text}</{tag}>"
				return match.group(0)

		# Replace all matching tags using regex
		return re.sub(r"<(\S+?)>(.*?)</\1>", replace_tag, original_content, flags=re.DOTALL)

def normalize_formatting(text):
		"""Normalize to LF line endings and tabs (tab size = 4)."""
		text = text.replace('\r\n', '\n').replace('\r', '\n')	# Line endings to LF
		# Convert 4-space indents to tabs
		text = re.sub(r'^( {4})+', lambda m: '\t' * (len(m.group(0)) // 4), text, flags=re.MULTILINE)
		return text

def generate_diff(original, modified, filename):
		"""Return a unified diff string."""
		original_lines = original.splitlines(keepends=True)
		modified_lines = modified.splitlines(keepends=True)
		diff = difflib.unified_diff(
				original_lines,
				modified_lines,
				fromfile=f"a/{filename}",
				tofile=f"b/{filename}",
				lineterm=""
		)
		return ''.join(diff)

def preview_changes(tar_file, original_content, modified_content):
		"""Preview changes with a diff output."""
		print(f"\nChanges for {tar_file}:")
		diff_text = generate_diff(original_content, modified_content, tar_file)
		print(diff_text)

def process_all_files():
		os.makedirs(OUT_DIR, exist_ok=True)

		# Load all patch data from src/
		patch_dict = {}
		for src_file in os.listdir(SRC_DIR):
				if src_file.lower().endswith('.xml'):
						patch_dict.update(get_tag_text_dict(os.path.join(SRC_DIR, src_file)))

		for tar_file in os.listdir(TAR_DIR):
				if tar_file.lower().endswith('.xml'):
						tar_path = os.path.join(TAR_DIR, tar_file)
						out_path = os.path.join(OUT_DIR, os.path.basename(tar_file))
						diff_name = os.path.basename(tar_file) + DIFF_SUFFIX
						diff_path = os.path.join(OUT_DIR, diff_name)

						with open(tar_path, 'r', encoding='utf-8') as f:
								original_content = f.read()

						# Normalize formatting before editing
						original_normalized = normalize_formatting(original_content)
						modified_content = patch_xml_content(original_normalized, patch_dict)
						modified_normalized = normalize_formatting(modified_content)

						# If true, preview changes and ask for confirmation
						if PREVIEW_MODE:
								preview_changes(tar_file, original_normalized, modified_normalized)
								user_input = input(f"Do you want to apply these changes to {tar_file}? (y/n): ").lower()
								if user_input != 'y':
										print(f"• Skipping {tar_file}")
										continue

						# Save the modified file
						with open(out_path, 'w', encoding='utf-8', newline='\n') as f:
								f.write(modified_normalized)

						# Generate and save diff if needed
						if original_normalized != modified_normalized:
								diff_text = generate_diff(original_normalized, modified_normalized, tar_file)
								with open(diff_path, 'w', encoding='utf-8', newline='\n') as f:
										f.write(diff_text)
								print(f"✓ Patched: {tar_file}	→	Saved to: {out_path}")
								print(f"↪ Diff saved to: {diff_path}")
						else:
								print(f"• No changes for {tar_file}")

if __name__ == "__main__":
		process_all_files()
