#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then 
    echo "Deux arguments attendus : <dossier> <langue>"
    exit 1
fi

folder=$1  # dump-text 	ou contextes
basename=$2  # all_rus, all_fr, ironie_rus, sarcasme_rus, ironie_fr, sarcasme_fr
lineno=1

echo "<lang=\"$basename\">" > "./itrameur/$folder-$basename.txt"

# Pour les contextes/dump_text russes
export LC_ALL=ru_RU.UTF-8

# Pour les contextes/dump_text français
# export LC_ALL=fr_FR.UTF-8

for filepath in "$folder/$basename"*.txt; do
    pagename=$(basename "$filepath" .txt)
    
    echo "<page=\"$pagename\">" >> "./itrameur/$folder-$basename.txt"
    echo "<text>" >> "./itrameur/$folder-$basename.txt"
    
    encoding=$(uchardet "$filepath")
    
    if [[ "$encoding" == "ISO-8859-7" ]]; then
        iconv -f ISO-8859-7 -t UTF-8//IGNORE "$filepath" -o "$filepath.utf8"
        filepath="$filepath.utf8" 
    fi
    
    content=$(iconv -f UTF-8 -t UTF-8//IGNORE "$filepath")
    
    content=$(echo "$content" | sed -e 's/&/\&amp;/g') 
    content=$(echo "$content" | sed -e 's/</\&lt;/g') 
    content=$(echo "$content" | sed -e 's/>/\&gt;/g') 
    
    echo "$content" >> "itrameur/$folder-$basename.txt"
    echo "</text>" >> "itrameur/$folder-$basename.txt"
    echo "</page> §" >> "itrameur/$folder-$basename.txt"
    
    lineno=$((lineno+1))
done

echo "</lang>" >> "./itrameur/$folder-$basename.txt"