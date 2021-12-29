#!/bin/bash

imputed_vcf="/home/proyectos/bioinfo/NOBACKUP/MAF_FJD_v2.0/imputed_vcf"

module load miniconda/3.6

sbatch --account=bioinfo_serv \
--partition=bioinfo \
--job-name=changeFormat \
--mem-per-cpu=60gb --cpus-per-task=2 \
-t 15:00:00 -o %j_imputing.out \
--error=%j_imputing.err ./changeFormat.py \
--run date_16_03_21 --variants ${imputed_path}/merge_imputed_YYYYMMDD.vcf.gz

