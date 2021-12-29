#!/bin/bash
#SBATCH --account=bioinfo_serv
#SBATCH --partition=bioinfo
#SBATCH --job-name=fastqc   #job name
#SBATCH --mail-type=END # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=ldelafuente.lorena@gmail.com # Where to send mail        
#SBATCH --mem-per-cpu=5gb # Per processor memory
#SBATCH --cpus-per-task=5
#SBATCH -t 15:00:00     # Walltime
#SBATCH -o %j_fastqc.out # Name output file 
#SBATCH --error=%j_fastqc.err
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


SUBSTARTTIME=$(date +%s)



# for file in ${path_maf}/coverage/bedFiles/*.bed; 
# do 
# 	filename=$(basename ${file})
# 	sort -k1,1 -k2,2n ${file} > ${path_maf}/coverage/bedFiles/tmp.bed ; 
# 	bedtools merge -c 4 -o distinct -i ${path_maf}/coverage/bedFiles/tmp.bed > ${path_maf}/coverage/incorporated_bed/${filename}; 
# 	rm ${path_maf}/coverage/bedFiles/tmp.bed; 
# done

mkdir ${path_maf}/merged_vcf/date_2021_03_29/
mkdir ${path_maf}/imputed_vcf/date_2021_03_29/

lista_muestras_excluidas="${path_maf}/metadata/date_2021_03_17/lista_muestras_excluidas.tsv"

bcftools view -S ^${lista_muestras_excluidas} --min-ac=1 -O z -o ${path_maf}/merged_vcf/date_2021_03_29/merged_2021_03_29.vcf.gz ${path_maf}/merged_vcf/date_17_03_21/merge_total_20210209.vcf.gz
tabix -p vcf ${path_maf}/merged_vcf/date_2021_03_29/merged_2021_03_29.vcf.gz

bcftools view -S ^${lista_muestras_excluidas} --min-ac=1 -O z -o ${path_maf}/imputed_vcf/date_2021_03_29/merged_2021_03_29.vcf.gz ${path_maf}/imputed_vcf/date_17_03_21/merge_imputed_20210209_71samplesFiltered.vcf.gz
tabix -p vcf ${path_maf}/imputed_vcf/date_2021_03_29/merged_2021_03_29.vcf.gz


SUBENDTIME=$(date +%s)
echo "	Running time: $(($SUBENDTIME - $SUBSTARTTIME)) seconds" 



