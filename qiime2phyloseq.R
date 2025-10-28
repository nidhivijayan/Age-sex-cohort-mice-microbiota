#creating qiime object =====
qiime<-qza_to_phyloseq(features="Aging-table-dada2.qza",
                       tree="rooted-tree-merged.qza",
                       metadata="Young_aging_metadata_v3.txt", taxonomy = "Aging-taxonomy-weighted_silva138-1.qza")

qiime

#visualizing data ====
sample_sums_df <- data.frame(SampleID = sample_names(qiime_f),
                             Reads = sample_sums(qiime_f))
library(ggplot2)
ggplot(sample_sums_df, aes(x = Reads)) + 
  geom_histogram(binwidth = 1000) + 
  geom_vline(xintercept = c(1000, 5000, 10000), linetype = "dashed", col = "red") +
  labs(title = "Read depth distribution across samples")

otu <- as(otu_table(qiime), "matrix")
rarecurve(t(otu), step = 500, sample = min(rowSums(otu)), cex = 0.5, label = FALSE)
abline(v = 5000, col = "red", lty = 2)

qiime_sampledf<-data.frame(sample_data(qiime))
View(qiime_sampledf)

# Filtering samples with only 1 replicate ====
samples_to_keep <- !(qiime_sampledf$month %in% c("M04", "M08", "M20","M14","exclude"))
names(samples_to_keep) <- rownames(qiime_sampledf)  # match sample names
qiime_f<-prune_samples(samples_to_keep, qiime_f)
qiime_f

#Filter out cohort B since it was not longitudinal =====
qiime_sampledf<-data.frame(sample_data(qiime))
samples_to_keep <- !(qiime_sampledf$mousegroup.x %in% c("B", "C2","C3"))
names(samples_to_keep) <- rownames(qiime_sampledf)  # match sample names
qiime_f<-prune_samples(samples_to_keep, qiime)
qiime_f

#Filter out samples with low reads =====

qiime_f <- prune_samples(sample_sums(qiime_f) >= 5027, qiime_f)

#determine how many mice were present ====
n_unique_mice <- qiime_sampledf %>% summarise(n_unique = n_distinct(mouse))
print(n_unique_mice)
# 92
n_per_month <- qiime_sampledf %>%
  group_by(month) %>%
  summarise(n = n())

print(n_per_month)
# month     n
# <chr> <int>
#   1 M03      75
# 2 M05      39
# 3 M06      31
# 4 M07      44
# 5 M09      69
# 6 M11      42
# 7 M12      29
# 8 M13      35
# 9 M15      67
# 10 M17      33
# 11 M18      24
# 12 M19      34
# 13 M21      36
# 14 M22      21
# 15 M23      45
#Plot number of samples

samples_df<-as.data.frame(sample_data(qiime_f))
  
  metadata_summ <- samples_df %>%
  group_by(month, survival, mousegroup.x) %>%
  summarise(n_samples = n(), .groups = "drop")
View(metadata_summ)

metadata_summ <- metadata_summ[metadata_summ$frailty != "" & !is.na(metadata_summ$frailty), ]

ggplot(metadata_summ, aes(fill=survival, y=n_samples, x=month)) + scale_fill_manual(values=c("deeppink","blue","grey"))+
  geom_bar(position="stack", stat="identity")+facet_grid(.~mousegroup.x, scales="free_x")
