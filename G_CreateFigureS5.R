# Generate Figure S5
# 
# Figure S5: How do predictive models built using connectomes from individual
# tasks compare to models built using an “intrinsic” connectome, calculated by
# averaging across tasks? Movie = movie watching, rest = resting-state, smt =
# sensorimotor task.

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
  filter(analysis == 'cbpm' & outcome == 'memoryability' & connectome != 'gsr' & connectome != 'default' & thresh == 0.01 & partialCor == 'age+sex+fd') -> df

df.null %>%
  filter(analysis == 'cbpm' & outcome == 'memoryability' & connectome != 'gsr' & connectome != 'default' & thresh == 0.01 & partialCor == 'age+sex+fd') -> df.null

ggplot(df, aes(x = connectome, y = results)) +
  geom_quasirandom(data = df.null, aes(y = R), width = 0.3, size = 0.15) +
  geom_point(shape = 'diamond filled', fill = 'red', size = 1.5) +
  geom_label(aes(label = pstar, y = results + 0.15), size = 5/.pt) +
  scale_y_continuous(limits = c(-.35,.35), breaks = seq(-.5, .5, .1)) +
  #scale_x_discrete(limits = c('none', 'age+sex+fd')) +
  labs(y = bquote(r['obs,pred']), title = 'Figure S2', x = 'Task') +
  theme_light(base_size = 12) +
  theme(aspect.ratio = .25, axis.text.x = element_text(angle = 90, vjust = 0.25, hjust = 1))

ggsave(filename = 'FigureS5.png',
       plot = last_plot(),
       height = 3.5,
       width = 6.5,
       units= 'in')
