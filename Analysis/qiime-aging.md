---
editor_options: 
  markdown: 
    wrap: 72
---

system("git --version")

conda activate qiime2-amplicon-2024.10

### The input here is a txt file with sample ID, location to FR and RR

qiime tools import\
--type 'SampleData[PairedEndSequencesWithQuality]'\
--input-path AMCohortC_lumu.files.txt\
--output-path Aging-mucosal-all.qza\
--input-format PairedEndFastqManifestPhred33V2

qiime demux summarize\
--i-data \$input/Aging-mucosal-all.qza\
--o-visualization \$input/Aging-mucosal-all-demux2.qzv

### I used DADA2 to denoise

qiime dada2 denoise-paired\
--i-demultiplexed-seqs \$input/Aging-mucosal-all.qza\
--p-trunc-len-f 250\
--p-trunc-len-r 240\
--o-representative-sequences
\$input/Aging-mucosal-all-rep-seqs-dada2.qza\
--o-table \$input/Aging-mucosal-table-all-dada2.qza\
--o-denoising-stats \$input/Aging-mucosal-stats-all-dada2.qza\
--p-n-threads 5

qiime metadata tabulate\
--m-input-file \$input/Aging-mucosal-stats-all-dada2.qza\
--o-visualization \$input/Aging-mucosal-stats-all-dada2.qzv

qiime feature-table summarize\
--i-table \$input/Aging-mucosal-table-all-dada2.qza\
--o-visualization \$input/Aging-mucosal-table-all-dada2.qzv\
--m-sample-metadata-file \$input/AMCohortC_lumu_meta.txt

qiime phylogeny align-to-tree-mafft-fasttree\
--i-sequences Aging-mucosal-all-rep-seqs-dada2.qza\
--o-alignment aligned-Aging-mucosal-rep-seqs-all.qza\
--o-masked-alignment aligned-Aging-mucosal-rep-seqs-dada2-all.qza\
--o-tree mucosal-unrooted-tree-all.qza\
--o-rooted-tree muscoal-rooted-tree-all.qza

qiime diversity core-metrics-phylogenetic\
--i-phylogeny muscoal-rooted-tree-all.qza\
--i-table Aging-mucosal-table-all-dada2.qza\
--p-sampling-depth 4107\
--m-metadata-file \$input/AMCohortC_lumu_meta.txt\
--output-dir core-metrics-results

## Different classifiers were tried and same results were obtained

classifier1=/home/nidhivij/SILVA_db_qiime/silva-138-trained-classifier.qza
classifier=/home/nidhivij/qiime2/silva-138-99-nb-classifier.qza
classifier=/home/nidhivij/qiime2/silva-138-99-nb-diverse-weighted-classifier.qza
qiime feature-classifier classify-sklearn\
--i-classifier \$classifier\
--i-reads Aging-mucosal-all-rep-seqs-dada2.qza\
--o-classification Aging-mucosal-taxonomy-silva138-weighted-all.qza

classifier1=/home/nidhivij/SILVA_db_qiime/silva-138-trained-classifier.qza
classifier=/home/nidhivij/qiime2/silva-138-99-nb-diverse-weighted-classifier.qza
qiime feature-classifier classify-sklearn\
--i-classifier \$classifier\
--i-reads Aging-rep-seqs-dada2.qza\
--o-classification Aging-taxonomy-weighted_silva138-1.qza

#Beta diversity exploration qiime diversity beta-group-significance\
--i-distance-matrix
core-metrics-results/bray_curtis_distance_matrix.qza\
--m-metadata-file Young_aging_metadata.txt\
--o-visualization core-metrics-results/bray_distance_matrix.qzv\
--p-pairwise\
--m-metadata-column age\

qiime diversity beta-group-significance\
--i-distance-matrix
core-metrics-results/weighted_unifrac_distance_matrix.qza\
--m-metadata-file Young_aging_metadata.txt\
--o-visualization core-metrics-results/weighted_UF_distance_matrix.qzv\
--p-pairwise\
--m-metadata-column age\

