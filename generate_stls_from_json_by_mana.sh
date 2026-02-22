#!/bin/bash
set_file=${1:-"./set_order"}
symbol_file=${2:-"./mana_symbol_order_right"}
scad_file=${3:-"./CardBoxDivider.scad"}
output_dir=`pwd`/CardBoxDividerSTLs/ByMana

mkdir -p ${output_dir}

echo scad_file=${scad_file}
echo symbol_file=${symbol_file}
echo set_file=${set_file}
echo output_dir=${output_dir}

prev_expansion=""
prev_symbol=""
counter=0
padded_counter=$(printf %06d "$counter")
for symbol_line in $(cat $symbol_file)
do
    IFS=':' read -ra symbol_array <<< "$symbol_line"
    prev_expansion=""
    while IFS='' read -r expansion_line || [[ -n "$expansion_line" ]]
    do
        IFS=' ' read -ra expansion <<< "$expansion_line"
        
        # TODO clean up
        case ${symbol_array[0]} in
            M)
                skip_test=$(jq -e '.data."'${expansion[1]}'".cards? | any(.colors? | length > 1)' AllPrintings.json)
                ;;
            C) # Fix
                skip_test=$(jq -e '.data."'${expansion[1]}'".cards? | any(.colors? | length == 0)' AllPrintings.json)
                ;;
            L) # Fix
                skip_test=$(jq -e '.data."'${expansion[1]}'".cards? | any(.colors? | length == 0)' AllPrintings.json)
                ;;
            *)
                skip_test=$(jq -e '.data."'${expansion[1]}'".cards? | any(.colors == ["'${symbol_array[0]}'"])' AllPrintings.json)
                ;;
        esac
        if ! $skip_test
        then
            echo Skipping ${expansion[1]}
            continue
        fi
        
        if [ -z "$prev_expansion" ]
        then
            echo Generating STLs for ${symbol_array[0]}...
        else
            padded_counter=$(printf %06d "$counter")
            echo "Generating STLs for $padded_counter ${symbol_array[0]} : ${prev_expansion[1]} / ${expansion[1]}, clip_right=${symbol_array[2]}"
            set -x
            openscad \
            -o "${output_dir}/${padded_counter}_${symbol_array[0]}_${prev_expansion[1]}-${expansion[1]}.stl" \
            -p CardBoxDivider.json -P CardCatalog \
            -D'back_set="'${expansion[0]}'"' \
            -D'front_set="'${prev_expansion[0]}'"' \
            -D'clip_right='${symbol_array[2]}'' \
            -D'front_symbol="'${symbol_array[1]}'"' \
            -D'back_symbol="'${symbol_array[1]}'"' \
            $scad_file
            set +x
        fi
        prev_expansion[0]=${expansion[0]}
        prev_expansion[1]=${expansion[1]}
        counter=$(($counter+1))
    done < $set_file
done
