# Create Publication Ready Tables of Models

# requirements ------------------------------------------------------------

shh <- suppressPackageStartupMessages

shh(library(MplusAutomation))
shh(library(tidyverse))
shh(library(kableExtra))

options(knitr.kable.NA = "")

createModelCompTbl <- function(unformatted_model_summary_tbl, Model1Title) {
  # 
  
  unformatted_model_summary_tbl %>%
    select(Title, ChiSqM_Value, ChiSqM_DF, ChiSqM_PValue, WaldChiSq_Value, WaldChiSq_DF, WaldChiSq_PValue, CFI, TLI, RMSEA_Estimate, SRMR.Within, SRMR.Between) %>%
    mutate(ChiSqM_PValue = format.pval(ChiSqM_PValue, eps = .001)) %>%
    mutate(`Chi-square` = str_glue("{ChiSqM_Value} ({ChiSqM_DF}), p: {ChiSqM_PValue}")) %>%
    mutate(WaldChiSq_PValue = p.adjust(WaldChiSq_PValue, method = "bonferroni")) %>%
    mutate(WaldChiSq_PValue = format.pval(WaldChiSq_PValue, eps = .001, digits = 2)) %>%
    mutate(`Wald's Test` = str_glue("{WaldChiSq_Value} ({WaldChiSq_DF}), p: {WaldChiSq_PValue}")) %>%
    mutate(`Wald's Test` = case_when(
      Title == Model1Title ~ NA_character_,
      TRUE ~ as.character(`Wald's Test`)
    )) %>%
    mutate(modNum = as.double(str_extract(Title, "[0-9]{1,2}"))) %>%
    arrange(modNum) %>%
    select(Title, `Chi-square`, `Wald's Test`, everything(), -starts_with("ChiSq"), -starts_with("WaldChi"), -modNum) %>%
    rename(RMSEA = RMSEA_Estimate) 
}

createParamTbl <- function(x) {
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

  left_join(unstand, stand, by = c("paramHeader", "param", "BetweenWithin"), suffix = c(".unstand", ".stand")) %>%
    select(BetweenWithin, everything())
}

createCommunTbl <- function(x) {
  # function that
  # 1.) extracts the communality values from a mplus.model.list objects created by MplusAutomation::readModels()
  # 2.) performs some minor tidying

  x$parameters$r2 %>%
    as_tibble() %>%
    mutate(pval = format.pval(pval, eps = .001)) %>%
    select(-BetweenWithin)
}

remove_dup <- function(str_vct){
  out_vct <- str_vct
  uniq <- unique(str_vct)
  for(u in uniq){
    str_detect(u, str_vct) %>%
      which.max() -> first.instance
    str_detect(u, str_vct) %>%
      which() -> all.instances
    all.instances[!(all.instances %in% first.instance)] -> elements.2.remove
    out_vct[elements.2.remove] <- ''
  }
  return(out_vct)
}

# Parameters --------------------------------------------------------------

M <- readModels(target = file.path(getwd(), "mplus"))

# extract model summary information
map_dfr(M, ~ .x$summaries) %>%
  as_tibble() -> model_summaries

ModelComp_col_names <- c("Title", "Chi-square", paste0("Wald's Test", footnote_marker_alphabet(1)), "CFI", "TLI", "RMSEA_Estimate", "SRMR.Within", "SRMR.Between")

# No Residual Covariance -- Model Comparisons -----------------------------

model_summaries %>%
  filter(str_detect(Filename, "SingleFactor_NoResidCov")) %>%
  createModelCompTbl(Model1Title = "Model 0: Redundancy") -> no_resid_cov_summary_tbl

# print the summary table nicely in R viewer
no_resid_cov_summary_tbl %>%
  magrittr::set_colnames(ModelComp_col_names) %>%
  kable(caption = "Table X: Model Comparisons", escape = F) %>%
  kable_classic() %>%
  footnote(alphabet = c("All Wald's Tests test the constraint that the unique path for the given ROI to 0."))

write_csv(x = no_resid_cov_summary_tbl, path = "intermediate/05_type-ModelComparisons_model-NoResidCov_tbl.csv")

# Single Factor Model -- Model Comparions ---------------------------------

# A summary of model fit statistics
model_summaries %>%
  filter(str_detect(Filename, "SingleFactor_modelName-Model[0-8]")) %>%
  createModelCompTbl(Model1Title = "Model 0: Redundancy") -> single_factor_summary_tbl

single_factor_summary_tbl %>%
  magrittr::set_colnames(ModelComp_col_names) %>%
  kable(caption = "Table X: Model Comparisons", escape = F) %>%
  kable_classic() %>%
  footnote(alphabet = c("All Wald's Tests test the constraint that the unique path for the given ROI to 0."))

write_csv(x = single_factor_summary_tbl, path = "intermediate/05_type-ModelComparisons_model-SingleFactor_tbl.csv", na = "")

# Two Factor Model -- Model Comparisons -----------------------------------

# A summary of model fit statistics
model_summaries %>%
  filter(str_detect(Filename, "TwoFactor_modelName-Model[0-8].out")) %>%
  createModelCompTbl(Model1Title = "Bifactor Model 0: Both Subnetworks -> MemQ") -> twofactor_summary_tbl

# print the table nicely in R viewer
twofactor_summary_tbl %>%
  magrittr::set_colnames(ModelComp_col_names) %>%
  kable(caption = "Table X: Model Comparisons", escape = F) %>%
  kable_classic() %>%
  footnote(alphabet = c("All Wald's Tests test the constraint that the unique path for the given ROI to 0."))

# write to a csv file
write_csv(x = twofactor_summary_tbl, path = "intermediate/05_type-ModelComparisons_model-TwoFactor_tbl.csv", na = "")

# Single Factor Measurement Model -- Parameters ---------------------------

createParamTbl(M$data.all_modelType.Measurement_measureModel.SingleFactor.out) -> single_factor_param_tbl

single_factor_param_tbl %>% 
  filter(BetweenWithin == 'Within') %>%
  filter(str_detect(paramHeader, 'Variances', negate = TRUE)) %>%
  mutate(param = str_replace(param, 'SCECORR', 'SCENE')) %>%
  mutate(param = str_replace(param, 'COLCORR', 'COLOR')) %>%
  mutate(param = str_replace(param, 'EMOCORR', 'SOUND')) %>%
  select(-BetweenWithin, -ends_with('.unstand')) %>%
  rename(est = est.stand, se = se.stand, pval = pval.stand) %>%
  mutate(paramHeader = remove_dup(paramHeader))  -> single_factor_param_tbl_truncated

single_factor_param_tbl %>%
  mutate(BetweenWithin = remove_dup(BetweenWithin)) %>%
  mutate(paramHeader = remove_dup(paramHeader)) -> single_factor_param_tbl

# print the table nicely in R viewer
col_names <- c("level", "paramHeader", "param", "est", "se", "pval", "est", "se", "pval")
single_factor_param_tbl %>%
  kable(caption = "Table 1: Measurement Model Parameter Estimates", col.names = col_names) %>%
  kable_classic() %>%
  footnote(general = "Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.")

# write to csv
write_csv(x = single_factor_param_tbl, "intermediate/05_type-Parameters_model-SingleFactor_detail-full_tbl.csv")
write_csv(x = single_factor_param_tbl_truncated, "intermediate/05_type-Parameters_model-SingleFactor_detail-truncated_tbl.csv")

# Two Factor Measurement Model -- Parameters ------------------------------

createParamTbl(M$data.all_modelType.Measurement_measureModel.TwoFactor.out) -> two_factor_param_tbl

two_factor_param_tbl %>%
  mutate(paramHeader = remove_dup(paramHeader)) %>%
  mutate(BetweenWithin = remove_dup(BetweenWithin)) -> two_factor_param_tbl

# print the table nicely in R viewer
col_names <- c("level", "paramHeader", "param", "est", "se", "pval", "est", "se", "pval")
two_factor_param_tbl %>%
  kable(caption = "Table 2: Twofactor Measurement Model Standardized Parameter Estimates", col.names = col_names) %>%
  kable_classic() %>%
  footnote(general = "Parameter headers follows standard Mplus syntax. Parameters set to a value follow Mplus standards, reporting the value the parameter was set to as the estimate, the standard error set to 0.000, and the pval set to 999.000. See Halquist & Wiley (2018) for more information. param = parameter, est = estimate, se = standard error, pval = p value. PMN = Posterior Medial Network, MEMQ = Memory Quality, PHIPP = posterior hippocampus, PREC = precuneus, PCC = posterior cingulate cortex, MPFC = medial prefrontal cortex, PHC = parahippocampal cortex, RSC = retrosplenial cortex, AAG = anterior angular gyrus, PAG = posterior angular gyrus, SCECORR = scene feature correct, COLCORR = color feature correct, EMOCORR = emotional sound feature correct.")

# write to csv
write_csv(x = two_factor_param_tbl, "intermediate/05_type-Parameters_model-TwoFactorMeasure_detail-full_tbl.csv")

# Two Factor Structural Model Parameters

createParamTbl(M$data.all_modelType.Structural_measureModel.TwoFactor_modelName.Model0.out) -> two_factor_struc_param_tbl

two_factor_struc_param_tbl %>%
  filter(BetweenWithin == 'Within') %>%
  filter(str_detect(paramHeader, 'Variances', negate = TRUE)) %>%
  mutate(param = str_replace(param, 'SCECORR', 'SCENE')) %>%
  mutate(param = str_replace(param, 'COLCORR', 'COLOR')) %>%
  mutate(param = str_replace(param, 'EMOCORR', 'SOUND')) %>%
  select(-BetweenWithin, -ends_with('.unstand')) %>%
  rename(est = est.stand, se = se.stand, pval = pval.stand) %>%
  mutate(paramHeader = remove_dup(paramHeader)) -> two_factor_param_tbl_truncated

write_csv(x = two_factor_param_tbl_truncated, "intermediate/05_type-Parameters_model-TwoFactorStructural_detail-truncated_tbl.csv")

# Communality Table -------------------------------------------------------

createCommunTbl(M$data.neural_modelType.Measurement_measureModel.SingleFactor_modelName.Final.out) -> SingleFactor

createCommunTbl(M$data.neural_modelType.Measurement_measureModel.TwoFactor.out) -> TwoFactor

left_join(SingleFactor, TwoFactor, by = c("param"), suffix = c(".SingleFactor", ".TwoFactor")) -> JointTbl

# print the table nicely in R viewer
col_names <- c("param", "est", "se", "est_se", "pval", "est", "se", "est_se", "pval")
JointTbl %>%
  kable(caption = "Table X: Communality Values", escape = F, col.names = col_names) %>%
  kable_classic() %>%
  add_header_above(c(" " = 1, "Single Factor" = 4, "Two Factor" = 4))

write_csv(JointTbl, path = "intermediate/05_type-Communality_model-All_tbl.csv")
