library(tidyverse)
library(ggbeeswarm)
library(patchwork)

df <- read_csv('numconnections.csv')

#df %>%
#  pivot_longer(cols = numpos:numneg, names_to = 'positive_negative', values_to = 'number_connections') -> df

ggplot(df, aes(x = partialCor, y = numpos)) +
  geom_quasirandom() +
  scale_x_discrete(limits = c('none', 'age', 'fd', 'acer', 'age+fd', 'age+fd+acer')) +
  scale_y_continuous(breaks = seq(0,9000,2000)) +
  expand_limits(y = c(0, 9000)) +
  labs(x = 'Controlling for...', y = '# Connections', caption = 'Threshold = 0.01', title = 'Negatively Correlated w/ Memory') -> p1

ggplot(df, aes(x = partialCor, y = numneg)) +
  geom_quasirandom() +
  scale_x_discrete(limits = c('none', 'age', 'fd', 'acer', 'age+fd', 'age+fd+acer')) +
  scale_y_continuous(breaks = seq(0,40,10)) +
  expand_limits(y = c(0, 40)) +
  labs(x = 'Controlling for...', y = '# Connections', caption = 'Threshold = 0.01', title = 'Postively Correlated w/ Memory') -> p2

p1 + p2 + plot_layout(ncol = 1, nrow = 2)
