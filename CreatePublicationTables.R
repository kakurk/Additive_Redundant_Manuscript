# Create Publication Ready Tables of Models

# R packages
library(MplusAutomation)
library(tidyverse)
library(kableExtra)

options(knitr.kable.NA = '')

M <- readModels(target = file.path(getwd(), 'mplus'), filefilter = 'model[1]?[0-9]')

# Create Fit Statistics Tables --------------------------------------------

# A summary of model fit statistics
map_dfr(M, ~.x$summaries) %>% 
  as_tibble() %>%
  select(Title, ChiSqM_Value, ChiSqM_DF, ChiSqM_PValue, WaldChiSq_Value, WaldChiSq_DF, WaldChiSq_PValue, CFI, TLI, RMSEA_Estimate, SRMR.Within, SRMR.Between) %>%
  mutate(ChiSqM_PValue = format.pval(ChiSqM_PValue, eps = .001)) %>%
  mutate(`Chi-square` = str_glue('{ChiSqM_Value} ({ChiSqM_DF}), p: {ChiSqM_PValue}')) %>%
  mutate(WaldChiSq_PValue = format.pval(WaldChiSq_PValue, eps = .001)) %>%
  mutate(`Wald's Test` = str_glue('{WaldChiSq_Value} ({WaldChiSq_DF}), p: {WaldChiSq_PValue}')) %>%
  mutate(`Wald's Test` = case_when(Title == 'Model 0: Redundancy' ~ NA_character_,
                                   TRUE ~ as.character(`Wald's Test`))) %>%
  mutate(modNum = as.double(str_extract(Title, '[0-9]{1,2}'))) %>%
  arrange(modNum) %>%
  select(Title, `Chi-square`, `Wald's Test`, everything(), -starts_with('ChiSq'), -starts_with('WaldChi'), -modNum) -> summary.tbl

# print the table nicely in R viewer
col_names <- c('Title', 'Chi-square', paste0("Wald's Test", footnote_marker_alphabet(1)), "CFI", "TLI", "RMSEA_Estiate", "SRMR.Within", "SRMR.Between")

summary.tbl %>%
  mutate(`Wald's Test` = case_when(Title == 'Model 9: MPFC + PHC' ~ paste0(`Wald's Test`, footnote_marker_alphabet(2)),
                                   Title == 'Model 10: MPFC + PHC + PREC' ~ paste0(`Wald's Test`, footnote_marker_alphabet(3)),
                                   TRUE ~ `Wald's Test`)) %>%
  magrittr::set_colnames(col_names) %>%  
  kable(caption = 'Table X: Model Comparisons', escape = F) %>%
  kable_classic() %>%
  footnote(alphabet = c("All Wald's Tests test the constraint that the unique path for the given ROI to 0 unless otherwise noted.",
                        "Tests the constraint that the PHC -> MemQ path is 0.",
                        "Tests the constraint that the PREC -> MemQ path is 0."))

# write to a csv file
write_csv(x = summary.tbl, path = 'summary_table.csv')

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
    filter(BetweenWithin == 'Within') %>%
    select(-BetweenWithin, -est_se) %>%
    mutate(pval = format.pval(pval, eps = .001)) -> unstand
  
  x$parameters$stdyx.standardized %>%
    as_tibble() %>%
    filter(BetweenWithin == 'Within') %>%
    select(-BetweenWithin, -est_se) %>%
    mutate(pval = format.pval(pval, eps = .001)) -> stand
  
  left_join(unstand, stand, by = c('paramHeader', 'param'), suffix = c('.unstand', '.stand'))
  
}

col_names <- c('paramHeader', 'param', 'est', 'se', 'pval', 'est', 'se', 'pval')

# Model 0

createParamTbl(M$model0.out) -> model0_param_tbl

# print the table nicely in R viewer
model0_param_tbl %>%
  kable(caption = 'Table 1: Model 0 Parameter Estimates', col.names = col_names) %>%
  add_header_above(c(" " = 2, "Unstandardized" = 3, "Standardized" = 3)) %>%
  kable_classic() %>%
  footnote(general = 'Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.')

# write to csv
write_csv(x = model0_param_tbl, 'model0_param_tbl.csv')

# Model 2

createParamTbl(M$model2.out) -> model2_param_tbl

# print the table nicely in R viewer
model2_param_tbl %>% 
  kable(caption = 'Table 2: Model 2 Parameter Estimates', col.names = col_names) %>%
  add_header_above(c(" " = 2, "Unstandardized" = 3, "Standardized" = 3)) %>%
  kable_classic() %>%
  footnote(general = 'Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.')

# write to csv
write_csv(x = model2_param_tbl, 'model2_param_tbl.csv')

# Model 4

createParamTbl(M$model4.out) -> model4_param_tbl

# print the table nicely in R viewer
model4_param_tbl %>% 
  kable(caption = 'Table 3: Model 4 Parameter Estimates', col.names = col_names) %>%
  add_header_above(c(" " = 2, "Unstandardized" = 3, "Standardized" = 3)) %>%
  kable_classic() %>%
  footnote(general = 'Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.')

# write to csv
write_csv(x = model4_param_tbl, 'model4_param_tbl.csv')

# Model 5

createParamTbl(M$model5.out) -> model5_param_tbl
  
# print the table nicely in R viewer
model5_param_tbl %>%
  kable(caption = 'Table 4: Model 5 Parameter Estimates', col.names = col_names) %>%
  add_header_above(c(" " = 2, "Unstandardized" = 3, "Standardized" = 3)) %>%
  kable_classic() %>%
  footnote(general = 'Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.')

# write to csv
write_csv(x = model5_param_tbl, 'model5_param_tbl.csv')