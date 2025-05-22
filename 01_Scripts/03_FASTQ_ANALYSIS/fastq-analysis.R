#############################
#
#
#   Seqkit analysis
#   Created by Sterling Wright
#   April 8th, 2025
##############################

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(readr)
library(ggpubr)

setwd("$PATH")

# Read the dataset
df <- read.csv("SEQkit-stats-results.csv", header = TRUE)

# Define custom fill colors for Phenotype
sampletype_colors <- c(
  "Gut" = "brown",
  "Saliva" = "dodgerblue"
)

# Convert num_seqs to numeric (if needed)
df$num_seqs <- as.numeric(gsub(",", "", df$num_seqs))

# Define custom colors
phenotype_colors <- c("Gut" = "brown", "Saliva" = "dodgerblue")

#### Number of sequences per sample type ####
p1<-ggplot(df, aes(x = SampleType, y = num_seqs, fill = SampleType)) +
  geom_violin(trim = FALSE, color = NA, alpha = 0.7) +  # Violin without border
  geom_jitter(aes(color = SampleType), width = 0.2, size = 2, alpha = 0.8) +  # Overlay jittered points
  scale_fill_manual(values = phenotype_colors) +
  scale_color_manual(values = phenotype_colors) +
  labs(y = "Number of Sequences", x = NULL) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
    axis.text.y = element_text(angle = 90, hjust = 1, size = 11),
    axis.title.y = element_text(size = 14),
    legend.position = "none"
  )

#### Median fragment lengths #### 
p2<-ggplot(df, aes(x = SampleType, y = Q2, fill = SampleType)) +
  geom_violin(trim = FALSE, color = NA, alpha = 0.7) +  # Violin without border
  geom_jitter(aes(color = SampleType), width = 0.2, size = 2, alpha = 0.8) +  # Overlay jittered points
  scale_fill_manual(values = phenotype_colors) +
  scale_color_manual(values = phenotype_colors) +
  labs(y = "Median Fragment Lengths (Q2)", x = NULL) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
    axis.text.y = element_text(angle = 90, hjust = 1, size = 11),
    axis.title.y = element_text(size = 14),
    legend.position = "none"
  )


#### GC Content (%) #### 
p3<-ggplot(df, aes(x = SampleType, y = df$GC..., fill = SampleType)) +
  geom_violin(trim = FALSE, color = NA, alpha = 0.7) +  # Violin without border
  geom_jitter(aes(color = SampleType), width = 0.2, size = 2, alpha = 0.8) +  # Overlay jittered points
  scale_fill_manual(values = phenotype_colors) +
  scale_color_manual(values = phenotype_colors) +
  labs(y = "GC Content (%)", x = NULL) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
    axis.text.y = element_text(angle = 90, hjust = 1, size = 11),
    axis.title.y = element_text(size = 14),
    legend.position = "none"
  )


# Generate boxplots



# Create a combined figure with one legend
combined_plot <- ggarrange(
  p1, p2, p3,
  ncol = 2, nrow = 2,  # Arrange in a 2x2 grid
  labels = c("A", "B", "C"),  # Add subplot labels
  font.label = list(size = 14, face = "bold"),  # Style the labels
  common.legend = TRUE,  # Use a common legend
  legend = "bottom"  # Position the legend at the bottom
)

# Display the combined plot
print(combined_plot)

#### Analysis ####

# Assuming your dataframe is named `df`
df_summary <- df %>%
  group_by(SampleType) %>%
  summarise(
    mean_Q2 = mean(Q2, na.rm = TRUE),
    sd_Q2 = sd(Q2, na.rm = TRUE),
    mean_GC = mean(GC..., na.rm = TRUE),
    sd_GC = sd(GC..., na.rm = TRUE),
    mean_numberofsequences = mean(num_seqs, na.rm = TRUE),
    sd_numberofsequences = sd(num_seqs, na.rm = TRUE)
  )

print(df_summary)
