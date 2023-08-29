# R script for fixing the BIDS formatting of the CamCan MRI data

library(tidyverse)
library(jsonlite)
library(assertthat)

# all of the data, as recieved from CamCan admins
source.data <- '/mmfs1/data/kurkela/Desktop/CamCan/sourcedata'

# subdirectory containing just the MRI data
source.mri <- file.path(source.data, 'cc700')

x <- list.files(path = source.mri, recursive = TRUE, full.names = TRUE)

#-- setup bids directory structure

raw.data <- '/mmfs1/data/kurkela/Desktop/CamCan/rawdata'

## Step 1: Create Subject subdirectories

subj.ids <- x %>% str_extract(., 'sub-CC[0-9]{6}') %>% unique()
str_c(raw.data, subj.ids, sep = '/') %>%
    walk(., ~if(!dir.exists(.x)){dir.create(.x)}) -> raw.data.subjs

## Step 2: Create scan subdirectories

scan.type.dirs <- c('anat', 'func')

map(.x = raw.data.subjs, .f = ~str_c(.x, scan.type.dirs, sep = '/')) %>%
 unlist() %>%
 walk(., ~if(!dir.exists(.x)){dir.create(.x)}) -> raw.data.scans

## Step 3: Anat Files
# The anatomic files are labeled correctly. No filename changing required. Simply need to sort them into the correct directory
# in the new directory structure

copy_anat <- function(from){
 # copy anatomic images
 # from is the original file name
 
 subj <- str_extract(from, 'sub-CC[0-9]{6}')
 if(is.na(subj)){return()}
 filename <- basename(from)
 
 to <- file.path(raw.data, subj, 'anat', filename)

 assert_that(dir.exists(dirname(to)), msg = 'directory doesnt exist')
 
 file.copy(from = from, to = to, overwrite = FALSE)

}

anat.files <- str_subset(x, 'anat')

anat.files %>%
  str_subset(., 'sub-CC[0-9]{6}', negate = TRUE) -> unsorted_files

anat.files %>%
  str_subset(., 'sub-CC[0-9]{6}') %>%
  walk(., copy_anat)

## Step 4 Copy Functional Files

# select all functional BOLD files. Each of these files should have
# "epi" somewhere in the filepath
func.files <- x %>% str_subset(., 'epi')

# store files not in the subject subdirectories as unsorted files
func.files %>%
  str_subset(., 'sub-CC[0-9]{6}', negate = TRUE) %>%
  c(unsorted_files, .) -> unsorted_files

copy_func <- function(from){
 # copy functional files
 # from is the original full path to file
 subj <- str_extract(from, 'sub-CC[0-9]{6}')
 task <- str_extract(from, '(?<=epi_)[a-z]{3,5}')
 echo <- str_extract(from, '(?<=echo)[0-9]')
 events <- str_extract(from, '_onsets')

 og_filename <- basename(from)

 og_filename %>% str_extract(., '\\..*$') -> ext

 if(!is.na(events)){
   filename <- str_glue('{subj}_task-{task}_events{ext}')
 } else if(is.na(echo)){
   filename <- str_glue('{subj}_task-{task}_bold{ext}')
 } else {
   filename <- str_glue('{subj}_task-{task}_echo-{echo}_bold{ext}')
 }

 to <- file.path(raw.data, subj, 'func', filename)

 assert_that(dir.exists(dirname(to)), msg = 'directory doesnt exist')

 file.copy(from = from, to = to, overwrite = FALSE)

}

fix_events <- function(x){
  # fix events tsvs
  df <- read_tsv(x, col_types = 'dcd-') %>%
        select(onset, duration, trial_type)

 subj <- str_extract(x, 'sub-CC[0-9]{6}')
 task <- str_extract(x, '(?<=epi_)[a-z]{3,5}')
 echo <- str_extract(x, '(?<=echo)[0-9]')
 events <- str_extract(x, '_onsets')

 og_filename <- basename(x)

 og_filename %>% str_extract(., '\\..*$') -> ext

 filename <- str_glue('{subj}_task-{task}_events{ext}')

 to <- file.path(raw.data, subj, 'func', filename)
 
 assert_that(dir.exists(dirname(to)), msg = 'directory doesnt exist')

 write_tsv(df, path = to, na = 'n/a')

}

func.files %>%
  str_subset(., 'onsets') %>%
  walk(., fix_events)

func.files %>%
  str_subset(., 'sub-CC[0-9]{6}') %>%
  str_subset(., 'onsets', negate = T) %>%
  walk(., copy_func)

## Step 5 Copy Field Map Files

x %>%
  str_subset(., 'fmap') -> fmap.files

fmap.files %>%
  str_subset(., 'tmp') %>%
  c(unsorted_files, .) -> unsorted_files

fmap.files %>%
  str_subset(., 'sub-CC[0-9]{6}', negate = TRUE) %>%
  c(unsorted_files, .) -> unsorted_files

copy_fmap <- function(fmap.files){
  # input is a data.frame of fmap files for this subject
   
 subj <- str_extract(from, 'sub-CC[0-9]{6}')
 task <- str_extract(from, '(?<=fmap_)[a-z]{3,5}')
 run  <- str_extract(from, '(?<=run-)[0-9]{2}')

 og_filename <- basename(from)

 og_filename %>% str_extract(., '\\..*$') -> ext

 filename <- str_glue('{subj}_task-{task}_run-{run}_fieldmap{ext}')

 to <- file.path(raw.data, subj, 'func', filename)

 file.copy(from = from, to = to, overwrite = FALSE)

}

#fmap.files %>% 
#  str_subset(., 'tmp', negate = TRUE) %>% 
#  str_subset(., 'sub-CC') %>% 
#  tibble(fmap.file = .) %>% 
#  mutate(subj = str_extract(fmap.file, 'sub-CC[0-9]{6}')) %>% 
#  nest(data = fmap.file) %>%
#  mutate(fmap.file = walk(fmap.file, copy_fmap))

## Fix unsorted files

# participants.tsv
unsorted_files %>%
  str_subset(., '.tsv') %>%
  map(., read_tsv) -> TSVs

joinedTbl <- TSVs[[1]]
for(i in 2:length(TSVs)){
  joinedTbl <- full_join(joinedTbl, TSVs[[i]])
}

out <- file.path(raw.data, 'participants.tsv')

write_tsv(x = joinedTbl, path = out, na = "n/a")


# dataset_description
# Create dataset_description JSON file

unsorted_files %>%
  str_subset(., 'description') %>%
  map(., jsonlite::fromJSON) %>%
  map(., as_tibble) -> O

joinedTbl <- O[[1]]
for(i in 2:length(O)){
  joinedTbl <- full_join(joinedTbl, O[[i]])
}

joinedTbl %>%
  select(Name, BIDSVersion) %>%
  transmute(Name = unbox('CamCan'), BIDSVersion = unbox('v1.6.0')) %>%
  write_json(., path = file.path(raw.data, 'dataset_description.json'), pretty = TRUE, dataframe = 'columns')

# README
# Create short README file

write_lines(x = 'CamCan Data -- Fixed BIDS', path = file.path(raw.data, 'README'))

# Write Task json files
# -- task-movie_bold.json
# -- task-rest_bold.json
# -- task-smt_bold.json

tibble(TaskName = unbox('movie')) %>%
  write_json(., path = file.path(raw.data, 'task-movie_bold.json'), pretty = TRUE, dataframe = 'columns')

tibble(TaskName = unbox('rest')) %>%
  write_json(., path = file.path(raw.data, 'task-rest_bold.json'), pretty = TRUE, dataframe = 'columns')

tibble(TaskName = unbox('smt')) %>%
  write_json(., path = file.path(raw.data, 'task-smt_bold.json'), pretty = TRUE, dataframe = 'columns')
