#!/bin/bash



module load bedtools
module load miniconda/3.6
module load bcftools
module load gcc
module load plink
module load R/R
source ~/.Renviron
export PATH=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el7_9.x86_64/jre/bin/:$PATH


# path_maf="/home/gonzalo/Documents/prueba_MAF"
# path_maf="/home/gonzalo/Documents/MAF_FJD_v2.0"
# path_maf="/home/proyectos/bioinfo/NOBACKUP/MAF_FJD_v3.0_copia"
path_maf="/home/proyectos/bioinfo/fjd/MAF_FJD_v3.0"

#date_paste="$(date +"%Y_%m_%d")"
date_paste="2021_06_07"
date_dir="date_${date_paste}"

last_dir="$(ls ${path_maf}/merged_vcf/ | tail -n 1)"
# # #########last_merge="${path_maf}/merged_vcf/${last_dir}/*.vcf.gz"

#mymetadatapathology="${path_maf}/metadata/mymetadatapathology_20210315.txt"
mymetadatapathology="${path_maf}/metadata/${date_dir}/mymetadatapathology_${date_paste}.txt"
mymetadatapathology_uniq="${path_maf}/metadata/${date_dir}/mymetadatapathology_uniq_${date_paste}.txt"


mkdir "${path_maf}/metadata/${date_dir}"
mkdir "${path_maf}/tmp"
mkdir "${path_maf}/tmp/covFiles/"


echo "INICIO:" >> ${path_maf}/metadata/${date_dir}/logfile.txt
echo $(date) >> ${path_maf}/metadata/${date_dir}/logfile.txt
echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# Generar metadata
echo "METADATA GENERATION" >> ${path_maf}/metadata/${date_dir}/logfile.txt
STARTTIME=$(date +%s)

tag_group2="${path_maf}/metadata/TAG_GROUP2.xlsx"
tso="${path_maf}/metadata/Exoma Clínico_TSO y anterior.xls"
ces_1="${path_maf}/metadata/Exoma Clínico_CES55_CES122.xls"
ces_2="${path_maf}/metadata/Exoma Clínico_CES123_actual.xlsx"
otras_muestras="${path_maf}/metadata/otros_pacientes.tsv"
ces_investigacion="${path_maf}/metadata/ExomaClinico_CES_INV.xlsx"


Rscript ${path_maf}/scripts/metadatageneration.R \
"${tso}" \
"${ces_1}" \
"${ces_2}" \
"${otras_muestras}" \
"${tag_group2}" \
"${mymetadatapathology}" \
"${mymetadatapathology_uniq}" \
"${ces_investigacion}"

ENDTIME=$(date +%s)
echo "Running time: $(($ENDTIME - $STARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# # Filtro familia
# echo "FIRST FAMILY FILTER" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# STARTTIME=$(date +%s)

# for vcf in ${path_maf}/individual_vcf/incorporated_vcf/*.vcf.gz; do bcftools query -l ${vcf} >> ${path_maf}/metadata/${date_dir}/multisample.tsv ; done
# # #######bcftools query -l ${last_merge} > ${path_maf}/metadata/${date_dir}/multisample.tsv
# ls ${path_maf}/individual_vcf/new_vcf/*.vcf.gz | xargs -n 1 basename | sed 's/_.*$//' | sed 's/\..*$//' | sed 's/b$//' | sed 's/bis$//'> ${path_maf}/metadata/${date_dir}/indivsample.tsv

# # Exit pipeline if there are duplicate samples in the within the batch of samples that are going to be analyced
# if [[ $(sort "${path_maf}/metadata/${date_dir}/indivsample.tsv" | uniq -d | wc -l) > 0 ]]
# then
# 	echo "Duplicate samples in batch:"
# 	sort ${path_maf}/metadata/${date_dir}/indivsample.tsv | uniq -d
# 	echo "Please, manualy filter these duplicated samples."
# 	echo "Exit"
# 	exit 1
# fi


# python ${path_maf}/scripts/avoid_family.py \
# --multivcf ${path_maf}/metadata/${date_dir}/multisample.tsv \
# --singlevcf ${path_maf}/metadata/${date_dir}/indivsample.tsv \
# --family ${mymetadatapathology} \
# --output ${path_maf}/metadata/${date_dir}/avoid_samples.tsv \
# --dupout ${path_maf}/metadata/${date_dir}/dup_samples.tsv


# # Moving individual vcf and bed files from related samples to the discarded folders
# for i in $(cat ${path_maf}/metadata/${date_dir}/avoid_samples.tsv);
# do
# 	mv ${path_maf}/individual_vcf/new_vcf/${i}* ${path_maf}/individual_vcf/discarded_vcf/
# 	mv ${path_maf}/coverage/new_bed/${i}* ${path_maf}/coverage/discarded_bed/
# done


# ########### EN PROCESO ###########
# # Rename duplicate samples

# mkdir ${path_maf}/individual_vcf/tmp_vcf/
# cd ${path_maf}/individual_vcf/new_vcf/
# for i in $(cat ${path_maf}/metadata/${date_dir}/dup_samples.tsv);
# do
# 	vcffile="$(ls ${i}*gz)"
# 	tbifile="$(ls ${i}*tbi)"

# 	mv ${vcffile} ${tbifile} ../tmp_vcf/

# 	bcftools view ../tmp_vcf/${vcffile} | sed "s/${i}/dUpTaGgG${i}/g" | bgzip -c > dUpTaGgG${vcffile}
# 	tabix -p vcf dUpTaGgG${vcffile}

# done

# cd ${path_maf}/coverage/new_bed/
# for i in $(cat ${path_maf}/metadata/${date_dir}/dup_samples.tsv);
# do
# 	bedfile="$(ls ${i}*bed)"
# 	mv ${bedfile} dUpTaGgG${bedfile}
# done
# ########### EN PROCESO ###########

# ENDTIME=$(date +%s)
# echo "Running time: $(($ENDTIME - $STARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# # Merge
# echo "MERGE" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# STARTTIME=$(date +%s)

# # BCFTOOLS da error si hay muchos vcfs. Para prevenir el error he puesto como máximo 500 vcfs para hacer vcfs intermedios.
# ls ${path_maf}/individual_vcf/new_vcf/*.vcf.gz ${path_maf}/individual_vcf/incorporated_vcf/*.vcf.gz | split -l 850 - "${path_maf}/tmp/subset_vcfs_"

# for i in ${path_maf}/tmp/subset_vcfs_*
# do 
# 	iname="$(basename ${i})"

# 	bcftools merge -l ${i} -O z -o ${path_maf}/tmp/merge.${iname}.vcf.gz
# 	tabix -p vcf ${path_maf}/tmp/merge.${iname}.vcf.gz

# done

# bcftools merge -O z -o ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz ${path_maf}/tmp/merge.*.vcf.gz





# # # if [[ $(ls ${path_maf}/individual_vcf/new_vcf/*.vcf.gz | wc -l) -gt 850 ]]
# # # then
 	
# # # 	ls ${path_maf}/individual_vcf/new_vcf/*.vcf.gz | split -l 850 - "${path_maf}/tmp/subset_vcfs_"

# # # 	for i in ${path_maf}/tmp/subset_vcfs_*
# # # 	do 
# # # 		iname="$(basename ${i})"

# # # 		bcftools merge -l ${i} -O z -o ${path_maf}/tmp/merge.${iname}.vcf.gz
# # # 		tabix -p vcf ${path_maf}/tmp/merge.${iname}.vcf.gz

# # # 	done

# # # 	bcftools merge -O z -o ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz ${last_merge} ${path_maf}/tmp/merge.*.vcf.gz	

# # # # elif [[ $(ls ${path_maf}/individual_vcf/new_vcf/*.vcf.gz | wc -l) == 0 ]]
# # # # then
# # # # 	 cp ${last_merge} ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz

# # # else
	
# # # 	bcftools merge -O z -o ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz ${last_merge} ${path_maf}/individual_vcf/new_vcf/*vcf.gz
	
# # # fi

# ENDTIME=$(date +%s)
# echo "Running time: $(($ENDTIME - $STARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# # IMPUTATION
# echo "IMPUTATION" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# STARTTIME=$(date +%s)



# # Making a bedfile from the merged vcf so that bedtools will work faster (40 min per sample to 2 sec per sample)
# echo "	Making bed file" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# SUBSTARTTIME=$(date +%s)

# bcftools view ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz | grep -v '^#' | awk '{ print $1"\t"$2"\t"$2 }' > ${path_maf}/tmp/merged_variant_position.bed

# SUBENDTIME=$(date +%s)
# echo "	Running time: $(($SUBENDTIME - $SUBSTARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt



# # Make sure there are no overlaping regions so that coverage files have the same number of entries as variants in the merge vcf
# echo "	Remove overlapping regions in new bed files" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# SUBSTARTTIME=$(date +%s)

# for file in ${path_maf}/coverage/new_bed/*.bed; 
# do 
# 	sort -k1,1 -k2,2n ${file} > ${path_maf}/coverage/new_bed/tmp.bed ; 
# 	bedtools merge -c 4 -o distinct -i ${path_maf}/coverage/new_bed/tmp.bed > ${file}; 
# 	rm ${path_maf}/coverage/new_bed/tmp.bed; 
# done

# SUBENDTIME=$(date +%s)
# echo "	Running time: $(($SUBENDTIME - $SUBSTARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt



# # Making coverage files
# echo "	Making coverage files" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# SUBSTARTTIME=$(date +%s)

# # for file in $(ls ${path_maf}/coverage/new_bed/*.bed ${path_maf}/coverage/incorporated_bed/*.bed);
# # do 
# # 	filename="$(basename ${file})"
# # 	bedtools intersect -f 1.0 -loj -a ${path_maf}/tmp/merged_variant_position.bed -b ${file} | awk '{print $NF}' > ${path_maf}/tmp/covFiles/${filename}_variantCov.txt; 
# # done

# function PL {
# 	path_maf=${1}
# 	filename="$(basename ${2})"
# 	bedtools intersect -f 1.0 -loj -a ${path_maf}/tmp/merged_variant_position.bed -b ${2} | awk '{print $NF}' > ${path_maf}/tmp/covFiles/${filename}_variantCov.txt
# } 

# export -f PL

# parallel "PL" ::: ${path_maf} ::: ${path_maf}/coverage/new_bed/*.bed ${path_maf}/coverage/incorporated_bed/*.bed

# SUBENDTIME=$(date +%s)
# echo "	Running time: $(($SUBENDTIME - $SUBSTARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt


# # Runinng imputeValues.py script
# echo "	Runinng imputeValues.py script" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# SUBSTARTTIME=$(date +%s)


# bcftools query -l ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz | split -l 450 - "${path_maf}/tmp/subset_vcfs_merge_"

# function IMPUTE { 
# 	path_maf=${1}
# 	date_paste=${2}
# 	filename=${3}

# 	iname="$(basename ${filename})"

# 	# Sepration
# 	bcftools view -S ${filename} --min-ac=0 -O z -o ${path_maf}/tmp/${iname}_merged.vcf.gz ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz
# 	tabix -p vcf ${path_maf}/tmp/${iname}_merged.vcf.gz

# 	# Imputation
# 	skiprows=$(bcftools view ${path_maf}/tmp/${iname}_merged.vcf.gz | head -n 500 | grep -n "#CHROM" | sed 's/:.*//')
# 	numrows="$((${skiprows}-1))"
# 	bcftools view ${path_maf}/tmp/${iname}_merged.vcf.gz | head -n ${numrows} > ${path_maf}/tmp/${iname}_imputed.vcf

# 	python ${path_maf}/scripts/imputeValues.py \
# 	--mergedvcf ${path_maf}/tmp/${iname}_merged.vcf.gz \
# 	--skiprows ${skiprows} \
# 	--imputedvcf ${path_maf}/tmp/${iname}_imputed.vcf \
# 	--covFilesPath ${path_maf}/tmp/covFiles/ \
# 	--clusterSample ${iname}

# 	#rscript ${path_maf}/scripts/imputeValues.R \
# 	#${path_maf}/tmp/${iname}_merged.vcf.gz \
# 	#${path_maf}/tmp/R${iname}_imputed.vcf \
# 	#${path_maf}/tmp/covFiles/ 

# 	bgzip -c ${path_maf}/tmp/${iname}_imputed.vcf > ${path_maf}/tmp/${iname}_imputed.vcf.gz
# 	tabix -p vcf ${path_maf}/tmp/${iname}_imputed.vcf.gz

# 	rm ${path_maf}/tmp/${iname}_imputed.vcf
	
# }

# export -f IMPUTE

# parallel "IMPUTE" ::: ${path_maf} ::: ${date_paste} ::: ${path_maf}/tmp/subset_vcfs_merge_*

# # Merge impute values
# bcftools merge -O z -o ${path_maf}/tmp/imputed_${date_paste}_tmp.vcf.gz ${path_maf}/tmp/subset_vcfs_merge_*_imputed.vcf.gz	

# SUBENDTIME=$(date +%s)
# echo "	Running time: $(($SUBENDTIME - $SUBSTARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt

# ENDTIME=$(date +%s)
# echo "Running time: $(($ENDTIME - $STARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# # PLINK relationship calculation 
# echo "PLINK RELATIONSHIP CALCULATION" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# STARTTIME=$(date +%s)

# mkdir ${path_maf}/tmp/plinkout
# cd ${path_maf}/tmp/plinkout
# bcftools annotate --set-id +'%CHROM\_%POS\_%REF\_%FIRST_ALT' -o imputed_${date_paste}_ID_tmp.vcf.gz -O z ${path_maf}/tmp/imputed_${date_paste}_tmp.vcf.gz

# geno=0.05
# maf=0.05

# plink --vcf imputed_${date_paste}_ID_tmp.vcf.gz --make-bed --out merged
# plink --bfile merged --make-bed --geno ${geno} --mind 1 --maf ${maf} --out merged_geno_maf
# plink --bfile merged_geno_maf --geno ${geno} --mind 1 --maf ${maf} --indep-pairwise 50 5 0.5
# plink --bfile merged_geno_maf --extract plink.prune.in --make-bed --out merged_geno_maf_prunned
# plink --bfile merged_geno_maf_prunned --genome --min 0.05 --out relationship_raw
# sed  's/^ *//' relationship_raw.genome > relationship_tmp.tsv
# sed -r 's/ +/\t/g' relationship_tmp.tsv > relationship.tsv
# rm relationship_tmp.tsv


# plink --bfile merged --missing --out missing_stats_raw
# sed  's/^ *//' missing_stats_raw.imiss > missing_stats_tmp.tsv
# sed -r 's/ +/\t/g' missing_stats_tmp.tsv > missing_stats.tsv
# rm missing_stats_tmp.tsv

# Rscript ${path_maf}/scripts/filtro_parentesco_v2.R \
# ${mymetadatapathology_uniq} \
# relationship.tsv \
# missing_stats.tsv \
# tabla_muestras_excluidas.tsv \
# lista_muestras_excluidas.tsv

# ENDTIME=$(date +%s)
# echo "Running time: $(($ENDTIME - $STARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# # Making the definitive merge and imputed vcfs
# echo "MAKING THE DEFINITIVE MERGED AND IMPUTED VCFs" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# STARTTIME=$(date +%s)

# mkdir "${path_maf}/merged_vcf/${date_dir}"
# mkdir "${path_maf}/imputed_vcf/${date_dir}"
# mkdir "${path_maf}/individual_vcf/discarded_vcf_tmp"
# mkdir "${path_maf}/coverage/discarded_bed_tmp"

# # Moving individual vcf and bed files from related samples to the discarded folders

# if [[ $(cat ${path_maf}/tmp/plinkout/lista_muestras_excluidas.tsv | wc -l) == 0 ]]
# then
# 	mv ${path_maf}/tmp/imputed_${date_paste}_tmp.vcf.gz ${path_maf}/imputed_vcf/${date_dir}/imputed_${date_paste}.vcf.gz 
# 	mv ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz ${path_maf}/merged_vcf/${date_dir}/merged_${date_paste}.vcf.gz 
# else
# 	# Removing samples from merged and imputed vcf

# 	bcftools view -S ^${path_maf}/tmp/plinkout/lista_muestras_excluidas.tsv --min-ac=1 -O v ${path_maf}/tmp/imputed_${date_paste}_tmp.vcf.gz | sed "s/dUpTaGgG//g" | bgzip -c > ${path_maf}/imputed_vcf/${date_dir}/imputed_${date_paste}.vcf.gz
# 	bcftools view -S ^${path_maf}/tmp/plinkout/lista_muestras_excluidas.tsv --min-ac=1 -O v ${path_maf}/tmp/merged_${date_paste}_tmp.vcf.gz | sed "s/dUpTaGgG//g" | bgzip -c > ${path_maf}/merged_vcf/${date_dir}/merged_${date_paste}.vcf.gz

# 	for i in $(cat ${path_maf}/tmp/plinkout/lista_muestras_excluidas.tsv);
# 	do
# 		mv ${path_maf}/individual_vcf/incorporated_vcf/${i}* ${path_maf}/individual_vcf/discarded_vcf_tmp/
# 		mv ${path_maf}/coverage/incorporated_bed/${i}* ${path_maf}/coverage/discarded_bed_tmp/

# 		mv ${path_maf}/individual_vcf/new_vcf/${i}* ${path_maf}/individual_vcf/discarded_vcf_tmp/
# 		mv ${path_maf}/coverage/new_bed/${i}* ${path_maf}/coverage/discarded_bed_tmp/
# 	done

# 	########### EN PROCESO ###########
# 	# Rename duplicate samples

# 	for vcffile in ${path_maf}/individual_vcf/*/dUpTaGgG*.gz 
# 	do
# 		bcftools view ${vcffile} | sed "s/dUpTaGgG//g" | bgzip -c > ${path_maf}/individual_vcf/tmp.vcf.gz
# 		mv ${path_maf}/individual_vcf/tmp.vcf.gz ${vcffile}
# 	done

# 	# rename s/"dUpTaGgG"/""/g ${path_maf}/individual_vcf/incorporated_vcf/* # The “Perl” version, with syntax rename 's/^fgh/jkl/' fgh*
# 	# rename s/"dUpTaGgG"/""/g ${path_maf}/individual_vcf/discarded_vcf_tmp/*	
# 	# rename s/"dUpTaGgG"/""/g ${path_maf}/coverage/new_bed/*
# 	# rename s/"dUpTaGgG"/""/g ${path_maf}/coverage/discarded_bed_tmp/*

# 	rename "dUpTaGgG" "" ${path_maf}/individual_vcf/incorporated_vcf/* # The util-linux version, with syntax rename fgh jkl fgh*
# 	rename "dUpTaGgG" "" ${path_maf}/individual_vcf/discarded_vcf_tmp/*
# 	rename "dUpTaGgG" "" ${path_maf}/coverage/incorporated_bed/*
# 	rename "dUpTaGgG" "" ${path_maf}/coverage/discarded_bed_tmp/*
# 	########### EN PROCESO ###########
# fi
# tabix -p vcf ${path_maf}/imputed_vcf/${date_dir}/imputed_${date_paste}.vcf.gz
# tabix -p vcf ${path_maf}/merged_vcf/${date_dir}/merged_${date_paste}.vcf.gz

# ENDTIME=$(date +%s)
# echo "Running time: $(($ENDTIME - $STARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# # Database creation
# echo "DATABASE CREATION" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# STARTTIME=$(date +%s)

# mkdir "${path_maf}/db/${date_dir}"

# cd ${path_maf}/db/${date_dir}/


# python ${path_maf}/scripts/callMAF.py \
# --multivcf ${path_maf}/imputed_vcf/${date_dir}/imputed_${date_paste}.vcf.gz \
# --pathology ${mymetadatapathology_uniq} \
# --mafdb ${path_maf}/db/${date_dir}/MAFdb.tab \
# --samplegroup ${path_maf}/db/${date_dir}/sampleGroup.txt 


# python ${path_maf}/scripts/changeFormat.py \
# --multivcf ${path_maf}/imputed_vcf/${date_dir}/imputed_${date_paste}.vcf.gz \
# --vcfout ${path_maf}/db/${date_dir}/MAFdb_AN20_${date_paste}.vcf \
# --mafdb ${path_maf}/db/${date_dir}/MAFdb.tab \
# --samplegroup ${path_maf}/db/${date_dir}/sampleGroup.txt


# bgzip -c ${path_maf}/db/${date_dir}/MAFdb_AN20_${date_paste}.vcf > ${path_maf}/db/${date_dir}/MAFdb_AN20_${date_paste}.vcf.gz 
# tabix -p vcf ${path_maf}/db/${date_dir}/MAFdb_AN20_${date_paste}.vcf.gz 

# ENDTIME=$(date +%s)
# echo "Running time: $(($ENDTIME - $STARTTIME)) seconds" >> ${path_maf}/metadata/${date_dir}/logfile.txt
# echo >> ${path_maf}/metadata/${date_dir}/logfile.txt







# # Moving files and removing tmp diectory

# # copy db to lastest db
# cp ${path_maf}/db/${date_dir}/MAFdb_AN20_${date_paste}.vcf.gz ${path_maf}/db/latest/MAFdb_AN20_latest.vcf.gz
# cp ${path_maf}/db/${date_dir}/MAFdb_AN20_${date_paste}.vcf.gz.tbi ${path_maf}/db/latest/MAFdb_AN20_latest.vcf.gz.tbi

# # Moving log and tsv files from the relationship PLINK test to the metadata directory
# mdir ${path_maf}/metadata/${date_dir}/plinkout
# mv ${path_maf}/tmp/plinkout/*in ${path_maf}/metadata/${date_dir}/plinkout
# mv ${path_maf}/tmp/plinkout/*out ${path_maf}/metadata/${date_dir}/plinkout
# mv ${path_maf}/tmp/plinkout/*log ${path_maf}/metadata/${date_dir}/plinkout
# mv ${path_maf}/tmp/plinkout/*tsv ${path_maf}/metadata/${date_dir}/plinkout

# # Removing tmp directory
# # rm -r ${path_maf}/tmp/
# rm -r ${path_maf}/individual_vcf/tmp_vcf/

# # Moving the new samples to the incorporated
# mv ${path_maf}/individual_vcf/new_vcf/* ${path_maf}/individual_vcf/incorporated_vcf/
# mv ${path_maf}/coverage/new_bed/* ${path_maf}/coverage/incorporated_bed/

# # Moving temporal discarded samples and removing folder
# mv ${path_maf}/individual_vcf/discarded_vcf_tmp/* ${path_maf}/individual_vcf/discarded_vcf/
# mv ${path_maf}/coverage/discarded_bed_tmp/* ${path_maf}/coverage/discarded_bed/
# rm -r ${path_maf}/individual_vcf/discarded_vcf_tmp
# rm -r ${path_maf}/coverage/discarded_bed_tmp



echo "FINAL:" >> ${path_maf}/metadata/${date_dir}/logfile.txt
echo $(date) >> ${path_maf}/metadata/${date_dir}/logfile.txt
echo >> ${path_maf}/metadata/${date_dir}/logfile.txt
