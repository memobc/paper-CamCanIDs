# Create Figure S2 and Figure S3
#
# Figure S2: Number of connections that entered our predictive model. For each
# pair of our networks of interest, we calculated the number of connections that
# positively correlated with memory ability at a p < 0.01 (our connection
# selection threshold, see text) and subtracted the number of connections that
# negatively correlated with memory ability at a p < 0.01. See Schaefer (2018)
# for the description of each network.
#
# Figure S3: Proportion of connections that entered our predictive model. For
# each pair of our networks of interest, we calculated the proportion of
# connections (of all possible connections involving that pair) that positively
# correlated with memory ability at a p < 0.01 (our connection selection
# threshold, see text) and subtracted the proportion of connections that
# negatively correlated with memory ability at a p < 0.01. See Schaefer (2018)
# for the description of each network.

# requirements ------------------------------------------------------------

library(tidyverse)
library(patchwork)
library(scales)
library(corrr)
source('functions/stetchify.R')
source('functions/baseFig.R')

# inputs ------------------------------------------------------------------

networks_alt_order <- read_csv(file = 'results/networks.txt', col_names = c('Network'))

diff <- read_csv(file = 'results/diff.txt', col_names = networks$Network)

count <- read_csv(file = 'results/count.txt', col_names = networks$Network)

# tidy --------------------------------------------------------------------

diff %>% 
  stretchify() %>%
  rename(count = r) -> diff

count %>% 
  stretchify() %>%
  rename(total = r) -> count

left_join(diff, count) %>%
  mutate(scaled = count/total*100) -> scaled.df

# figure ------------------------------------------------------------------

diagLabels <- tibble(x = seq(1,18,1), y = seq(19,2,-1), text = networks_alt_order$Network)

baseFig(diff, aes(x = x, y = y, fill = count)) +
  scale_fill_gradient2(low = muted('blue'), 
                       high = muted('red'), 
                       guide = guide_colourbar(barwidth = 0.5,
                                               barheight = 6),
                       name = '# p<0.01')

ggsave(filename = 'figures/FigureS2.png',
       plot = last_plot(), 
       height = 5, 
       width = 7, 
       units= 'in', 
       dpi = 600)

baseFig(scaled.df, aes(x = x, y = y, fill = scaled)) +
  scale_fill_gradient2(low = muted('blue'),
                       high = muted('red'),
                       guide = guide_colourbar(barwidth = 0.5,
                                               barheight = 6),                       
                       name = '% p<0.01')

ggsave(filename = 'figures/FigureS3.png',
       plot = last_plot(), 
       height = 5, 
       width = 7, 
       units= 'in', 
       dpi = 600)
