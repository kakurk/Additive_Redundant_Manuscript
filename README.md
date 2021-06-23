# Additive_Redundant_Manuscript
Repository Home of the MemoLab's Additive Redundant Manuscript

## Analysis Steps

Step 1: Extract ROI Data
- Extract single trial estimates (SPM_T values from a multi-model single trial estimate analysis, see Mumford et al. 2012; ) from PM Network ROIs (see Cooper, Kurkela, Davis, & Ritchey 2021)
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
