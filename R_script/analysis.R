library("phyloseq")
setwd("/Volumes/Samsung_T5/pancan2022/qiime2-open-ref/R")
phylo <- readRDS("phylo_all.rds")
phylo

#filter non-fungi otus/asvs
phylo_fungi = subset_taxa(phylo, Kingdom =="k__Fungi")
phylo_fungi

#filter to just keep taxa that appeared in more than one sample (prevalence >= 2)
phylo_fungi.1 <- filter_taxa(phylo_fungi, function (x) {sum(x > 0) > 1}, prune=TRUE)
phylo_fungi.1

#subset tissue samples
phylo_tissue<-subset_samples(phylo_fungi.1, SampleType == "Tissue")
phylo_tissue


##########################################################################################
#Bray-Curtis Beta diversity
library("vegan")
sample_data(phylo_tissue)[1:10]
sample_data(phylo_tissue)$Description <- factor(sample_data(phylo_tissue)$Description)
is.factor(sample_data(phylo_tissue)$Description)
levels(sample_data(phylo_tissue)$Description)
# Change labels
levels(sample_data(phylo_tissue)$Description) = c("PDA", "Healthy")

dist <- phyloseq::distance(phylo_tissue, method = "bray")
perma <- adonis(dist~Description, data = as(sample_data(phylo_tissue), "data.frame"), permutations = 1000)
perma

bray1 <- ordinate(phylo_tissue, "PCoA", "bray")
bray2 <- plot_ordination(phylo_tissue, 
                         bray1, color="Description") + 
  stat_ellipse(geom = "polygon", type="norm", size=1, alpha=0.1, aes(color=Description, fill=Description))+
  scale_fill_manual(values = c("Healthy"="cornflowerblue", "PDA"="orange"))+
  scale_color_manual(values = c("Healthy"="cornflowerblue", "PDA"="orange"))+
  ggtitle("Bray-Curtis") + geom_point(size = 4)+
  beta.theme

pdf("Bray_Curtis.pdf",width=5,height=4)
bray2 
dev.off()

#########################################################
genus_count <- tax_glom(phylo_tissue, "Genus")
genus_count<-psmelt(genus_count)
write.csv(genus_count, file = "genus_count.csv")
#genus level individual sample stacked bar plot
Tissue_relative = transform_sample_counts(phylo_tissue, function(x) {(x/sum(x))} )
Tissue_relative
#prepare dataset
genus_glom <- tax_glom(Tissue_relative, taxrank = "Genus")#agglomerate at the genus taxonomic rank 
genus<-psmelt(genus_glom)# melt phyloseq object into large data frame
genus = subset(genus, select = c("Sample","Genus","Abundance"))#select columns to use; put value variable at the end
genus$Genus[genus$Genus=="g__unidentified"]<-"g__Unclassified"
#merge duplicated rows
genus%>%
  group_by(Sample, Genus) %>%
  summarise_all(sum) %>%
  data.frame() -> genus_agg
#calculate statistics (make sure using dplyr not plyr)
#genus_summary <- data_genus %>%
#  group_by(Description,Genus) %>%  # the grouping variable
#  summarise(mean_Abun = mean(Abundance),# calculates the mean of each group for each genus
#            sum_Abun = sum(Abundance),#calculates the sum of each group for each genus
#            sd_Abun = sd(Abundance), # calculates the standard deviation of each group
#            n_Abun = n(),  # calculates the sample size per group
#            SE_Abun = sd(Abundance)/sqrt(n()))# calculates the standard error of each group 

genus_reshape <- reshape2::dcast(genus_agg, Sample ~ Genus, value.var='Abundance') #transform data
genus_reshape <- genus_reshape %>% remove_rownames %>% column_to_rownames(var="Sample")#column "Sample" to row name
genus_reshape_t <- as.data.frame(t(genus_reshape))
genus_reshape_t$sum <- rowSums(genus_reshape_t)

new_genus_reshape <- genus_reshape_t[order(-genus_reshape_t$sum),]

top20 <- new_genus_reshape[1:20,]

top20_genera <- row.names(top20)

new_genus_reshape$Genus <- row.names(new_genus_reshape)

#now i want to create a list containing the top20 genera names, and keep those genera names but change the other genera names to "others"
Others <- !(new_genus_reshape$Genus %in% c( "g__Candida", "g__Malassezia", "g__Saccharomyces", "g__Cystobasidium",
                                            "g__Unclassified" ,"g__Cladosporium",      "g__Aspergillus",       "g__Rhodotorula",
                                            "g__Blumeria", "g__Tilletia", "g__Exophiala","g__Didymella", "g__Hanseniaspora", 
                                            "g__Meyerozyma", "g__Filobasidium" , "g__Collophora","g__Kazachstania", "g__Agaricus", "g__Cystofilobasidium",
                                            "g__Debaryomyces"))
new_genus_reshape$Genus[Others]<- "Others"

#merge duplicated rows
new_genus_reshape%>%
  group_by(Genus) %>%
  summarise_all(sum) %>%
  data.frame() -> new_genus_reshape

new_genus_reshape <- new_genus_reshape[ -c(20) ]#remove the sum column

final_genus <- reshape2::melt(new_genus_reshape)
#genus barplot
final_genus$variable <- factor(final_genus$variable)
final_genus$Genus <- as.character(final_genus$Genus)

#merge with metadata
metadata <- read.table("/Volumes/Samsung_T5/pancan2022/qiime2-open-ref/metadata_w_ctrls.txt", head= T)
final_genus$SampleID<-final_genus$variable
final_genus <- merge(final_genus, metadata, by = "SampleID")

#plot individual sample based stacked barplot

final_genus$Genus <- factor(final_genus$Genus, levels = c("g__Candida","g__Malassezia","g__Unclassified",
                                                          "g__Cystobasidium", "g__Rhodosporidiobolus", "g__Aspergillus",
                                                          "g__Cladosporium", "g__Saccharomyces", "g__Tilletia","g__Ustilago",
                                                          "g__Aureobasidium","g__Udeniomyces", "g__Exophiala", "g__Kazachstania",
                                                          "g__Rhodotorula","g__Wallemia", "g__Alternaria",
                                                          "g__Botrytis","g__Gibberella","g__Plectosphaerella", "Others"))
final_genus$Description <- factor(final_genus$Description, levels = c("health", "cancer"), labels = c("Healthy","PDA"))

p <- ggplot(final_genus, aes(fill=Genus, y=value, x=variable)) + facet_grid(~Description, scales = "free_x",space="free")+
  geom_bar(position="stack", stat="identity")+
  scale_fill_manual(values = c("#15983DFF", "#FEC10BFF","#838B8B","#A1C720FF","#16A08CFF", "#0C5BB0FF", "#EE0011FF", "#9A703EFF","#FFA07A","808080",
                               "lightskyblue", "darkgreen", "deeppink", "khaki2", "firebrick", "darkgoldenrod1", "darkorange1", "cyan1", "royalblue4", "darksalmon",
                               "black"))+
  ylab("Mean Relative Abundance (%)") +
  geom_bar(position="stack", stat="identity")+
  stacked_bar.theme

pdf("genus_bar_plot.pdf",width=12,height=4)
p
dev.off()
