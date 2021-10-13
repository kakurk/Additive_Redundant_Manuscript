# Create Publication Ready Tables of Models

# R packages
library(MplusAutomation)
library(tidyverse)
library(kableExtra)

options(knitr.kable.NA = '')

M <- readModels(target = file.path(getwd(), 'mplus'))

# Create Fit Statistics Tables --------------------------------------------

### No Resid Cov

# A summary of model fit statistics
map_dfr(M, ~.x$summaries) %>% 
  as_tibble() %>%
  filter(str_detect(Filename, '^noresidcov_model[0-8]\\.out')) %>%
  select(Title, ChiSqM_Value, ChiSqM_DF, ChiSqM_PValue, WaldChiSq_Value, WaldChiSq_DF, WaldChiSq_PValue, CFI, TLI, RMSEA_Estimate, SRMR.Within, SRMR.Between) %>%
  mutate(ChiSqM_PValue = format.pval(ChiSqM_PValue, eps = .001)) %>%
  mutate(`Chi-square` = str_glue('{ChiSqM_Value} ({ChiSqM_DF}), p: {ChiSqM_PValue}')) %>%
  mutate(WaldChiSq_PValue = p.adjust(WaldChiSq_PValue, method = 'bonferroni')) %>%
  mutate(WaldChiSq_PValue = format.pval(WaldChiSq_PValue, eps = .001, digits = 2)) %>%
  mutate(`Wald's Test` = str_glue('{WaldChiSq_Value} ({WaldChiSq_DF}), p: {WaldChiSq_PValue}')) %>%
  mutate(`Wald's Test` = case_when(Title == 'Model 0: Redundancy' ~ NA_character_,
                                   TRUE ~ as.character(`Wald's Test`))) %>%
  mutate(modNum = as.double(str_extract(Title, '[0-9]{1,2}'))) %>%
  arrange(modNum) %>%
  select(Title, `Chi-square`, `Wald's Test`, everything(), -starts_with('ChiSq'), -starts_with('WaldChi'), -modNum) -> summary.tbl

# print the table nicely in R viewer
col_names <- c('Title', 'Chi-square', paste0("Wald's Test", footnote_marker_alphabet(1)), "CFI", "TLI", "RMSEA_Estiate", "SRMR.Within", "SRMR.Between")

summary.tbl %>%
  magrittr::set_colnames(col_names) %>%  
  kable(caption = 'Table X: Model Comparisons', escape = F) %>%
  kable_classic() %>%
  footnote(alphabet = c("All Wald's Tests test the constraint that the unique path for the given ROI to 0."))


### Single Factor Models

# A summary of model fit statistics
map_dfr(M, ~.x$summaries) %>% 
  as_tibble() %>%
  filter(str_detect(Filename, '^model[0-8]\\.out')) %>% 
  select(Title, ChiSqM_Value, ChiSqM_DF, ChiSqM_PValue, WaldChiSq_Value, WaldChiSq_DF, WaldChiSq_PValue, CFI, TLI, RMSEA_Estimate, SRMR.Within, SRMR.Between) %>%
  mutate(ChiSqM_PValue = format.pval(ChiSqM_PValue, eps = .001)) %>%
  mutate(`Chi-square` = str_glue('{ChiSqM_Value} ({ChiSqM_DF}), p: {ChiSqM_PValue}')) %>%
  mutate(WaldChiSq_PValue = p.adjust(WaldChiSq_PValue, method = 'bonferroni')) %>%
  mutate(WaldChiSq_PValue = format.pval(WaldChiSq_PValue, eps = .001, digits = 2)) %>%
  mutate(`Wald's Test` = str_glue('{WaldChiSq_Value} ({WaldChiSq_DF}), p: {WaldChiSq_PValue}')) %>%
  mutate(`Wald's Test` = case_when(Title == 'Model 0: Redundancy' ~ NA_character_,
                                   TRUE ~ as.character(`Wald's Test`))) %>%
  mutate(modNum = as.double(str_extract(Title, '[0-9]{1,2}'))) %>%
  arrange(modNum) %>%
  select(Title, `Chi-square`, `Wald's Test`, everything(), -starts_with('ChiSq'), -starts_with('WaldChi'), -modNum) -> summary.tbl

# print the table nicely in R viewer
col_names <- c('Title', 'Chi-square', paste0("Wald's Test", footnote_marker_alphabet(1)), "CFI", "TLI", "RMSEA_Estiate", "SRMR.Within", "SRMR.Between")

summary.tbl %>%
  magrittr::set_colnames(col_names) %>%  
  kable(caption = 'Table X: Model Comparisons', escape = F) %>%
  kable_classic() %>%
  footnote(alphabet = c("All Wald's Tests test the constraint that the unique path for the given ROI to 0."))

# write to a csv file
write_csv(x = summary.tbl, path = 'summary_table.csv')

### Bifactor Models

# A summary of model fit statistics
map_dfr(M, ~.x$summaries) %>% 
  as_tibble() %>%
  filter(str_detect(Filename, '^alternate_model[0-8]\\.out')) %>% 
  select(Title, ChiSqM_Value, ChiSqM_DF, ChiSqM_PValue, WaldChiSq_Value, WaldChiSq_DF, WaldChiSq_PValue, CFI, TLI, RMSEA_Estimate, SRMR.Within, SRMR.Between) %>%
  mutate(ChiSqM_PValue = format.pval(ChiSqM_PValue, eps = .001)) %>%
  mutate(`Chi-square` = str_glue('{ChiSqM_Value} ({ChiSqM_DF}), p: {ChiSqM_PValue}')) %>%
  mutate(WaldChiSq_PValue = p.adjust(WaldChiSq_PValue, method = 'bonferroni')) %>%
  mutate(WaldChiSq_PValue = format.pval(WaldChiSq_PValue, eps = .001, digits = 2)) %>%
  mutate(`Wald's Test` = str_glue('{WaldChiSq_Value} ({WaldChiSq_DF}), p: {WaldChiSq_PValue}')) %>%
  mutate(`Wald's Test` = case_when(Title == 'Bifactor Model 0: Both Subnetworks -> MemQ' ~ NA_character_,
                                   TRUE ~ as.character(`Wald's Test`))) %>%
  mutate(modNum = as.double(str_extract(Title, '[0-9]{1,2}'))) %>%
  arrange(modNum) %>%
  select(Title, `Chi-square`, `Wald's Test`, everything(), -starts_with('ChiSq'), -starts_with('WaldChi'), -modNum) -> summary.tbl

# print the table nicely in R viewer
col_names <- c('Title', 'Chi-square', paste0("Wald's Test", footnote_marker_alphabet(1)), "CFI", "TLI", "RMSEA_Estiate", "SRMR.Within", "SRMR.Between")

summary.tbl %>%
  magrittr::set_colnames(col_names) %>%  
  kable(caption = 'Table X: Model Comparisons', escape = F) %>%
  kable_classic() %>%
  footnote(alphabet = c("All Wald's Tests test the constraint that the unique path for the given ROI to 0."))

# write to a csv file
write_csv(x = summary.tbl, path = 'bifactor_summary_table.csv')

# Create Parameter Tables -------------------------------------------------

createParamTbl <- function(x){
  # function that 
  # 1.) extracts the unstandardized and standardized parameter estimates
  # from a mplus.model.list object created by MplusAutomation::readModels() 
  # 2.) perfoms minor tidying by filtering out the between parameter estimates,
  # removing the est_se column, and formating the pval column
  # 3.) joins the two data.frames together

  x$parameters$unstandardized %>%
    as_tibble() %>%
    select(-est_se) %>%
    mutate(pval = format.pval(pval, eps = .001)) -> unstand

  x$parameters$stdyx.standardized %>%
    as_tibble() %>%
    select(-est_se) %>%
    mutate(pval = format.pval(pval, eps = .001)) %>%
    select(BetweenWithin, everything()) -> stand
  
  left_join(unstand, stand, by = c('paramHeader', 'param', 'BetweenWithin'), suffix = c('.unstand', '.stand'))

}

col_names <- c('level', 'paramHeader', 'param', 'est', 'se', 'pval', 'est', 'se', 'pval')

# Joint Measurement Model

createParamTbl(M$joint_measurement_model.out) %>%
  select(BetweenWithin, everything()) -> joint_measure_param_tbl

# print the table nicely in R viewer
joint_measure_param_tbl %>%
  kable(caption = 'Table 1: Measurement Model Parameter Estimates', col.names = col_names) %>%
  kable_classic() %>%
  footnote(general = 'Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.')

# write to csv
write_csv(x = joint_measure_param_tbl, 'supplemental_table_joint_measure_param_tbl.csv')

# Joint Two Factor Measurement Model

createParamTbl(M$alternate_joint_model.out) %>%
  select(BetweenWithin, everything()) -> alternate_joint_measure_param_tbl

# print the table nicely in R viewer
alternate_joint_measure_param_tbl %>%
  kable(caption = 'Table 2: Bifactor Measurement Model Standardized Parameter Estimates', col.names = col_names) %>%
  kable_classic() %>%
  footnote(general = 'Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.')

# write to csv
write_csv(x = alternate_joint_measure_param_tbl, 'twofactor_model_param_tbl.csv')

# Create Communality Tables

createCommunTbl <- function(x){
  # function that 
  # 1.) extracts the unstandardized and standardized parameter estimates
  # from a mplus.model.list object created by MplusAutomation::readModels() 
  # 2.) perfoms minor tidying by filtering out the between parameter estimates,
  # removing the est_se column, and formating the pval column
  # 3.) joins the two data.frames together
  
  x$parameters$r2 %>%
    as_tibble() %>%
    mutate(pval = format.pval(pval, eps = .001)) %>%
    select(-BetweenWithin)
  
}

createCommunTbl(M$neural_measurement_model_within.out) -> SingleFactor

createCommunTbl(M$alternate_measurement_model_within.out) -> TwoFactor

left_join(SingleFactor, TwoFactor, by = c('param'), suffix = c('.SingleFactor', '.TwoFactor')) -> JointTbl

col_names <- c('param', 'est', 'se', 'est_se', 'pval', 'est', 'se', 'est_se', 'pval')

JointTbl %>%
  kable(caption = 'Table X: Communality Values', escape = F, col.names = col_names) %>%
  kable_classic() %>%
  add_header_above(c(" " = 1, "Single Factor" = 4, "Two Factor" = 4))

write_csv(JointTbl, path = 'CommunalityValues.csv')
