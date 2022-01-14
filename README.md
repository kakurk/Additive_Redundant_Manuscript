# Additive_Redundant_Manuscript
Repository Home of the MemoLab's Additive Redundant Manuscript.

This repository tries to follow the [tidyverse's style guide](https://style.tidyverse.org/index.html) and [BIDS formatting](https://bids.neuroimaging.io/)  

## Directories

`intermediate/` = contains data written in between analysis steps  
`mplus/`= mplus specific files  

## Analysis Steps

Step 1: Single Trial Estimates
- Estimate neural activation at each retrieval trial using Mumoford et al. 2012's multi-model method.  
- `01_SingleTrialEstimates/A_condition_retrieval_regressors_RSA.m` -- generates multiple conditions `*.mat` files of the retrieval trial. See SPM12 manual.  
- `01_SingleTrialEstimates/A_nuisance_retrieval_regressors_RSA.m` -- generates multiple regressors `*.mat` files of nuisance variables. See SPM12 manual, manuscript for more information.  
- `01_SingleTrialEstimates/B_first_level_RSA_singleTrial.m` -- specifies a `SPM.mat` file. This model is NOT estimated, just specified. See SPM12 manual.  
- `01_SingleTrialEstimates/C_generate_RSA_singleTrial.m` -- Takes the model specification SPM.mat files from the previous step and runs a Mumford et al. 2012 mult-model single trial estimate analysis  

Step 2: Extract ROI Data
- Extract single trial estimates (SPM_T values from a multi-model single trial estimate analysis, see Mumford et al. 2012; [Maureen Ritchey's Generate SPM Single Trial](https://github.com/ritcheym/fmri_misc/blob/master/generate_spm_singletrial.m)) from PM Network ROIs (see Cooper, Kurkela, Davis, & Ritchey 2021; [Publically Available ROIs](https://github.com/memobc/paper-camcan-pmn/tree/master/rois))  
- Assumes ROIs are stored in a local directory: `rois/`  
- Assumes single-trial estimates are stored in a local directory: `st_estimates/`  
- Assumes [SPM12](https://www.fil.ion.ucl.ac.uk/spm/) is located in `spm12/`  
- See: `02_ExtractROIData/Extract_ROI_data.m`  -- Extracts single trial estimates from select ROIs and writes them as a csv file
- See: `02_ExtractROIData/Reslice_ROIs.m` -- reslices ROIs to be in the same space as the single trial estimates.
- See: `intermediate/02_Extracted_ROI_data_1s.csv`  

Step 3: Tidy Data
- Take Extracted Single Trial Estimates and appends behavioral data 'tidying' the data along the way  
- Assumes behavioral data are stored in a local directory: `orbit-data/`  
- See: `03_Tidy/tidy.R`  
- See: `intermediate/03_tidy_roi_data_1s.dat`  

Step 4: MPLUS Modeling
- Run a series of SEM models in MPLUS. See README in `mplus/`  

Step 5a: Visualize
- Take tidy data and print a correlation matrix of variables of interest  
- Additionally writes a csv of the data contained in Table 1 of the manuscript.  
- See: `05_CreatePublicationTables/05_visualize.R`  

Step 5b: Create Publication Tables
- After running the MPLUS models, the script automates extracting the results from the MPLUS output files (`*.out`) and writes the results to be formatted for publication.  
- Additionally calculate a Satorra Bentler Chi Squared Difference Test.  
- See: `05_CreatePublicationTables/05_CreatePublicationTables.R`  
- See: `05_CreatePublicationTables/05_SatorraBentler_ChiSqDiffTest.R`  

# References

Mumford, J. A., Turner, B. O., Ashby, F. G., & Poldrack, R. A. (2012). Deconvolving BOLD activation in event-related designs for multivoxel pattern classification analyses. NeuroImage, 59(3), 2636–2643. https://doi.org/10.1016/j.neuroimage.2011.08.076.

Cooper, R. A., Kurkela, K. A., Davis, S. W., & Ritchey, M. (2021). Mapping the organization and dynamics of the posterior medial network during movie watching. NeuroImage, 236, 118075. https://doi.org/10.1016/j.neuroimage.2021.118075
