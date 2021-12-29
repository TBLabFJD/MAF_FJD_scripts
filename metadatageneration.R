library(readxl)



read_excel_allsheets <- function(filename, tibble = FALSE, nskip=1) {
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) data.frame(readxl::read_excel(filename, sheet = X, skip=nskip), stringsAsFactors = F))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}



extract_df <- function(filename){
  
  df_out=data.frame()
  for (i in c(0,1,2)){
    mysheets <- read_excel_allsheets(filename, nskip=i)
    familia.list = lapply(mysheets, function(x)
      if("ADN" %in% colnames(x) && "Familia" %in% colnames(x)) x[,c("ADN","Familia")])
    familia.df = do.call("rbind", familia.list)
    if (is.null(familia.df)) next
    familia.df$Proyecto = rownames(familia.df)
    familia.df$Proyecto = gsub(".[0-9]*$", "", familia.df$Proyecto, perl = TRUE)
    df_out = rbind(df_out, familia.df)
  }
  
  return(df_out)
}





# DATA LOADING

args = commandArgs(TRUE)

familia.TSO.df = extract_df(args[1])
familia.CES1.df = extract_df(args[2])
familia.CES2.df = extract_df(args[3])
otras.muestras = read.table(args[4], sep="\t", header = TRUE)
familia.CES.INV.df = extract_df(args[8])

# familia.TSO.df = extract_df("/home/gonzalo/UAMssh/fjd/MAF_FJD_v3.0/metadata/Exoma Clínico_TSO y anterior.xls")
# familia.CES1.df = extract_df("/home/gonzalo/UAMssh/fjd/MAF_FJD_v3.0/metadata/Exoma Clínico_CES55_CES122.xls")
# familia.CES2.df = extract_df("/home/gonzalo/UAMssh/fjd/MAF_FJD_v3.0/metadata/Exoma Clínico_CES123_actual.xlsx")
# otras.muestras = read.table("/home/gonzalo/UAMssh/fjd/MAF_FJD_v3.0/metadata/otros_pacientes.tsv", sep="\t", header = TRUE)

familia = rbind(familia.TSO.df, familia.CES1.df, familia.CES2.df, otras.muestras, familia.CES.INV.df)
familia$Familia = gsub("\n", "|", familia$Familia)
familia = familia[!duplicated(familia),] # remove duplicates






# TAG ASSOCIATION
familia$ADN = gsub(" .*", "", familia$ADN, perl = TRUE)
familia$SAMPLE = gsub("/", "-", familia$ADN)
familia$TAG = gsub("[-_ ].*", "", familia$Familia, perl = TRUE)
# familia = familia[!is.na(familia$Familia),]
familia$tag = tolower(familia$TAG)
tag.assoc = data.frame(read_excel(args[5]), stringsAsFactors = F, sheet="clasificadas")
# tag.assoc = data.frame(read_excel("/home/gonzalo/UAMssh/fjd/MAF_FJD_v3.0/metadata/TAG_GROUP2.xlsx"), stringsAsFactors = F, sheet="clasificadas")
tag.assoc$TAG = tolower(tag.assoc$TAG)
tag.assoc_unique = unique(tag.assoc[, c("TAG", "Subtipo")])
tag.assoc_unique = tag.assoc_unique[!is.na(tag.assoc_unique$TAG),]
rownames(tag.assoc_unique) = tag.assoc_unique$TAG


familia$Categoria = tag.assoc_unique[familia$tag,"Subtipo"]


familia = familia[grep("REANÁLISIS", familia$Proyecto, invert = TRUE),]
familia = familia[grep("Confirmaciones", familia$Proyecto, invert = TRUE),]
familia = familia[!is.na(familia$ADN),]
familia$Familia[is.na(familia$Familia)] <- "-"
familia$TAG[is.na(familia$TAG)] <- "-"
familia$tag[is.na(familia$Familia)] <- "-"

# Collapse duplicates
newdf <- familia[!duplicated(familia$ADN),]
for (sample in newdf$ADN){
  for (column in colnames(newdf)){
    vector = unique(familia[familia$ADN == sample, column])
    newdf[newdf$ADN == sample, column] = paste(vector[!is.na(vector)], collapse = "|")
  }
}
newdf[newdf==""]<-NA


familia$Categoria[is.na(familia$Categoria)] <- "Varios"
newdf$Categoria[is.na(newdf$Categoria)] <- "Varios"


write.table(x = familia, file = args[6], row.names = F, quote = F, sep = "\t")
write.table(x = newdf, file = args[7], row.names = F, quote = F, sep = "\t")


#####################
# ionut <- read.delim("/home/gonzalo/UAMssh/fjd/MAF_FJD_v3.0/metadata/mymetadatapathology_20210315.txt", stringsAsFactors = FALSE)
# diferencia <- ionut[ionut$ADN %in% setdiff(ionut$ADN, familia$ADN), c("PROJECT", "ADN", "Familia")]
# diferencia$PROJECT = gsub("_.*$", "", diferencia$PROJECT)
# diferencia$PROJECT = gsub("-.*$", "", diferencia$PROJECT)
# colnames(diferencia) <- colnames(otros)
# write.table(diferencia, "/home/gonzalo/UAMssh/fjd/MAF_FJD_v3.0/metadata/otros_pacientes.tsv", row.names = FALSE, col.names = TRUE, quote = FALSE, sep = "\t")
# 
# 
# path="/home/gonzalo/Documents/MAF_FJD_v2.0/metadata/date_2021_03_29/mymetadatapathology_2021_03_29.txt"
# aa = read.table(path, sep="\t", header = TRUE)
# 