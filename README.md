# Additive_Redundant_Manuscript
Repository Home of the MemoLab's Additive Redundant Manuscript

## Analysis Steps

Step 1: Extract ROI Data
- Extract single trial estimates (SPM_T values from a multi-model single trial estimate analysis, see Mumford et al. 2012; https://github.com/ritcheym/fmri_misc/blob/master/generate_spm_singletrial.m) from PM Network ROIs (see Cooper, Kurkela, Davis, & Ritchey 2021; https://github.com/memobc/paper-camcan-pmn/tree/master/rois)
- Assumes ROIs are stored in a local directory: ``
- Assumes single-trial estimates are stored in a local directory: ``

`Extract_ROI_data.m`
`Extracted_ROI_data.csv`

Step 2: Tidy Data
- Take Extracted Single Trial Estimates and appends behavioral data 'tidying' the data along the way
- Assumes behavioral data are stored in a local directory: ``


Step 3: Visualize
- Take tidy data and print a correlation matrix of variables of interest

Step 4: MPLUS Modeling
- Run a series of SEM models in MPLUS. See README in `./mplus/`


# Refrences

Mumford, J. A., Turner, B. O., Ashby, F. G., & Poldrack, R. A. (2012). Deconvolving BOLD activation in event-related designs for multivoxel pattern classification analyses. NeuroImage, 59(3), 2636–2643. https://doi.org/10.1016/j.neuroimage.2011.08.076.

Cooper, R. A., Kurkela, K. A., Davis, S. W., & Ritchey, M. (2021). Mapping the organization and dynamics of the posterior medial network during movie watching. NeuroImage, 236, 118075. https://doi.org/10.1016/j.neuroimage.2021.118075

