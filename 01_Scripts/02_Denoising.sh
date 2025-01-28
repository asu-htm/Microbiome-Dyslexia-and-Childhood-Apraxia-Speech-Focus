#!/bin/bash

#SBATCH --job-name=DEONISE
#SBATCH -o DENOISE-1.out
#SBATCH --nodes=1
#SBATCH -t 0-04:00:00
#SBATCH --cpus-per-task=10
#SBATCH --mem=126G

cd $SLURM_SUBMIT_DIR

set -uex

# Record the start time
start_time=$(date)

# Activate QIIME2 environments
module load mamba
module load mamba/latest
source activate 

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs paired-end-demux.qza \
  --p-trim-left-f 0 \
  --p-trim-left-r 0 \
  --p-trunc-len-f 0 \
  --p-trunc-len-r 0 \
  --o-table Denoised-files/feature-table.qza \
  --o-representative-sequences Denoised-files/rep-seqs.qza \
  --o-denoising-stats Denoised-files/denoising-stats.qza \
  --p-n-threads 6

  qiime metadata tabulate \
  --m-input-file Denoised-files/denoising-stats.qza \
  --o-visualizationDenoised-files/denoising-dada2-stats-summ.qzv

