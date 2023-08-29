stretchify <- function(x){
  
  x %>%
    as.matrix() %>%
    magrittr::set_rownames(value = networks$Network) -> df
  
  df[networks_alt_order$Network,networks_alt_order$Network] -> df
  
  df %>%
    diag() -> the.diagonal
  
  df %>%
    as.matrix() %>%
    as_cordf() %>% 
    shave() %>% 
    stretch(na.rm = T) %>%
    add_row(x = networks_alt_order$Network, y = networks_alt_order$Network, r = the.diagonal) -> df
  
  return(df)
  
}