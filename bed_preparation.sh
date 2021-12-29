#!/bin/bash




#bedin="$1"

for bedin in /home/proyectos/bioinfo/fjd/MAF_FJD_v3.0/coverage/new_bed/*
do

#echo $bedin


sample="$(basename $bedin)"
#echo $sample
new_sample="$(echo $sample | sed 's/-/_/2' | sed 's/_.*//g' | sed 's/[a-z]//g' | sed 's/\..*//g')"
#echo $new_sample


cp ${bedin} ${path_maf}/coverage/new_bed_modified/${new_sample}_padding.quantized.bed

done
