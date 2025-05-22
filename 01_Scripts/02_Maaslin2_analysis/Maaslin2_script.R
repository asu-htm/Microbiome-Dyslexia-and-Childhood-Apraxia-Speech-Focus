# Maaslin2 Analysis Script
# Author: Sterling Wright
# Date: May 22nd, 2025
# Description: Run MaAsLin2 to assess differential abundance by Phenotype group,
# and visualize CLR-transformed abundances for a specific microbe.

##############################
# Setup
##############################

# Set working directory
setwd("$PATH")

# Load libraries
library(Maaslin2) # v.1.20.0
library(ggplot2) # v.3.5.1 
library(dplyr) # v.1.1.4
library(readr) # v.2.1.5
library(compositions) # v.2.0.8

##############################
# Load Input Data
##############################

# Read species abundance and metadata
species_data <- read.csv("species-gut-Neurodivergence.csv", row.names = 1)
metadata <- read.csv("METADATA.csv")

# Ensure Phenotype is a factor with specific reference level
metadata$Phenotype <- factor(metadata$Phenotype, levels = c("Typical", "Apraxia_of_speech", "Dyslexia"))

##############################
# Run MaAsLin2
##############################

set.seed(1)  # For reproducibility

fit_data <- Maaslin2(
  input_data = species_data,
  input_metadata = metadata,
  output = "Maaslin2",
  fixed_effects = c("Phenotype"),
  max_significance = 0.05,
  analysis_method = "LM"
)

##############################
# Visualization: CLR Boxplot
##############################

# Define microbe of interest
microbe_col <- "d__Bacteria.p__Bacteroidota.c__Bacteroidia.o__Bacteroidales.f__Rikenellaceae.g__Alistipes_A_871400.s__Alistipes_A_871400.communis"

# Confirm column exists
if (!(microbe_col %in% colnames(species_data))) {
  stop("Microbe not found in species_data")
}

# Merge with metadata
species_data$SampleID <- rownames(species_data)
merged_data <- species_data %>%
  inner_join(metadata, by = "SampleID")

# CLR transform (add pseudocount first)
abundance_cols <- setdiff(colnames(species_data), "SampleID")
merged_data[abundance_cols] <- merged_data[abundance_cols] + 1
clr_transformed <- clr(merged_data[abundance_cols]) %>% as.data.frame()
merged_data[abundance_cols] <- clr_transformed

# Add column for plotting
merged_data$clr_abundance <- merged_data[[microbe_col]]

# Define custom colors
phenotype_colors <- c(
  "Apraxia_of_speech" = "purple",
  "Dyslexia" = "orange",
  "Typical" = "blue3"
)

# Plot
p <- ggplot(merged_data, aes(x = Phenotype, y = clr_abundance, fill = Phenotype)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.7) +
  geom_jitter(width = 0.2, size = 2, alpha = 0.8) +
  scale_fill_manual(values = phenotype_colors) +
  labs(
    title = "Alistipes A 871400 communis",
    x = "Phenotype",
    y = "CLR-transformed Abundance"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    text = element_text(size = 14)
  )

# Save plot (optional)
ggsave("alistipes_boxplot.png", plot = p, width = 8, height = 6)

# View plot
print(p)
