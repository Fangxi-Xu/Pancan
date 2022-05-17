#Author: Fangxi Xu
#Date: 05/17/2022
####################
# R v4.0.5
setwd("/Volumes/Samsung_T5/pancan2022/qiime2-open-ref/R")
#load required packages
library("readr")#read_tsv() function
library("phyloseq")#create phylo object
library("tidyverse")
library("dplyr")
###################
#create phyloseq object
############################################################################
# import biom (feature) table - take a look at the tsv before importing
biom <- read_tsv("/Volumes/Samsung_T5/pancan2022/qiime2-open-ref/feature-table.tsv", col_names = TRUE)
row.names(biom) = biom$'#OTU ID'#column '#OTU ID' to row.names
biom = as.data.frame(biom)#convert to dataframe
biom[,1] <- NULL#remove the '#OTU ID' column
############################################################################
#import taxonomy table separated by Domain, Phylum, Class, Order, Family, Genus, Species
taxonomy<- read_tsv("/Volumes/Samsung_T5/pancan2022/qiime2-open-ref/taxonomy.tsv", col_names = TRUE)
colnames(taxonomy)#check column names
#names(taxonomy)[names(taxonomy) == "Feature ID"] <- "FeatureID"#rename the column if necessary
taxonomy = taxonomy[-1,]#delete unwanted row by row# - this is to remove the 1st row
taxonomy = taxonomy[,-3]#delete unwanted column by column# - this is to remove the 3nd column
taxonomy = as.data.frame(separate(taxonomy, Taxon, into = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"), sep=";"))
row.names(taxonomy) = taxonomy$`Feature ID`#column 'Feature ID' to row.names
taxonomy[,1] <- NULL#remove the 'Feature ID' column
#clean the taxonomy table by renaming the NA with Unclassified
#for differential taxa analysis, all the unclassified need to be aggregated and sum 
taxon = taxonomy %>% tidyr::replace_na(list(Domain = "k__Unclassified", 
                                            Phylum = "p__Unclassified",
                                            Class = "c__Unclassified",
                                            Order = "o__Unclassified",
                                            Family = "f__Unclassified",
                                            Genus = "g__Unclassified",
                                            Species = "s__Unclassified"))

taxon <- as.matrix(taxon)

############################################################################``
# Read in metadata
metadata <- read.table("/Volumes/Samsung_T5/pancan2022/qiime2-open-ref/metadata_w_ctrls.txt", head= T, row.names = 1)
############################################################################
# Read in phylogentic tree if there's one
############################################################################
# Import all as phyloseq objects
OTU <- otu_table(biom, taxa_are_rows = TRUE)
TAX <- tax_table(taxon)
META<-sample_data(metadata)
# Sanity checks for consistent OTU names
taxa_names(TAX)
taxa_names(OTU)
taxa_names(phy_tree)
# Same sample names
sample_names(OTU)
sample_names(META)
#merge and create phyloseq object
phylo <- phyloseq(OTU, TAX, META, phy_tree)
phylo
#prune OTUs that are not present in at least one sample
phylo<-prune_taxa(taxa_sums(phylo) > 0, phylo)
phylo

saveRDS(phylo, "phylo_all.rds")



