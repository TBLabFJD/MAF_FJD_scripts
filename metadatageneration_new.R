#METADATA GENERATION
library(readxl)

read_excel_allsheets <- function(filename, tibble = FALSE, nskip=0) {
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) data.frame(readxl::read_excel(filename, sheet = X, skip=nskip), stringsAsFactors = F))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

mysheets <- read_excel_allsheets("~/UAMssh/ionut/MAF_FJD/my_metadata.xlsx")

###

###

familia.df = do.call("rbind", mysheets)

familia.df$ADNok = gsub("/", "-", familia.df$ADN)

familia.df = familia.df[!is.na(familia.df$Familia),]

familia.df$tag = tolower(familia.df$TAG)

#Ionut

#repetead_families.df <- data.frame(cbind(familia$ADN, familia$Familia))


# TAG ASSOCIATION
#tag.assoc = data.frame(read_excel("/home/ionut/uam/ionut/MAF_FJD/TAG_GROUP2.xlsx"), stringsAsFactors = F, sheet="clasificadas")


tag.assoc = data.frame(read_excel("/mnt/genetica/ionut/MAF_FJD/EXOMA/TAG_GROUP2.xlsx"), stringsAsFactors = F, sheet="clasificadas")
tag.assoc$TAG = tolower(tag.assoc$TAG)
tag.assoc_unique = unique(tag.assoc[, c("TAG", "Subtipo", "Subtipo")])
tag.assoc_unique = tag.assoc_unique[!is.na(tag.assoc_unique$TAG),]
rownames(tag.assoc_unique) = tag.assoc_unique$TAG

familia.df$Categoria = tag.assoc_unique[familia.df$tag,"Subtipo"]


write.table(x = familia.df, file = "/home/ionut/Desktop/mymetadatapathology_20210113.txt", row.names = F, quote = F, sep = "\t")

write.table(x = IRD_familia, file = "/home/ionut/Desktop/adn_family_total.txt", row.names = F, quote = F, sep = "\t")

IRD_familia <- subset(familia, TAG=="RP" | TAG=="MD", select = c(ADNok, Familia, Diagnóstico, TAG))
IRD_familia_unique <- unique(IRD_familia)
IRD_familia_solved <- subset(IRD_familia, Diagnóstico=="R_55" | Diagnóstico=="D_5" | Diagnóstico=="R_54" | Diagnóstico=="R_45" | Diagnóstico=="D_4", select = c(ADNok, Familia, Diagnóstico, TAG))

IRD_familia <- subset(familia, select = c(ADNok, Familia))
