# Create Data Summary Table for the Manuscript. Final Formatting to be performed
# in a spreadsheet software (Excel/Google Sheets)

# requirements ------------------------------------------------------------

library(tidyverse)
library(corrr)
library(officer)
library(flextable)

# input -------------------------------------------------------------------

df <- read_csv('results/PredictTbl_gsr.csv')

# tidy --------------------------------------------------------------------

df %>%
  select(memoryability, Age, Sex, TotalScore, additional_acer, fd, starts_with('intrinsic')) -> df

# Giving variable names sensible labels
df %>%
  rename(memory = memoryability) %>% 
  rename(ACER = additional_acer, Cattell = TotalScore) %>%
  rename(within = intrinsic_within, between = intrinsic_between, 
         extra = intrinsic_extra, hipp = intrinsic_hipp) -> df

# Dummy Coding Sex; Create Correlation Matrix
df %>%
  mutate(Sex = if_else(Sex == 'FEMALE', 1, 0)) %>%
  correlate(use = "pairwise.complete.obs") %>%
  shave() -> cor_df

# Summary Stats for all Variables of Interest, in a pleasing tidy format
df %>%
  mutate(Sex = if_else(Sex == 'FEMALE', 1, 0)) %>%
  summarise(across(everything(), .fns = list('mean' = ~mean(.x, na.rm = T),
                                             'min' = ~min(.x, na.rm = T),
                                             'max' = ~max(.x, na.rm = T),
                                             'sd' = ~sd(.x, na.rm = T),
                                             'n' = ~sum(!is.na(.x))))) %>%
  pivot_longer(everything(), names_to = c("rowname", "stat"), names_sep = "_") %>%
  pivot_wider(names_from = 'stat', values_from = 'value') %>%
  rename(Variable = rowname) -> StatSummaryTbl

StatSummaryTbl$sd[3] <- NA

# Join the summary statistics table with the correlation table
StatSummaryTbl %>%
  left_join(., cor_df, by = c('Variable' = 'term')) %>%
  select(-hipp) -> StatSummaryTbl

set_flextable_defaults(font.size = 8, font.family = 'arial')

StatSummaryTbl %>%
  flextable(cwidth = 0.58, cheight = 0.1) %>%
  add_header_row(values = c("", "Correlations"), colwidths = c(6,9)) %>%
  align(part = 'header', align = 'center') %>%
  colformat_double(digits = 2) %>%
  colformat_double(j = 6, digits = 0) %>%
  colformat_double(i = 1, j = 4, digits = 0) %>%
  colformat_double(i = 3, j = 4, digits = 0) %>%
  colformat_double(i = 3, j =3, digits = 0) %>%
  colformat_double(i = c(4,5), j = c(3,4), digits = 0) %>%
  footnote(i = c(3, 4), j = c(1, 6), 
           value = as_paragraph(c('Sex was coded such that Female = 1, Male = 0',
                                  '8 Subjects Missing Cattell Scores')), 
           ref_symbols = c("a", "b")) -> Tbl1

save_as_docx(values = list('Table 1' = Tbl1),
             align = 'center',
             path = 'Table1.docx',
             pr_section = prop_section(
                            page_size = page_size(orient = "landscape"), 
                            type = "continuous"
                          ))
