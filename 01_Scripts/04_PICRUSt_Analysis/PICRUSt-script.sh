#!/bin/bash

# Run PICRUSt2 full pipeline

# Activate PICRUSt2 environment
conda activate picrust2

# Define input files
FASTA=rep_seqs.fasta
TABLE=feature_table.biom

# Step 1: Run full PICRUSt2 pipeline
picrust2_pipeline.py \
  -s $FASTA \
  -i $TABLE \
  -o picrust2_out_pipeline \
  -p 4  

# Output directory will include:
# - EC metagenome predictions: `EC_metagenome_out/pred_metagenome_unstrat.tsv.gz`
# - KO metagenome predictions: `KO_metagenome_out/pred_metagenome_unstrat.tsv.gz`
# - Pathway predictions: `pathways_out/path_abun_unstrat.tsv.gz`

# Step 2: Optionally, convert predicted output for STAMP or R
# Unzip and convert to TSV if needed:
gzip -d picrust2_out_pipeline/KO_metagenome_out/pred_metagenome_unstrat.tsv.gz

# Optional: Summarize pathway predictions (MetaCyc)
format_tree_and_metadata.py \
  -i picrust2_out_pipeline/pathways_out/path_abun_unstrat.tsv.gz \
  -m EC \
  -o picrust2_out_pipeline/pathways_out/path_abun_unstrat.stamp.tsv

echo "PICRUSt2 pipeline completed successfully!"
