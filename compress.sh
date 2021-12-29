#!/bin/bash
#SBATCH --account=bioinfo_serv
#SBATCH --partition=fastbioinfo
#SBATCH --job-name=merge_vcf   #job name
##SBATCH --mail-type=END # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=gonzalo.n.moreno@gmail.com # Where to send mail        
#SBATCH --mem-per-cpu=5gb # Per processor memory
#SBATCH --cpus-per-task=2
#SBATCH -t 15:00:00     # Walltime
#SBATCH -o %j.out # Name output file 
#SBATCH --error=%j.err
##SBATCH --file=
##SBATCH --initaldir=


module load bedtools
module load miniconda/3.6
module load bcftools
module load gcc
module load plink
module load R/R
source ~/.Renviron
export PATH=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.282.b08-1.el7_9.x86_64/jre/bin/:$PATH



path_maf="/home/proyectos/bioinfo/fjd/MAF_FJD_v3.0"


vcfin="$1"
#basename="$(basename ${vcfin})"
echo $vcfin
#echo $basename

#bgzip -c ${vcfin} > ${path_maf}/individual_vcf/compress_vcf/${basename}.gz
#tabix -p vcf ${path_maf}/individual_vcf/compress_vcf/${basename}.gz
 
#for file in /home/proyectos/bioinfo/fjd/MAF_FJD_v3.0/individual_vcf/copia_new_vcf_compress/*vcf.gz ; do sbatch --account=bioinfo_serv --partition=bioinfo /home/proyectos/bioinfo/fjd/MAF_FJD_v3.0/scripts/compress.sh ${file} ; done



sample="$(bcftools query -l ${vcfin})"
echo $sample
new_sample="$(echo $sample | sed 's/-/_/2' | sed 's/_.*//g' | sed 's/[a-z]//g')"
echo $new_sample
echo $new_sample > ${path_maf}/individual_vcf/log_files/new_sample_${sample}.txt

#bcftools reheader -s ${path_maf}/individual_vcf/log_files/new_sample_${sample}.txt ${vcfin} | bgzip -c > ${path_maf}/individual_vcf/new_vcf/${new_sample}.final.vcf.gz
bcftools reheader -s ${path_maf}/individual_vcf/log_files/new_sample_${sample}.txt ${vcfin} > ${path_maf}/individual_vcf/new_vcf/${new_sample}.final.vcf.gz

tabix -p vcf ${path_maf}/individual_vcf/new_vcf/${new_sample}.final.vcf.gz

rm ${path_maf}/individual_vcf/log_files/new_sample_${sample}.txt

