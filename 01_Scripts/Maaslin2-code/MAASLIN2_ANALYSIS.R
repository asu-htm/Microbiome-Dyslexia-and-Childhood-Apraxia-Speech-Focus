
getwd()

setwd("/Users/miajoslin/Desktop/ASU /MSGH Stuff /ASB 584 /Sterling Lab /")
install.packages("devtools")
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("Maaslin2")

library("devtools")
library(Maaslin2)

# Import data

# Load the data
data <- read.csv("SPECIES_TABLE_GSR.csv", header = TRUE, sep = ",", row.names = 1)

metadata<-read.csv("METADATA.csv", header = TRUE, sep = ",", row.names = 1)

set.seed(1)

metadata$Phenotype <-
  factor(metadata$Phenotype, levels = c('Typical', 'Apraxia_of_speech', 'Dyslexia'))

fit_out <- Maaslin2(input_data = data,
                    input_metadata = metadata,
                    output = 'GSR_OUTPUT',
                    fixed_effects = c('Phenotype'),
                    max_significance = 0.05
                    )


data <- read.csv("SPECIES_TABLE_SILVA.csv", header = TRUE, sep = ",", row.names = 1)

metadata<-read.csv("METADATA.csv", header = TRUE, sep = ",", row.names = 1)

set.seed(1)

metadata$Phenotype <-
  factor(metadata$Phenotype, levels = c('Typical', 'Apraxia_of_speech', 'Dyslexia', 'Unknown'))

fit_out <- Maaslin2(input_data = data,
                    input_metadata = metadata,
                    output = 'SILVA_OUTPUT',
                    fixed_effects = c('Phenotype'),
                    max_significance = 0.05
)

data <- read.csv("SPECIES_TABLE_MIMT.csv", header = TRUE, sep = ",", row.names = 1)

metadata<-read.csv("METADATA.csv", header = TRUE, sep = ",", row.names = 1)

set.seed(1)

metadata$Phenotype <-
  factor(metadata$Phenotype, levels = c('Typical', 'Apraxia_of_speech', 'Dyslexia'))

fit_out <- Maaslin2(input_data = data,
                    input_metadata = metadata,
                    output = 'MIMT_OUTPUT',
                    fixed_effects = c('Phenotype'),
                    max_significance = 0.05
)

data <- read.csv("SPECIES_TABLE_SILVA.csv", header = TRUE, sep = ",", row.names = 1)

metadata<-read.csv("METADATA.csv", header = TRUE, sep = ",", row.names = 1)

set.seed(1)

metadata$Phenotype <-
  factor(metadata$Phenotype, levels = c('Typical', 'Apraxia_of_speech', 'Dyslexia'))

fit_out <- Maaslin2(input_data = data,
                    input_metadata = metadata,
                    output = 'SILVA_OUTPUT',
                    fixed_effects = c('Phenotype'),
                    max_significance = 0.05
)
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.17")  # Adjust to match your R version

if(!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("Maaslin2")



fit_data = Maaslin2(
  input_data = transposed_data, 
  input_metadata = metadata, 
  output = "Maaslin2-Sleep-adjusted", 
  fixed_effects = c("NT_over_24T"),
  max_significance = 0.25,
  min_prevalence = 0.001,
  analysis_method = "LM")

devtools::install_github("biobakery/Maaslin2")
library(Maaslin2)

