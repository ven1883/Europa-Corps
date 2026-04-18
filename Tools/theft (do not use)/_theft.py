import os
import re
import difflib

# Directories (adjust if needed)
SRC_DIR = "Tools\\theft\\src"
TAR_DIR = "Tools\\theft\\tar"
OUT_DIR = "Tools\\theft\\tmp"
MISSING_FILE = os.path.join(OUT_DIR, "MISSING.txt")
DIFF_SUFFIX = ".diff.txt"
DRY_RUN = True

# Regular expression to match an entire <Item ...>...</Item> block
#   - Captures the indentation (if any) of the opening tag
#   - Captures the attributes of the opening tag
#   - Captures the inner content (including newlines) between the tags
#   - Uses re.MULTILINE and re.DOTALL so that ^ matches start-of-line and . matches newlines.
ITEM_BLOCK_REGEX = re.compile(
	r'^(?P<indent>[ \t]*)<Item(?P<attrs>[^>]*)>(?P<inner>.*?)</Item>',
	re.MULTILINE | re.DOTALL
)

# Regex to extract the identifier attribute from the opening tag
IDENTIFIER_REGEX = re.compile(r'identifier="([^"]+)"')

# Regex to remove Fabricate and Deconstruct components (non-greedy, DOTALL)
REMOVE_COMPONENTS_REGEX = re.compile(
	r'<(?:Fabricate|Deconstruct)\b.*?</(?:Fabricate|Deconstruct)>',
	re.DOTALL
)

def normalize_whitespace(text):
	"""Strip leading/trailing whitespace and replace runs of whitespace with a single space."""
	return re.sub(r'\s+', ' ', text.strip())

def reindent(text, indent):
	"""Re-indent every non-empty line of text with the provided indent."""
	lines = text.splitlines()
	reindented = "\n".join(indent + line if line.strip() != "" else "" for line in lines)
	return reindented

def extract_items_from_src():
	"""
	Walk through all files in SRC_DIR, extract each <Item> block and its inner XML,
	strip out Fabricate and Deconstruct components, and return a dict:
	   { identifier: inner_xml (str) }.
	"""
	items = {}
	for fname in os.listdir(SRC_DIR):
		if not fname.endswith(".xml"):
			continue
		src_path = os.path.join(SRC_DIR, fname)
		try:
			with open(src_path, 'r', encoding='utf-8') as f:
				content = f.read()
		except Exception as e:
			print(f"[ERROR] Reading {src_path}: {e}")
			continue

		for match in ITEM_BLOCK_REGEX.finditer(content):
			attrs = match.group("attrs")
			inner = match.group("inner")
			ident_match = IDENTIFIER_REGEX.search(attrs)
			if ident_match:
				ident = ident_match.group(1)
				# Remove Fabricate and Deconstruct components from inner content
				cleaned_inner = REMOVE_COMPONENTS_REGEX.sub('', inner).strip()
				# Normalize whitespace for later comparison
				items[ident] = cleaned_inner
	return items

def update_tar_file(tar_path, src_items, used_ids):
	"""
	Read the tar file as raw text, find all <Item> blocks,
	and replace the inner content with that from src if:
	  - An src item with the same identifier exists, and
	  - The normalized inner content is different.
	Returns a tuple: (original_text, modified_text, changed_flag)
	"""
	try:
		with open(tar_path, 'r', encoding='utf-8') as f:
			original = f.read()
	except Exception as e:
		print(f"[ERROR] Reading {tar_path}: {e}")
		return "", "", False

	modified = original

	def replacer(match):
		nonlocal modified
		item_indent = match.group("indent")
		attrs = match.group("attrs")
		inner = match.group("inner")
		id_match = IDENTIFIER_REGEX.search(attrs)
		if not id_match:
			return match.group(0)
		ident = id_match.group(1)
		if ident not in src_items:
			return match.group(0)
		used_ids.add(ident)
		tar_inner_norm = normalize_whitespace(inner)
		src_inner = src_items[ident]
		src_inner_norm = normalize_whitespace(src_inner)
		# If there is no difference, leave unchanged.
		if tar_inner_norm == src_inner_norm:
			return match.group(0)
		# Otherwise, build the new inner content:
		# Re-indent src inner content with one level deeper than the original <Item> tag.
		new_indent = item_indent + "\t"  # use one tab more
		new_inner = reindent(src_inner, new_indent)
		# Reassemble the full <Item> block, preserving the original opening tag and closing tag.
		updated_block = f"{item_indent}<Item{attrs}>{os.linesep}{new_inner}{os.linesep}{item_indent}</Item>"
		return updated_block

	modified = ITEM_BLOCK_REGEX.sub(replacer, original)

	# Normalize overall formatting (LF line endings, ensure tabs used consistently)
	modified = modified.replace('\r\n', '\n').replace('\r', '\n')
	modified = reindent(modified, "")  # reapply our tab-normalizer (note: may not be perfect)

	# Decide if any change was made by comparing normalized version.
	changed = normalize_whitespace(original) != normalize_whitespace(modified)
	return original, modified, changed

def generate_diff(original, modified, filename):
	return ''.join(difflib.unified_diff(
		original.splitlines(keepends=True),
		modified.splitlines(keepends=True),
		fromfile=f"a/{filename}",
		tofile=f"b/{filename}",
		lineterm=""
	))

def main():
	global DRY_RUN
	print("[INFO] Extracting source items...")
	src_items = extract_items_from_src()
	used_ids = set()
	os.makedirs(OUT_DIR, exist_ok=True)

	tar_files = [f for f in os.listdir(TAR_DIR) if f.endswith(".xml")]

	for fname in tar_files:
		tar_path = os.path.join(TAR_DIR, fname)
		out_path = os.path.join(OUT_DIR, fname)
		print(f"[PROCESSING] {fname}")
		original, modified, changed = update_tar_file(tar_path, src_items, used_ids)

		if changed:
			diff = generate_diff(original, modified, fname)
			# Save diff file
			diff_file = out_path + DIFF_SUFFIX
			with open(diff_file, 'w', encoding='utf-8', newline='\n') as df:
				df.write(diff)
			if DRY_RUN:
				print(f"\n[DRY-RUN] Would update {fname} with diff:\n{diff[:800]}")
			else:
				with open(out_path, 'w', encoding='utf-8', newline='\n') as outf:
					outf.write(modified)
				print(f"[UPDATED] {fname} written to {out_path}")
		else:
			print(f"[SKIP] No changes needed in {fname}")

	# Identify src items not used in any tar file.
	missing_ids = sorted(set(src_items.keys()) - used_ids)
	if missing_ids:
		with open(MISSING_FILE, 'w', encoding='utf-8', newline='\n') as mf:
			for ident in missing_ids:
				mf.write(f"{ident}\n")
		print(f"[INFO] Wrote {len(missing_ids)} missing identifiers to {MISSING_FILE}")

	if DRY_RUN:
		confirm = input("\n[DRY-RUN] Apply changes? (y/N): ").strip().lower()
		if confirm == "y":
			DRY_RUN = False
			main()

if __name__ == "__main__":
	main()
