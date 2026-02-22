#!/bin/bash
prev_expansion=${1}
next_expansion=${2}
prev_symbol=${3}
next_symbol=${4}
set_file=${5:-"AllSets.input"}
symbol_file=${6:-"../mana_symbol_order_right"}
scad_file=${7:-"../CardBoxDivider.scad"}
output_dir=`pwd`/CardBoxDividerSTLs

mkdir -p ${output_dir}

echo scad_file=${scad_file}
echo symbol_file=${symbol_file}
echo set_file=${set_file}
echo output_dir=${output_dir}

stl_file=${output_dir}/${prev_expansion}-${next_expansion}_${prev_symbol}-${next_symbol}.stl
prev_expansion=$(grep ${prev_expansion} ${set_file} | cut -f 1 -d' ')
next_expansion=$(grep ${next_expansion} ${set_file} | cut -f 1 -d' ')
prev_symbol=$(grep ${prev_symbol} ${symbol_file} | cut -f 2 -d':')
next_symbol=$(grep ${next_symbol} ${symbol_file} | cut -f 2 -d':')

openscad \
-o "${stl_file}" \
-D'back_set="'${next_expansion}'"' \
-D'front_set="'${prev_expansion}'"' \
-D'clip_right='true'' \
-D'front_symbol="'${prev_symbol}'"' \
-D'back_symbol="'${next_symbol}'"' \
$scad_file
