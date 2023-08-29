# Generate Table 2
# 
# Table 2: Computational Lesion Analysis. Excluding networks of regions
# traditionally related to episodic memory ability – i.e., the Default Mode
# Network C and the Hippocampus – have very little impact on model performance.
# Among non memory networks, only excluding Somatomotor Network B regions from
# the analysis resulted in a significant drop in model performance. results =
# Pearson’s correlation between observed and predicted memory ability scores, p
# = proportion of null simulations that were more extreme than observed. See
# Schaefer (2018) for the description of each network.

# requirements ------------------------------------------------------------

library(tidyverse)
library(officer)
library(flextable)

# inputs ------------------------------------------------------------------

df         <- read_csv('results/cbpm_results.csv')
df.null    <- read_csv('results/nullsims.csv')
networks_alt_order <- read_csv(file = 'results/networks.txt', col_names = c('Network'))

# tidy --------------------------------------------------------------------

# Add significance stars

networks_alt_order %>%
  pull(Network) %>%
  str_c('_exclude') -> fctLevels

# table  ------------------------------------------------------------------

df %>%
  filter(connectome != 'default') %>%
  filter(connections != 'all') %>%
  mutate(connections = factor(connections, levels = fctLevels)) %>%
  arrange(connections) %>%
  dplyr::select(-analysis, -connectome, -nsims) %>%
  mutate(results = round(results, digits = 3)) %>%
  rename(analysis = connections) %>%
  flextable() -> Tbl

save_as_docx(values = list('Table 2' = Tbl),
             align = 'center',
             path = 'Table2.docx',
             pr_section = prop_section(
               page_size = page_size(orient = "portrait"),
               type = "continuous"
             ))
