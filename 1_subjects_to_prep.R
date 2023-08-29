# packages
suppressPackageStartupMessages(library(tidyverse))

# parameters
fd_mean_thresh <- 0.3
num_runs_thresh <- 1
age_thresh <- 50

# motion
motion <- read_rds('motion.rds')

motion %>%
  mutate(CCID = str_remove(CCID, 'sub-')) -> motion

# subject numbers df
df <- read_rds('data.rds')

# Determine which scans are corrupted due to motion
motion %>% 
  filter(task == 'movie') %>%
  group_by(CCID) %>%
  summarise(BadMotion = sum(fd_mean > fd_mean_thresh), .groups = 'drop') %>%
  mutate(BadMotion = BadMotion > 1) %>%
  add_column(task = 'movie') -> movie

motion %>%
  filter(task != 'movie') %>%
  mutate(BadMotion = fd_mean > fd_mean_thresh) %>%
  select(CCID, task, BadMotion) %>%
  bind_rows(., movie) %>%
  group_by(CCID) %>%
  summarise(ExcludeMotion = sum(BadMotion) > num_runs_thresh, .groups = 'drop') -> motion.summary

df %>% 
  left_join(., motion.summary, by = 'CCID') %>%
  mutate(ExcludeMotion = if_else(is.na(ExcludeMotion), FALSE, ExcludeMotion)) -> df

# Determine who has missing MRI data
df %>% 
  rowwise() %>% 
  mutate(AnyMissingMRI = !all(c_across(cols = anat_T1w:fmap_smt_NA))) %>% 
  ungroup() -> df

# Determine who is too old to be analyed
df %>%
  ungroup() %>%
  mutate(AgeExclusion = Age > age_thresh) -> df

# Determine who has missing Emotional Memory data
df %>%
  rowwise() %>%
  mutate(AnyMissingEmoMem = is.na(TotalDetRecalls)) -> df

# Determine who has missing Wechler Memory Data
df %>%
  mutate(AnyMissingWechler = any(is.na(homeint_v219), is.na(homeint_v515), is.na(homeint_storyrecall_i), is.na(homeint_storyrecall_d))) -> df

# Determine who has missing Cattell data
df %>%
  mutate(AnyMissingCattell = is.na(TotalScore)) -> df

# Determine who has missing ACR-R data
df %>%
  mutate(AnyMissingAdd = is.na(additional_memory)) -> df

# Determine who meets preliminary inclusion criterion -- no missing data
df %>%
  mutate(MeetsInclusionCriterion = !any(AnyMissingMRI, AnyMissingWechler, AgeExclusion, ExcludeMotion)) -> df

df %>% 
  filter(MeetsInclusionCriterion) %>% 
  pull(CCID) -> subjects_to_prep

write_lines(subjects_to_prep, file = '/mmfs1/scratch/kurkela/subjects_to_prep.txt')
