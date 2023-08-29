baseFig <- function (x, aesDef){
  
  ggplot(x, aesDef) +
    geom_tile(color = 'black') +
    scale_x_discrete(position = 'top', limits = networks_alt_order$Network) +
    scale_y_discrete(position = 'left', limits = rev(networks_alt_order$Network)) +
    expand_limits(y = c(0,22)) +
    geom_text(data = diagLabels, aes(x = x, y = y, label = text, fill = NULL), 
              angle = 90, hjust = 0.1, vjust = 0.4, size = 12/.pt, family = 'Times', fontface = 'plain', color = 'black')  +
    theme(aspect.ratio = 1,
          axis.title = element_blank(),
          axis.text.y = element_text(colour = 'black', size = 12, family = 'Times', face = 'plain'),
          axis.ticks = element_blank(),
          panel.background = element_blank(),
          axis.text.x = element_blank())
}