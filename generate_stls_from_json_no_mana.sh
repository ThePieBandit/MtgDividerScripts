#!/bin/bash
set_file=${1:-"./set_order"}
symbol_file=${2:-"./mana_symbol_order_right"}
scad_file=${3:-"./CardBoxDivider.scad"}
output_dir=`pwd`/CardBoxDividerSTLs/NoMana

mkdir -p ${output_dir}

echo scad_file=${scad_file}
echo symbol_file=${symbol_file}
echo set_file=${set_file}
echo output_dir=${output_dir}

prev_expansion=""
prev_symbol=""
counter=0
padded_counter=$(printf %06d "$counter")
while IFS='' read -r expansion_line || [[ -n "$expansion_line" ]]
do
    echo
    IFS=' ' read -ra expansion <<< "$expansion_line"
    
    if [ -z $prev_expansion ]
    then
        echo 
    else
        padded_counter=$(printf %06d "$counter")
        echo "Generating STLs for ${prev_expansion[1]} / ${expansion[1]}, clip_right=true"
        openscad \
        -o "${output_dir}/${padded_counter}_${prev_expansion[1]}-${expansion[1]}.stl" \
        -p CardBoxDivider.json -P CardCatalog \
        -D'back_set="'${expansion[0]}'"' \
        -D'front_set="'${prev_expansion[0]}'"' \
        -D'clip_right='true'' \
        -D'front_symbol="''"' \
        -D'back_symbol="''"' \
        $scad_file
    fi
    prev_expansion[0]=${expansion[0]}
    prev_expansion[1]=${expansion[1]}
    counter=$(($counter+1))
done < $set_file
