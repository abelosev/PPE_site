#!/bin/bash

# Ce script analyse un fichier txt avec les URL's français ou russes de la directoire URL's 
# en entrée et génère un fichier HTML dans la directoire tableaux contenant un tableau 
# avec les informations sur le lien URL, le type d'encodage de la page et le nombre de 
# concordances pour un mot-clé spécifique dans le contenu de la page.

# Comment utiliser le script : 
# -a	Traitement du mot 'ironie' en français
# -b	Traitement du mot 'sarcasme' en français
# -c	Traitement des deux mots en français
# -d	Traitement du mot 'ironie' en russe
# -e	Traitement du mot 'sarcasme' en russe
# -f	Traitement des deux mots en russe

# Quelques exemples de l'utilisation : 
# ./traitement_url.sh -a ironie_fr.txt ironie_fr.html
# ./traitement_url.sh -f all_rus.txt all_rus.html

mot=""

while getopts ":abcdef" opt; do
    case $opt in
        a)
            mot="\b[iI]ronie[s]?\b"
            ;;
        b)
            mot="\b[sS]arcasme[s]?\b"
            ;;
        c)
            mot="\b([iI]ronie[s]?|[sS]arcasme[s]?)\b"
            ;;
        d)
            mot="\b(и|И)рони(и|я|ей|ю)\b"
            ;;
        e)
            mot="\b(с|С)арказм(а|е|у|ом)\b"
            ;;
        f)
            mot="\b((С|с)арказм(а|е|у|ом)|(и|И)рони(и|я|ей|ю))\b"
            ;;
        \?)
            echo "Option invalide: -$OPTARG" >&2
            usage
            ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -ne 2 ]]; then
    usage
fi

fichier_urls="$1"
fichier_tableau="$2"

basename=$(basename -s .txt $1)

echo "<html><body>" > ../tableaux/$2
echo "<h2>Tableau $basename :</h2>" >> ../tableaux/$2
echo "<br/>" >> ../tableaux/$2
echo "<table border=\"1\">" >> ../tableaux/$2
echo "<tr><th>ligne</th><th>code</th><th>URL</th><th>encodage</th><th>concordance</th></tr>" >> ../tableaux/$2

lineno=1;
while read -r URL; do
    echo -e "\tURL : $URL";
    code=$(curl -Ls -o /dev/null -w "%{http_code}" $URL)
    charset=$(curl -ILs -o /dev/null -w "%{content_type}" $URL | egrep -Eo "charset=(\w|-)+" | cut -d= -f2)

    aspiration=$(curl $URL > ../aspirations/$basename-$lineno.html)


    echo -e "\tcode : $code";

    if [[ ! $charset ]]
    then
        echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
        charset="UTF-8";
    else
        echo -e "\tencodage : $charset";
    fi

    if [[ $code -eq 200 ]]
        then
            dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
            if [[ $charset -ne "UTF-8" && -n "$dump" ]]
                then
                    dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE)
            fi
        else
            continue
    fi
    
    echo "$dump" > ../dumps_text/$basename-$lineno.txt
    
    fichierDump=../dumps_text/$basename-$lineno.txt
    
    compte=$(egrep $mot -wc $fichierDump)
    contexte=$(egrep -B 2 -A 2 $mot $fichierDump)
    echo "$contexte" >  ../contextes/$basename-$lineno.txt        
    
    echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td>$compte</td></tr>" >> ../tableaux/$2
    echo -e "\t--------------------------------"
    lineno=$((lineno+1));
    
done < ../URLs/$1
echo "</table>" >> ../tableaux/$2
echo "</body></html>" >> ../tableaux/$2