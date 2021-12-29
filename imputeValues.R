## MAF FJD COHORT DDBB - IMPUTING VALUES
## Author: Lorena de la Fuente
## 12-02-2020

args = commandArgs(TRUE)
mergedVCF = args[1] # MergedVCF
imputedVCF = args[2] # Path to save final imputedFile
covFiles = args[3] # All Cov files

print(covFiles)
print(mergedVCF)
print(imputedVCF)


### 1. Load MERGED VCF

library(vcfR)

vcf <- read.vcfR(mergedVCF, verbose = FALSE, limit = 3e+11)

print(gc())

genotypes = vcf@gt[,-1]

samples = colnames(genotypes)

print(samples)





### 2. Create matrix (read variant coverage files to create matrix)

matrix = matrix(NA, nrow = nrow(genotypes), ncol = ncol(genotypes))
colnames(matrix) = samples

for (sample in samples) {
  print(sample)
  file = list.files(path = covFiles, pattern = sample, full.names = T)[1]
  print(file)
  matrix[,sample] = read.table(file, stringsAsFactors = FALSE)[,1]
}

print(gc())



matrix[matrix=="10:inf"] <- "0/0:.:.:.:."
matrix[matrix=="."] <- "./.:.:.:.:."
matrix[matrix=="1"] <- "./.:.:.:.:."
matrix[matrix=="2"] <- "0/0:.:.:.:."


print("Matrix")
print(colnames(matrix))
print(dim(matrix))



### 3. Merge values
 
genotypes[genotypes == "./.:.:.:.:.:.:.:."] <- "./.:.:.:.:."
genotypes[genotypes == "./.:.:.:.:."] <- matrix[genotypes == "./.:.:.:.:."]

genotypes = cbind(vcf@gt[,1,drop=F], genotypes)

vcf@gt <- genotypes


write.vcf(x = vcf, file = imputedVCF)



