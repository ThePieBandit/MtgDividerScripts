#!/bin/bash
set_file=${1:-"./set_order"}
symbol_file=${2:-"./mana_symbol_order_right"}
scad_file=${3:-"./CardBoxDivider.scad"}
output_dir=`pwd`/CardBoxDividerSTLs/BySet 

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
    echo Generating STLs for ${expansion[1]}...
    use_previous=true
	for symbol_line in $(cat $symbol_file)
	do
		IFS=':' read -ra symbol_array <<< "$symbol_line"
		if [ -z $prev_symbol ]
		then
            use_previous=false
        elif [ $use_previous = true ]
        then
            padded_counter=$(printf %06d "$counter")
            echo "Generating STLs for $padded_counter ${prev_expansion[1]}-${expansion[1]} : ${prev_symbol[0]} / ${symbol_array[0]}, clip_right=${symbol_array[2]}"
            openscad \
			-o "${output_dir}/${padded_counter}_${prev_expansion[1]}-${expansion[1]}_${prev_symbol[0]}-${symbol_array[0]}.stl" \
            -p CardBoxDivider.json -P CardCatalog \
			-D'back_set="'${expansion[0]}'"' \
			-D'front_set="'${prev_expansion[0]}'"' \
			-D'clip_right='${symbol_array[2]}'' \
			-D'front_symbol="'${prev_symbol[1]}'"' \
			-D'back_symbol="'${symbol_array[1]}'"' \
			$scad_file
            use_previous=false
        else
            padded_counter=$(printf %06d "$counter")
            echo "Generating STLs for $padded_counter ${expansion[1]} : ${prev_symbol[0]} / ${symbol_array[0]}, clip_right=${symbol_array[2]}"
            openscad \
			-o "${output_dir}/${padded_counter}_${expansion[1]}-${expansion[1]}_${prev_symbol[0]}-${symbol_array[0]}.stl" \
            -p CardBoxDivider.json -P CardCatalog \
			-D'back_set="'${expansion[0]}'"' \
			-D'front_set="'${expansion[0]}'"' \
			-D'clip_right='${symbol_array[2]}'' \
			-D'front_symbol="'${prev_symbol[1]}'"' \
			-D'back_symbol="'${symbol_array[1]}'"' \
			$scad_file
        fi
		prev_symbol[0]=${symbol_array[0]}
		prev_symbol[1]=${symbol_array[1]}
		prev_symbol[2]=${symbol_array[2]}
        counter=$(($counter+1))
	done
    prev_expansion[0]=${expansion[0]}
    prev_expansion[1]=${expansion[1]}
done < $set_file
