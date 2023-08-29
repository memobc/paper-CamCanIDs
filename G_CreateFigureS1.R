# Create Figure S1
# 
# Figure S1: Grand mean connectivity matrix. Here we report the grand mean
# functional connectivity matrix, calculated by averaging functional
# connectivity estimates between our networks of interest across all subjects
# included in our analysis. As expected, regions included in the same functional
# network display increased functional connectivity. See Schaefer (2018) for the
# description of each network.

# requirements ------------------------------------------------------------

library(tidyverse)
library(patchwork)
library(scales)
library(corrr)
source('functions/stetchify.R')
source('functions/baseFig.R')

# inputs ------------------------------------------------------------------

networks_alt_order <- read_csv(file = 'results/networks.txt', col_names = c('Network'))

networks <- read_csv(file = 'results/gradmean_networks.txt', col_names = c('Network'))

grand_mean_conn_downsampled <- read_csv(file = 'results/downsampled_grand_connectome.txt', col_names = networks$Network)

# tidy --------------------------------------------------------------------

grand_mean_conn_downsampled %>% 
  stretchify()-> df

# figure ------------------------------------------------------------------

diagLabels <- tibble(x = seq(1,18,1), y = seq(19,2,-1), text = networks_alt_order$Network)

baseFig(df, aes(x = x, y = y, fill = r)) +
  scale_fill_gradient2(low = muted('blue'), 
                       high = muted('red'), 
                       guide = guide_colourbar(nbin = 100, 
                                               barwidth = 0.5,
                                               barheight = 6), 
                       n.breaks = 10)

# output ------------------------------------------------------------------

ggsave(filename = 'figures/FigureS1.png',
       plot = last_plot(), 
       height = 5, 
       width = 7, 
       units= 'in', 
       dpi = 600)
