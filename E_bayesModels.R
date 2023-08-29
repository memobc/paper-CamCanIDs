library(tidyverse)
library(BayesFactor)
library(effectsize)

# Read data in. Calculate memory ability index
read_csv('results/PredictTbl_gsr.csv') -> PredictTbl_tidy

# Bayesian Regression using BayesFactor

# vPMN-vPMN connections
bfObj_within <- regressionBF(memoryability ~ within, data = PredictTbl_tidy, whichModels = 'top')
bf_asVector  <- extractBF(bfObj_within, onlybf = TRUE)
interpret_bf(bf_asVector, include_value = T)

# vPMN-dPMN connections
bfObj_between <- regressionBF(memoryability ~ between, data = PredictTbl_tidy, whichModels = 'top')
bf_asVector   <- extractBF(bfObj_between, onlybf = TRUE)
interpret_bf(bf_asVector, include_value = T)

# vPMN-rest-of-brain connections
bfObj_extra_full <- lmBF(memoryability ~ extra, data = PredictTbl_tidy)
bf_asVector <- extractBF(bfObj_extra_full, onlybf = TRUE)
interpret_bf(bf_asVector, include_value = T)

# hipp connections
bfObj_extra_full <- lmBF(memoryability ~ hipp, data = PredictTbl_tidy)
bf_asVector <- extractBF(bfObj_extra_full, onlybf = TRUE)
interpret_bf(bf_asVector, include_value = T)
