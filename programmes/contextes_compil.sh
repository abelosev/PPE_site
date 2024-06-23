#!/bin/bash

prefixes=("ironie_rus" "sarcasme_rus" "all_rus" "ironie_fr" "sarcasme_fr" "all_fr")

for prefix in "${prefixes[@]}"
do
    output_file="../compil_contextes/compil_${prefix}.txt"
    > "$output_file"

    file_number=1
    while [ -f "../contextes/${prefix}-${file_number}.txt" ]
    do
        cat "../contextes/${prefix}-${file_number}.txt" >> "$output_file"
        file_number=$((file_number+1))
    done
done