# Generate Figure 3

# requirements ------------------------------------------------------------

library(tidyverse)
library(readr)
library(ggplot2)
library(ggbeeswarm)
library(patchwork)

# inputs ------------------------------------------------------------------

df         <- read_csv('newresults/cbpm_results.csv')
df.null    <- read_csv('newresults/nullsims.csv')
networks_alt_order <- read_csv(file = 'newresults/networks.txt', col_names = c('Network'))

# tidy --------------------------------------------------------------------

# Add significance stars
df %>%
  mutate(pstar = case_when(p <= 0.1 & p > 0.05 ~ '~',
                           p <= 0.05 & p > 0.01 ~ '*',
                           p <= 0.01 & p > 0.001 ~ '**',
                           p <= 0.001 ~ '***',
                           TRUE ~ 'ns')) -> df

networks_alt_order %>%
  pull(Network) %>%
  str_c('_exclude') -> fctLevels

# figure ------------------------------------------------------------------

df %>% 
  filter(connectome == 'gsr' & connections == 'all' & outcome == 'memoryability' & thresh == 0.01 & 	
           partialCor == 'age+sex+fd') -> df

df.null %>%
  filter(partialCor == 'age+sex+fd' & connectome == 'gsr' & connections == 'all' & outcome == 'memoryability' & thresh == 0.01) -> df.null

df %>% 
  rename(R = results) %>% 
  select(-p, -nsims, -pstar) %>% 
  bind_rows(., df.null, .id = 'highlight') -> df

ggplot(df, aes(x = R, fill = highlight)) +
  #geom_quasirandom(aes(x = '', y = R)) +
  geom_dotplot(binaxis = 'x', binpositions = 'all', stackratio = 1.4, method = 'histodot') +
  theme_classic(base_size = 18) +
  theme(axis.text.y = element_blank(), axis.title.y = element_blank(), axis.ticks.y = element_blank()) +
  labs(x = 'correlation(predicted, observed)') +
  scale_fill_manual(values = c('red', 'black'), 
                    labels = c('observed', 'null simulations'), 
                    name = NULL) +
  scale_x_continuous(breaks = c(-0.2, -0.1, 0, 0.1, 0.2)) +
  expand_limits(x = c(-0.2, 0.2)) +
  theme(legend.position="left")
  
ggsave(filename = '/Users/kylea/OneDrive/Desktop/DissertationFigureHistodot.png',
       plot = last_plot(),
       units = 'in', height = 5, width = 7, dpi = 600)
