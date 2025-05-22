#!/bin/bash

# QIIME 2 Microbiome Analysis Pipeline
# Author: Sterling L. Wright
# Date: May 22nd, 2025
# Description: This script performs quality control, taxonomic classification, diversity analysis,
# and data export using QIIME 2 from raw paired-end fastq files.

##############################
# 1. Preprocessing: AdapterRemoval
##############################

OUTPUT_DIR="adapter_removal_output"
mkdir -p $OUTPUT_DIR

cat SampleNames.txt | while read sample; do
    R1="${sample}_L001_R1_001.fastq.gz"
    R2="${sample}_L001_R2_001.fastq.gz"
    
    AdapterRemoval --file1 $R1 \
                   --file2 $R2 \
                   --output1 ${OUTPUT_DIR}/${sample}_unmerged_R1.fastq.gz \
                   --output2 ${OUTPUT_DIR}/${sample}_unmerged_R2.fastq.gz \
                   --outputcollapsed ${OUTPUT_DIR}/${sample}_merged.fastq.gz \
                   --minlength 30 \
                   --threads 4 \
                   --trimqualities \
                   --trimns \
                   --collapse \
                   --minquality 20

done

##############################
# 2. Import and DADA2 Denoising
##############################

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.txt \
  --output-path paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33

qiime tools validate paired-end-demux.qza

qiime demux summarize \
  --i-data paired-end-demux.qza \
  --o-visualization paired-end-demux.qzv

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs paired-end-demux.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 250 \
  --p-trunc-len-r 200 \
  --o-table feature-table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza \
  --p-n-threads 6

qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-dada2-stats.qzv

##############################
# 3. Taxonomy Assignment
##############################

qiime feature-classifier classify-sklearn \
  --i-classifier $DATABASE \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

qiime taxa barplot \
  --i-table feature-table.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file $METADATA \
  --o-visualization taxa-barplot.qzv

##############################
# 4. Collapse to Genus and Species
##############################

# Genus
qiime taxa collapse \
  --i-table feature-table.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table genus-table.qza

# Species
qiime taxa collapse \
  --i-table feature-table.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 7 \
  --o-collapsed-table species-table.qza

##############################
# 5. Export Collapsed Tables
##############################

for LEVEL in genus species; do
  NAME="${LEVEL}-table"
  qiime tools export \
    --input-path ${NAME}.qza \
    --output-path exported-${LEVEL}

  biom convert \
    -i exported-${LEVEL}/feature-table.biom \
    -o exported-${LEVEL}/${NAME}.tsv \
    --to-tsv

done

##############################
# 6. Alpha Diversity Analysis
##############################

mkdir -p ALPHA_DIVERSITY

for METRIC in observed_features shannon simpson; do
  qiime diversity alpha \
    --i-table species-table.qza \
    --p-metric $METRIC \
    --o-alpha-diversity ALPHA_DIVERSITY/alpha-${METRIC}_vector.qza

  qiime diversity alpha-group-significance \
    --i-alpha-diversity ALPHA_DIVERSITY/alpha-${METRIC}_vector.qza \
    --m-metadata-file $METADATA \
    --o-visualization ALPHA_DIVERSITY/alpha-${METRIC}.qzv

done

##############################
# 7. Beta Diversity (Optional Example)
##############################

# Filter genus table to saliva samples
qiime feature-table filter-samples \
  --i-table genus-table.qza \
  --m-metadata-file $METADATA \
  --p-where "SampleType IN ('saliva')" \
  --o-filtered-table genus-saliva.qza

qiime diversity beta \
  --i-table genus-saliva.qza \
  --p-metric aitchison \
  --p-pseudocount 1 \
  --o-distance-matrix genus-saliva-aitchison-distance.qza

qiime diversity pcoa \
  --i-distance-matrix genus-saliva-aitchison-distance.qza \
  --o-pcoa pcoa-genus-saliva.qza

qiime emperor plot \
  --i-pcoa pcoa-genus-saliva.qza \
  --m-metadata-file $METADATA \
  --o-visualization pcoa-genus-saliva-emperor.qzv

declare -a StringArray=("SampleType" "State" "City")
for category in ${StringArray[@]}; do
qiime diversity beta-group-significance \
  --i-distance-matrix genus-saliva-aitchison-distance.qza \
  --m-metadata-file $METADATA \
  --m-metadata-column "$category" \
  --o-visualization ${NAME}-$category-significance.qzv \
  --p-pairwise
done




  
