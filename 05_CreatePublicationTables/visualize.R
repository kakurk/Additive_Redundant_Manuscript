# visualize the correlation matrix

library(tidyverse)
library(corrr)
library(MplusAutomation)

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
M <- readModels(target = 'mplus/')

M$data.all_modelType.Measurement_measureModel.SingleFactor.out$data_summary$ICC %>%
  as_tibble() %>%
  mutate(variable = str_to_lower(variable)) -> ICCs

df %>%
  summarise(across(-subject, .fns = c(mean, sd, min, max))) %>%
  pivot_longer(pHipp_1:EmoCorr_4, names_to = c("rowname", "stat"), names_sep = "_") %>%
  mutate(stat = factor(stat, labels = c("mean", "sd", "min", "max"))) %>%
  pivot_wider(names_from = stat, values_from = "value") %>%
  left_join(., corTbl, by = "rowname") %>%
  mutate(rowname = str_to_lower(rowname)) %>%
  left_join(., ICCs, by = c("rowname" = "variable")) %>%
  select(rowname, mean, sd, min, max, ICC, pHipp:EmoCorr) %>%
  mutate(rowname = str_replace(rowname, 'scecorr', 'scene')) %>%
  mutate(rowname = str_replace(rowname, 'colcorr', 'color')) %>%
  mutate(rowname = str_replace(rowname, 'emocorr', 'sound')) %>%
  mutate(rowname = str_to_upper(rowname)) %>%
  rename(SCENE = SceCorr) %>%
  rename(COLOR = ColCorr) %>%
  rename(SOUND = EmoCorr) -> Tbl

write_csv(Tbl, "intermediate/05_Table1.csv", na = '')
