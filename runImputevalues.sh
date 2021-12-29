#!/bin/sh

##SBATCH --account=bioinfo_serv
##SBATCH --partition=bioinfo
##SBATCH --job-name=impute
##SBATCH --mail-type=FAIL # Mail events (NONE, BEGIN, END, FAIL, ALL)
##SBATCH --mail-user=gonzalo.n.moreno@gmail.com # Where to send mail
##SBATCH --mem-per-cpu=60gb
##SBATCH --cpus-per-task=2
##SBATCH -t 15:00:00     # Walltime
##SBATCH -o %j_impute.out # Name output file 
##SBATCH --error=%j_impute.err

path_maf=/home/proyectos/bioinfo/NOBACKUP/MAF_FJD_v3.0

module load R/R
source ~/.Renviron

sbatch --account=bioinfo_serv \
--partition=bioinfo \
--job-name=impute2 \
--mem-per-cpu=120gb \
--cpus-per-task=1 \
-o impute2.out \
--error=impute2.err \
R CMD BATCH --no-restore --no-save ${path_maf}/scripts/imputeValues_prueba.R


