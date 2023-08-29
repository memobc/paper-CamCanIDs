# Create Figure 3
#
# Figure 3: Evaluating Feature Importance. The partial correlation of connection
# strength with memory ability after controlling for age, sex, and average
# in-scanner motion. See Schaefer (2018) for the description of each network.

# requirements ------------------------------------------------------------

library(tidyverse)
library(patchwork)
library(scales)
library(corrr)
source('functions/stetchify.R')
source('functions/baseFig.R')

# inputs ------------------------------------------------------------------

networks_alt_order <- read_csv(file = 'results/networks.txt', col_names = c('Network'))

networks_alt_order %>%
  slice(1:15,17,16,18) -> networks_alt_order

networks <- read_csv(file = 'results/gradmean_networks.txt', col_names = c('Network'))

corr_with_behv_downsample <- read_csv(file = 'results/downsampled_corr_with_behav_mat.txt', col_names = networks$Network)

# tidy --------------------------------------------------------------------

corr_with_behv_downsample %>% 
  stretchify() %>%
  rename(corr = r) -> corr_with_behv_downsample

# figure ------------------------------------------------------------------

# Panel C

diagLabels <- tibble(x = seq(1,18,1), y = c(seq(20,5,-1), 3,2), text = networks_alt_order$Network)

yaxisLimits <- rev(networks_alt_order$Network)

yaxisLimits <- c(yaxisLimits[1:2], NA, yaxisLimits[3:18])

yaxisLimits %>%
  str_replace_na(., replacement = '') -> yaxisLabels

ggplot(corr_with_behv_downsample, aes(x = x, y = y, fill = corr)) +
  geom_tile(color = 'black') +
  scale_x_discrete(position = 'top', limits = networks_alt_order$Network) +
  scale_y_discrete(limits = yaxisLimits, labels = yaxisLabels) +
  expand_limits(y = c(0,24)) +
  geom_text(data = diagLabels, aes(x = x, y = y, label = text, fill = NULL), 
            angle = 90, hjust = 0.05, vjust = 0.4, size = 12/.pt, color = 'black')  +
  theme(aspect.ratio = 1,
        axis.title = element_blank(),
        axis.text.y = element_text(colour = 'black', size = 12),
        axis.ticks = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_blank()) +
  scale_fill_gradient2(n.breaks = 7,
                       breaks = c(0.075, 0, -0.075),
                       low = muted('blue'),
                       high = muted('red'),
                       name = bquote(r['memory']))

# output ------------------------------------------------------------------

ggsave(filename = 'figures/Figure3.png',
       plot = last_plot(), 
       height = 6.42, 
       width = 9, 
       units= 'in', 
       dpi = 600)
