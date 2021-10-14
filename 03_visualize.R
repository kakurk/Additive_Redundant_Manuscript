# visualize the correlation matrix

library(tidyverse)
library(corrr)

col.names <- c("subject", "pHipp", "PREC", "PCC", "MPFC", "PHC", "RSC", "aAG", "pAG", "SceCorr", "ColCorr", "EmoCorr")

df <- read_delim("mplus/tidy_roi_data.dat", delim = " ", col_names = col.names)

df %>%
  select(-subject) %>%
  correlate() %>%
  shave() -> corTbl

corTbl %>%
  fashion() %>%
  print()

# taken from Mplus
ICCs <- c(0.037, 0.085, 0.193, 0.087, 0.124, 0.156, 0.254, 0.077, 0.208, 0.145, 0.119)

df %>%
  summarise(across(-subject, .fns = c(mean, sd, min, max))) %>%
  pivot_longer(pHipp_1:EmoCorr_4, names_to = c("rowname", "stat"), names_sep = "_") %>%
  mutate(stat = factor(stat, labels = c("mean", "sd", "min", "max"))) %>%
  pivot_wider(names_from = stat, values_from = "value") %>%
  left_join(., corTbl, by = "rowname") %>%
  add_column(ICC = ICCs, .after = "max") -> Tbl

write_csv(Tbl, "Table1.csv")
