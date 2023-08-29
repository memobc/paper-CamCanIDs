# Create Data Summary Table for the Manuscript.
# Final Formatting to be performed in a spreadsheet software (Excel/Google Sheets)
#
# Table S5: How similar are connectomes calculated using data from different
# tasks? Similarity between connectomes was calculated using a Pearson's
# correlation. N = number of subjects with valid scans for both scans in this
# pair, min = minimum Peasrson’s correlation between connectomes in task pair,
# max = maximum Pearson’s correlation between connectomes in task pair, mean =
# average Pearson’s correlation between connectomes in task pair.

# requirements ------------------------------------------------------------

library(tidyverse)
library(officer)
library(flextable)
library(gtsummary)

# input -------------------------------------------------------------------

f  <- c('results/moviesmt.csv', 
        'results/restmovie.csv', 
        'results/restsmt.csv')
df <- map_dfr(f, read_csv)

# tidy --------------------------------------------------------------------

set_flextable_defaults(font.size = 10, font.family = 'arial')

df %>%
  group_by(taskPair) %>%
  summarise(across(similarity, .fns = list(N = length,
                                           min = min, max = max, 
                                           mean = mean, sd = sd))) %>%
  rename_with(.fn = ~str_remove(.x, 'similarity_'),
              .cols = starts_with('similarity')) %>%
  rename(`Task Pair` = taskPair) -> df

df %>%
  flextable() %>%
  colformat_double(digits = 2) %>%
  set_caption(caption = 'Table S5', autonum = FALSE) -> Tbl

save_as_docx(values = list(Tbl),
             align = 'center',
             path = 'TableS5.docx',
             pr_section = prop_section(
                            page_size = page_size(width = 6.5, height = 3, orient = "portait"), 
                            type = "continuous",
                            page_margins = page_mar(bottom = 0, top = 0, right = 0, left = 0)
                          ))
