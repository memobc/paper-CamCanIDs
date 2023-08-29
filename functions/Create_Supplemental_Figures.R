# Create Figure 5
# 
# Figure 5. Closer examination of hippocampal connections. Which hippocampal
# connections are driving performance in the CBPM? CBPM uses connections that
# are significantly correlated with the outcome in order to predict left out
# subjects (see Shen et al. 2017). This figure displays A.) the direction of the
# relationship of the statistically significant connections and B.) the
# percentage of hippocampal connections with each of the 17 networks from the
# Schefaer atlas (Schaefer et al. 2017) that are statistically significant after
# controlling for age, sex, and framewise displacement at our p < 0.01
# threshold. Hippocampal connections tend to be inversely related to memory
# ability and connections with visual, attentional, and somatomotor networks
# appear to drive performance of the hippocampal-only CBPM model.

# requirements ------------------------------------------------------------

library(tibble)
library(stringr)
library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(ggbeeswarm)

# inputs ------------------------------------------------------------------

# hippocampal connections only
hipp_connections          <- read_csv(file = 'hipp_connections_partialCorr.txt', col_names = FALSE)
hipp_connections_isSignif <- read_csv(file = 'newresults/onlyHipp_sig.txt', col_names = FALSE)

# from the Schaefer atlas
ROI_info <- read_csv(file = 'atlas/Parcellations/MNI/Centroid_coordinates/Schaefer2018_400Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv')

# tidy --------------------------------------------------------------------

# manually add the hipp rois
ROI_info %>%
  add_row(`ROI Label` = c(401,402,403,404,405,406), 
          `ROI Name` = c('LH_HIPP_BODY', 'RH_HIPP_BODY', 'LH_HIPP_HEAD', 'RH_HIPP_HEAD', 'LH_HIPP_TAIL', 'RH_HIPP_TAIL')) %>%
  mutate(`ROI Name` = str_remove(`ROI Name`, '17Networks_')) %>%
  mutate(Network = str_remove(`ROI Name`, '_[0-9]*$')) %>%
  separate(Network, into = c('hemisphere', 'network', 'label'), sep = '_') -> ROI_info

# tidy hippocampal connections matrix
hipp_connections %>%
  add_column(connect_from = c('LH_HIPP_BODY', 'RH_HIPP_BODY', 'LH_HIPP_HEAD', 'RH_HIPP_HEAD', 'LH_HIPP_TAIL', 'RH_HIPP_TAIL')) %>%
  pivot_longer(cols = -connect_from, names_to = 'connect_to', values_to = 'corr_connect_memAbil') %>%
  mutate(connect_to = str_remove(connect_to, 'X'),
         connect_to = as.double(connect_to)) %>%
  left_join(., ROI_info, by = c('connect_to' = 'ROI Label')) -> hipp_connections

# tidy some more
hipp_connections %>%
  mutate(corr_connect_memAbil_z = atanh(corr_connect_memAbil)) %>%
  separate(connect_from, into = c('connect_from_hemisphere', 'connect_from_region'), sep = 3) -> hipp_connections

# tidy
hipp_connections_isSignif %>%
  add_column(connect_from = c('LH_HIPP_BODY', 'RH_HIPP_BODY', 'LH_HIPP_HEAD', 'RH_HIPP_HEAD', 'LH_HIPP_TAIL', 'RH_HIPP_TAIL')) %>%
  pivot_longer(cols = -connect_from, names_to = 'connect_to', values_to = 'is_signif') %>%
  mutate(connect_to = str_remove(connect_to, 'X'),
         connect_to = as.double(connect_to)) %>%
  left_join(., ROI_info, by = c('connect_to' = 'ROI Label')) -> hipp_connections_isSignif

# tidy some more
hipp_connections_isSignif %>%
  separate(connect_from, into = c('connect_from_hemisphere', 'connect_from_region'), sep = 3) -> hipp_connections_isSignif

left_join(hipp_connections, hipp_connections_isSignif) -> hipp_connections

# figure ------------------------------------------------------------------

## Comparing Hipp Subsections
ggplot(hipp_connections, aes(x = connect_from_hemisphere, y = corr_connect_memAbil_z)) +
  geom_quasirandom(alpha = 1) +
  geom_boxplot(alpha = 1) +
  facet_grid(col = vars(connect_from_region)) +
  scale_x_discrete(labels = c('left','right')) +
  labs(x = 'Hemisphere', y = 'Z', title = 'Cor(Connection, Memory)', subtitle = 'Controlling for age, sex, fd')

ggsave(filename = 'hipp_connections_breakdown.svg', plot = last_plot(), width = 8, height = 4, units = 'in')

# figure ------------------------------------------------------------------

## Comparing connections to different networks
hipp_connections %>%
  mutate(network = factor(network, levels = unique(ROI_info$network))) -> hipp_connections

ggplot(hipp_connections, aes(x = network, y = corr_connect_memAbil_z)) +
  theme(axis.text.x = element_text(angle= 90)) +
  geom_quasirandom(alpha = 0.3) +
  geom_boxplot(alpha = 0.7) +
  facet_grid(rows = 'hemisphere', labeller = label_both)

ggsave(filename = 'hipp_connect_to_breakdown.svg', plot = last_plot(), width = 8, height = 4, units = 'in')
