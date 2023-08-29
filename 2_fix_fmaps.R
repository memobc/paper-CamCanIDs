# R script for fixing the BIDS formatting of the CamCan MRI data

library(tidyverse)
library(jsonlite)
library(assertthat)

# all of the data, as recieved from CamCan admins
source.data <- '/mmfs1/data/kurkela/Desktop/CamCan/sourcedata'
 
# subdirectory containing just the MRI data
source.mri <- file.path(source.data, 'cc700')
x <- list.files(path = source.mri, recursive = TRUE, full.names = TRUE)

raw.data <- '/mmfs1/data/kurkela/Desktop/CamCan/rawdata'

subj.ids <- x %>% str_extract(., 'sub-CC[0-9]{6}') %>% unique()
str_c(raw.data, subj.ids, sep = '/') -> raw.data.subjs

scan.type.dirs <- 'fmap'

map(.x = raw.data.subjs, .f = ~str_c(.x, scan.type.dirs, sep = '/')) %>%
 unlist() %>%
 walk(., ~if(!dir.exists(.x)){dir.create(.x)})

y <- list.files(path = raw.data, recursive = TRUE, full.names = FALSE)
y %>% str_subset(., 'func') %>% str_subset(., '.nii.gz') -> y

## Step 5 Copy Field Map Files

x %>%
  str_subset(., 'fmap') -> fmap.files

copy_fmap <- function(data, func.files){
  # input is a data.frame of fmap files for this subject
  
  ## Parse the .nii files
  data %>%
   pull() %>%
   str_subset(., '.nii') -> images

  for(i in images){
    from <- i
    subj <- str_extract(i, 'sub-CC[0-9]{6}')
    if(str_detect(i, 'run')){
      mag <- str_extract(i, '(?<=run-0)[1-2]')
      to <- file.path(raw.data, subj, 'fmap', str_glue('{subj}_magnitude{mag}.nii.gz'))
    } else {
      to <- file.path(raw.data, subj, 'fmap', str_glue('{subj}_phasediff.nii.gz'))
    }
    file.copy(from, to, overwrite = FALSE)
  }
 
  ## Fix jsons
  data %>%
   pull() %>%
   str_subset(., '.nii', negate = TRUE) -> jsonFiles

  jsonOUT <- list(RepetitionTime = 0, EchoTime1 = 0, EchoTime2 = 0, FlipAngle = 0, IntendedFor = c())
  x <- fromJSON(jsonFiles %>% str_subset(., 'run-01'))
  y <- fromJSON(jsonFiles %>% str_subset(., 'run-02'))

  jsonOUT$RepetitionTime = unbox(x$RepetitionTime)
  jsonOUT$EchoTime1 = unbox(x$EchoTime)
  jsonOUT$EchoTime2 = unbox(y$EchoTime)
  jsonOUT$FlipAngle = unbox(x$FlipAngle)

  func.files %>%
   str_subset(., subj) %>%
   str_remove(., 'sub-CC[0-9]{6}/') -> func.files
  
  jsonOUT$IntendedFor = func.files
  
  out <- file.path(raw.data, subj, 'fmap', str_glue('{subj}_phasediff.json'))
  write_json(jsonOUT, out)

}

fmap.files %>% 
  str_subset(., 'tmp', negate = TRUE) %>% 
  str_subset(., 'sub-CC') %>%
  str_subset(., 'fmap_movie') %>%
  tibble(fmap.file = .) %>% 
  mutate(subj = str_extract(fmap.file, 'sub-CC[0-9]{6}')) %>% 
  nest(data = fmap.file) %>%
  mutate(fmap.file = walk(.x = data, .f = copy_fmap, func.files = y))
