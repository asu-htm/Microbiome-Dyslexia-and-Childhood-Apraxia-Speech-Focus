# Stacked Bar Plots for Microbiome Data
# Author: Sterling L. Wright
# Date: March 6th, 2025
# Description: This script generates stacked bar plots for gut and saliva microbiome datasets.

# Rversion: 4.1

# Load required libraries
library(ggplot2); packageVersion("ggplot2")
library(tidyr)
library(dplyr)
library(readr)
library(gtools)
library(cowplot)
library(patchwork); packageVersion("patchwork")

# Load data
gut_df <- read.csv("species-gut-relative-abundance-5percent-2samples.csv", header = TRUE)
saliva_df <- read.csv("species-saliva-relative-abundance-5percent-2samples-1.csv", header = TRUE)

# Ensure numerical ordering of SampleID
# Transform data to long format
gut_long <- gut_df %>% pivot_longer(-Species, names_to = "SampleID", values_to = "Abundance")
# Ensure numerical ordering of SampleID
gut_long$SampleID <- factor(gut_long$SampleID, levels = mixedsort(unique(gut_long$SampleID)))

saliva_long <- saliva_df %>% pivot_longer(-Species, names_to = "SampleID", values_to = "Abundance")

# Ensure numerical ordering of SampleID
saliva_long$SampleID <- factor(saliva_long$SampleID, levels = mixedsort(unique(gut_long$SampleID)))

# Move "Other" to the end of the Species factor levels
gut_long$Species <- factor(gut_long$Species, levels = c(setdiff(unique(gut_long$Species), "Other"), "Other"))
saliva_long$Species <- factor(saliva_long$Species, levels = c(setdiff(unique(saliva_long$Species), "Other"), "Other"))


# Function to generate stacked bar plot
generate_barplot <- function(data, title, output_filename) {
  num_species <- length(unique(data$Species))  # Get number of unique species
  custom_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00",
                     "#FFFF33", "#A65628", "#F781BF", "dodgerblue", "#66C2A5",
                     "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F",
                     "#E5C494", "#B3B3B3", "#1F78B4", "#33A02C")  
  
  p <- ggplot(data, aes(x = SampleID, y = Abundance, fill = Species)) +
    geom_bar(stat = "identity", position = "stack") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 14),
          axis.text.y = element_text(size = 14),
          axis.title.x = element_text(size = 16, face = "bold"),
          axis.title.y = element_text(size = 16, face = "bold"),
          legend.position = "right",
          legend.text = element_text(size = 12),
          legend.title = element_text(size = 14, face = "bold")) +
    labs(title = title, x = "", y = "", fill = "Features") +
    scale_fill_manual(values = rep(custom_colors, length.out = num_species))
  
  # Save plot
  ggsave(output_filename, plot = p, width = 10, height = 6, dpi = 300)
  return(p)
}

# Generate and save plots
plot_gut <- generate_barplot(gut_long, "", "gut_microbiome_plot.png")

generate_barplot <- function(data, title, output_filename) {
  num_species <- length(unique(data$Species))  # Get number of unique species
  custom_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00",
                     "#FFFF33", "#A65628", "#F781BF", "dodgerblue", "#66C2A5",
                     "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#B3B3B3",
                     "#E5C494", "#1F78B4", "#33A02C")  
  
  p <- ggplot(data, aes(x = SampleID, y = Abundance, fill = Species)) +
    geom_bar(stat = "identity", position = "stack") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 14),
          axis.text.y = element_text(size = 14),
          axis.title.x = element_text(size = 16, face = "bold"),
          axis.title.y = element_text(size = 16, face = "bold"),
          legend.position = "right",
          legend.text = element_text(size = 12),
          legend.title = element_text(size = 14, face = "bold")) +
    labs(title = title, x = "", y = "", fill = "Features") +
    scale_fill_manual(values = rep(custom_colors, length.out = num_species))
  
  # Save plot
  ggsave(output_filename, plot = p, width = 10, height = 6, dpi = 300)
  return(p)
}

plot_saliva <- generate_barplot(saliva_long, "", "saliva_microbiome_plot.png")

# Print plots
#print(plot_gut)
#print(plot_saliva)

#### Combine Plots ####
plot_gut + plot_saliva + plot_layout(ncol = 1, guides = "collect") & 
  theme(legend.position = "bottom",
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 16))

plot_grid(plot_gut, plot_saliva, ncol = 1, labels = c("A", "B"))
