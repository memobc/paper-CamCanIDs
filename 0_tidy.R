#---- Create Behavioral Data Frame
# For further analysis in R studio

#-- packages
library(tidyverse)

#-- parameters
CamCan.dir <- '/mmfs1/data/kurkela/Desktop/CamCan/'
Cattell.dir <- file.path(CamCan.dir,'sourcedata/cc700-scored/Cattell/release001/summary')
EmotionalMemory.dir <- file.path(CamCan.dir, 'sourcedata/cc700-scored/EmotionalMemory/release001/summary')

#-- Calculate MRI Data Present/Absent

# list ALL files in the MRI data folder
MRI.bids.dir <- file.path(CamCan.dir, 'sourcedata/cc700/mri/pipeline/release004/BIDS_20190411')
MRI.dirs     <- list.files(path = MRI.bids.dir, pattern = '.nii.gz', recursive = TRUE)

# figure out which types of images there are
tibble(MRI.dirs) %>%
  mutate(CCID = str_extract(MRI.dirs, 'CC[0-9]{6}')) %>%
  mutate(type = str_extract(MRI.dirs, '^.*(?=/sub-CC[0-9]{6}/)')) %>%
  filter(str_detect(type, 'tmp', negate = T)) %>%
  mutate(image = str_extract(MRI.dirs, '(T1w)|(T2w)|(echo[0-5])|(run-0[1-2])')) -> df.MRI

# figure out which participants are missing images
df.MRI %>%
  mutate(present = TRUE) %>% 
  complete(nesting(type,image), CCID, fill = list(present = FALSE)) -> df.MRI

df.MRI %>% 
  select(-MRI.dirs) %>% 
  pivot_wider(names_from = c(type, image), values_from = present) -> df.MRI

#-- Standard Data
# Standard data contains data on age, gender, and handedness
Standard.File <- file.path(CamCan.dir, 'sourcedata/dataman/useraccess/processed/Maureen_Ritchey_1016/standard_data.csv')
df.Sta        <- read_csv(file = Standard.File, col_type = 'cdcdcd')

#-- Additional Data
# Additional data on memory, attention, etc.
Additional.File <- file.path(CamCan.dir, 'sourcedata/dataman/useraccess/processed/Maureen_Ritchey_1016/approved_data.tsv')
df.Add          <- read_tsv(file = Additional.File)

#-- Weschler Memory Data
# Logical Portion of the Weschler Memory Scale
Weschler.File <- file.path(CamCan.dir, 'new_sourcedata/dataman/useraccess/processed/Maureen_Ritchey_1109/approved_data.tsv')
df.Weschler   <- read_tsv(file = Weschler.File)

#-- Cattel Data

Cattell.Summary.File <- file.path(Cattell.dir, 'Cattell_summary.txt')

# First 8 columns are comments; 660 records according to these comments
df.Cat <- read_tsv(file = Cattell.Summary.File, skip = 8, col_type = 'cdddddddc', n_max = 660)

#-- Emotional Memory
Emotion.File <- file.path(EmotionalMemory.dir, 'EmotionalMemory_summary.txt')
df.Emo       <- read_tsv(file = Emotion.File, skip = 8, n_max = 330)

# Select only detail recall columns
df.Emo %>% 
  select(CCID, starts_with('Det')) -> df.Emo

# Calculate a the total number of detailed recalls
df.Emo %>% 
  rowwise() %>% 
  mutate(TotalDetRecalls = sum(c_across(starts_with('Det')))) -> df.Emo

# gross motion
mriqc.dir <- '/mmfs1/data/kurkela/Desktop/CamCan/derivatives/mriqc'
files     <- list.files(path = mriqc.dir, pattern = '\\.json$', recursive = TRUE, full.name = TRUE)

files %>%
  str_subset(., 'anat', negate = TRUE) -> files

map(files, jsonlite::fromJSON) %>%
  map_dbl(., ~.x$fd_perc) -> fd_perc

map(files, jsonlite::fromJSON) %>%
  map_dbl(., ~.x$fd_mean) -> fd_mean

files %>% str_extract(., 'sub-CC[0-9]{6}')       -> subj
files %>% str_extract(., '(?<=task-)[a-z]{3,5}') -> task
files %>% str_extract(., '(?<=echo-)[0-9]')      -> echo

tibble(fd_perc = fd_perc, fd_mean = fd_mean, CCID = subj, task = task, echo = echo, file = files) -> motion.df

write_rds(motion.df, 'motion.rds')

# stitch all of the dataframes together
left_join(df.MRI, df.Emo, by = 'CCID') %>%
  left_join(., df.Sta, by = 'CCID') %>%
  left_join(., df.Cat, by = 'CCID') %>%
  left_join(., df.Add, by = 'CCID') %>%
  left_join(., df.Weschler, by = 'CCID') -> df

write_rds(df, 'data.rds')
