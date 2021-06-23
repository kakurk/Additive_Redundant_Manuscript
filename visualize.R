# visualize the correlation matrix

library(tidyverse)
library(corrr)
library(lme4)

col.names <- c('subject', 'pHipp', 'PREC', 'PCC', 'MPFC', 'PHC', 'RSC', 'aAG', 'pAG', 'SceErr', 'ColErr')

df <- read_delim('mplus/tidy_roi_data.dat', delim = ' ', col_names = col.names)

df %>% select(-subject) %>% correlate() %>% fashion() %>% print()
