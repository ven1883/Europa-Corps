# cd "Tools/replacer"
echo FUCK!

for file in subs/**.sub; do
    [ -f "$file" ] || continue
	file=$(basename "$file")
	filenoext=$(basename -- "$file" .sub)

    echo "Processing $file"
	echo "No Extension Name: $filenoext"

	#copy the file and rename it to an archive
	cp "subs/$file" output/
	mv "output/$file" "output/${file%.sub}.gzip"

	#extract and rename to XML
	7z e -y "output/$filenoext.gzip" -ooutput/
	echo FUCKING DO YOUR FUCKING JOB YOU CUNT FUCK
	mv "output/$filenoext" "output/$filenoext.xml" # ease of reading

	# some fucking bullshit here to find and repalce the identifiers
	# 1. Parse the "->", trim whitespace, and format into sed syntax
	sed_script=$(awk -F '[[:space:]]*->[[:space:]]*' '$1!="" && $2!="" {print "s/\\<" $1 "\\>/" $2 "/g"}' changes.txt)

	# 2. Execute all replacements in a single pass
	sed -i "$sed_script" "output/$filenoext.xml"

	# <!---!>

	# reassemble the archive and spit it out.
	mv "output/$filenoext.xml" "output/$filenoext" #same as stock baro for better compat
	7z a -y -tgzip -mx9 "output/$filenoext.sub" "output/$filenoext"

done
