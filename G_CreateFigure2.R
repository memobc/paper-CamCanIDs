# Create Figure 2 from the manuscript
#
# Figure 2: Relationships between memory ability and intrinsic functional 
# connectivity among memory networks. Scatter plots and best fit linear 
# regression line of memory ability on average intrinsic connection strength 
# A) among DMN-C regions, B) between DMN-C and DMN-A regions, C) DMN-C and all 
# other regions, and D) the Hippocampus and all regions. There was little 
# evidence to suggest that the strength of these connections was predictive 
# of individual differences in memory ability.

# requirements ------------------------------------------------------------

library(tidyverse)
library(patchwork)

# input -------------------------------------------------------------------
# PredictTbl. Created by C_tidy.m

PredictTbl <- read_csv('results/PredictTbl_gsr.csv')

PredictTbl %>%
  rename(within  = intrinsic_within,
         between = intrinsic_between,
         extra   = intrinsic_extra,
         hipp    = intrinsic_hipp) -> PredictTbl

# create figure -----------------------------------------------------------

point.size <- .5
text.size  <- 8

# Panel A
PredictTbl %>%
  ggplot(aes(x = within, y = memoryability)) +
  geom_point(size = point.size, alpha = 0.5) +
  geom_smooth(formula = y ~ x, method = 'lm') +
  labs(x = 'mean(r)', title = 'DMN-C within',  y = 'memory ability') +
  scale_x_continuous(breaks = c(0.2, 0.3, 0.4, 0.5)) +
  theme_light() +
  theme(aspect.ratio = 1, text = element_text(size = text.size)) -> panelA

# Panel B
ggplot(PredictTbl, aes(x = between, y = memoryability)) +
  geom_point(size = point.size, alpha = 0.5) +
  geom_smooth(formula = y ~ x, method = 'lm') +
  labs(x = 'mean(r)', title = 'DMN-C between', y = 'memory ability') +
  scale_x_continuous(breaks = c(0, 0.1, 0.2, 0.3)) +
  expand_limits(x = c(0, 0.3)) +
  theme_light() +
  theme(aspect.ratio = 1, text = element_text(size = text.size))-> panelB

# Panel C
ggplot(PredictTbl, aes(x = extra, y = memoryability)) +
  geom_point(size = point.size, alpha = 0.5) +
  geom_smooth(formula = y ~ x, method = 'lm') +
  labs(x = 'mean(r)', title = 'DMN-C extra', y = 'memory ability') +
  theme_light() +
  theme(aspect.ratio = 1, text = element_text(size = text.size)) -> panelC

# Panel D
ggplot(PredictTbl, aes(x = hipp, y = memoryability)) +
  geom_point(size = point.size, alpha = 0.5) +
  geom_smooth(formula = y ~ x, method = 'lm') +
  labs(x = 'mean(r)', title = 'Hippocampus', y = 'memory ability') +
  theme_light() +
  theme(aspect.ratio = 1, text = element_text(size = text.size)) -> panelD

# Put it all together
panelA + panelB + panelC + panelD +
  plot_annotation(title = 'Targeted Hypotheses', tag_levels = 'A', tag_suffix = ')') + 
  plot_layout(nrow = 2, ncol = 2) -> figure

# output ------------------------------------------------------------------

ggsave(filename = 'figures/Figure2.png',
       plot = figure,
       width = 5,
       height = 5,
       unit = 'in',
       dpi = 600)
