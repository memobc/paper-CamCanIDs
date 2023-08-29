# Generate Figure S4
# 
# Figure S4: CBPM results are robust to selection of connection selection
# threshold in the CBPM analysis. Red diamonds indicate observed results, black
# dots indicate results of 100 null simulations. *** p <= 0.001, ** p <= 0.01, *
# p <= 0.05, ns = p > 0.05.

# requirements ------------------------------------------------------------

library(tidyverse)
library(readr)
library(ggplot2)
library(ggbeeswarm)
library(patchwork)

# inputs ------------------------------------------------------------------

df         <- read_csv('results/cbpm_results.csv')
df.null    <- read_csv('results/nullsims.csv')

# tidy --------------------------------------------------------------------

# Add significance stars
df %>%
  mutate(pstar = case_when(p <= 0.1 & p > 0.05 ~ '~',
                           p <= 0.05 & p > 0.01 ~ '*',
                           p <= 0.01 & p > 0.001 ~ '**',
                           p <= 0.001 ~ '***',
                           TRUE ~ 'ns')) -> df

# figure ------------------------------------------------------------------

df %>% 
  filter(analysis == 'cbpm' & outcome == 'memoryability' & connections == 'all' & partialCor == 'age+sex+fd' & connectome == 'gsr') -> df

df.null %>%
  filter(analysis == 'cbpm' & outcome == 'memoryability' & connections == 'all' & partialCor == 'age+sex+fd' & connectome == 'gsr') -> df.null

ggplot(df, aes(x = factor(thresh), y = results)) +
  geom_quasirandom(data = df.null, aes(y = R), width = 0.3, size = 0.15) +
  geom_point(shape = 'diamond filled', fill = 'red', size = 1.5) +
  geom_label(aes(label = pstar, y = results + 0.15), size = 5/.pt) +
  scale_y_continuous(limits = c(-.35,.35), breaks = seq(-.5, .5, .1)) +
  #scale_x_discrete(limits = c('none', 'age+sex+fd')) +
  labs(y = bquote(r['obs,pred']), title = 'CBPM Results', x = 'Connection Selection Threshold (p < #)') +
  theme_light(base_size = 8) +
  theme(aspect.ratio = .25, axis.text.x = element_text(angle = 90, vjust = 0.25, hjust = 1))

ggsave(filename = 'FigureS4.png',
       plot = last_plot(),
       height = 2.5,
       width = 6.5,
       units= 'in')
