#!/bin/bash

#SBATCH --job-name=Import
#SBATCH -o import-w-QIIME2.out
#SBATCH --nodes=1
#SBATCH -t 48:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=120G

cd $SLURM_SUBMIT_DIR

set -uex

# Record the start time
start_time=$(date)

# Activate QIIME2 environments
module load mamba
module load mamba/latest
source activate QIIME2-amplicon-2024.5

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.txt \
  --output-path paired-end-demux.qza \
  --input-format PairedEndFastqManifestPhred33

qiime tools validate paired-end-demux.qza

qiime demux summarize \
  --i-data paired-end-demux.qza \
  --o-visualization paired-end-demux.qzv
