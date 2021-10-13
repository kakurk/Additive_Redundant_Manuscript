# Data Cleaning

# requirements ------------------------------------------------------------

shhh <- suppressPackageStartupMessages

shhh(library(tidyverse))
shhh(library(pbapply))
shhh(library(tictoc))
shhh(library(glue))
shhh(library(tictoc))
shhh(library(assertthat))
shhh(library(magrittr))

numeric_to_bids <- function(NumericID, BIDS.prepend = 's'){
  # Converts a numeric subject ID to a BIDS formatted one.
  # Zero pads the numeric ID and place 'sub-s' in front
  # NumericID can be a character or a numeric.
  
  Zero.Pad.ID <- str_pad(NumericID, width = 3, side = 'left', pad = '0')
  BIDS.SubID  <- str_c(BIDS.prepend, Zero.Pad.ID)
  
}

calc_quality <- function(x, thresh){
  # calculate "Quality" by excluding high error trials above a 
  # predefined threshold and scaling the remaining low error
  # trials on a scale of 0 - 1

  thresholded <- ifelse(x > thresh, NA, x)
  thresholded <- 1 - thresholded / max(thresholded, na.rm = T)
  if_else(is.na(thresholded), 0, thresholded)

}

# parameters --------------------------------------------------------------

# the project directory
root <- '~/Desktop/Additive_Redundant_Manuscript/'

# Where the extracted ROI data is
extracted_data_file <- file.path(root, 'intermediate', '01_Extracted_ROI_data.csv')

# The orbit data directory
orbit_data_dir <- file.path(root, 'orbit-data')

# load data ---------------------------------------------------------------

cat('Loading Data:\n')

betas_df <- read_csv(extracted_data_file) %>%
            mutate(across('subject', factor))

# clean -------------------------------------------------------------------

# the subject exclusions csv
SS_exclusions    <- file.path(orbit_data_dir, 'derivs', 'excluded-runs-elife.csv')
select_cols      <- cols_only(SubID = col_character(), Memory = col_logical())
SS_exclusions_df <- read_csv(SS_exclusions, col_types = select_cols)

# the fmri behavioral data
behav_file <- file.path(orbit_data_dir, 'behavior', 'AllData_OrbitfMRI-behavior.csv')
behav_df   <- read_csv(file = behav_file) %>%
              mutate(Run = as.integer(Run))

# Tidy the behav_df to match betas_df

# Changes the numeric subject ID system of `behav_df`
# to BIDS format. Example: 01 -> sub-s001
behav_df %>%
  mutate(SubID = map_chr(SubID, numeric_to_bids, BIDS.prepend = 'sub-s')) -> behav_df

# Subject sub-s009 is missing the first session. The Run column of the behavioral data 
# (`behav_df`) has Runs 2-6 for subject sub-s009. The session column of the betas data
# frame (`betas_df`) has sessions 1-5 for subejct sub-s009. By subtracting 1 from the
# Run column just for subject sub-s009, these columns match
behav_df %>%
  mutate(Run = if_else(SubID == 'sub-s009', as.integer(Run - 1), Run)) -> behav_df

# Round onsetRemember to 3 decimal places. This allows for better matching of the
# behav_df and the betas_df using dplyr::left_join() below
behav_df %>%
mutate(onsetRemember = round(onsetRemember, 3)) -> behav_df
  
# Using the calc_quality function defined above, calculate memory quality for each feature
# The 57 and 30 cutoffs are from Cooper & Ritchey (2019)
behav_df %>%
  mutate(ColQuality = calc_quality(ColAbsError, thresh = 57)) %>%
  mutate(SceQuality = calc_quality(SceAbsError, thresh = 30)) %>%
  mutate(MemoryQuality = ColQuality + SceQuality + EmotionCorrect) -> behav_df

# the fmri behavioral data, only Ss included in elife paper
SS_exclusions_df %>% 
  filter(Memory) %>% 
  pull(SubID) -> GoodSs

behav_df %>% 
  filter(SubID %in% GoodSs) -> behav_df

# Next, we are going to tidy the betas_df to have a session column
betas_df %>%
  mutate(sess = str_extract(sess, '(?<=Sess)0[1-6]'),
         sess = as.integer(sess)) %>%
  mutate(ons = round(ons, 3)) -> betas_df

# match the behavioral data to the betas data
betas_df <- left_join(betas_df, behav_df, 
                      by = c('subject' = 'SubID', 
                             'sess' = 'Run', 
                             'ons' = 'onsetRemember'))

# select only the variables of interest; make SceQuality and ColQuality binary; coerce
# subject to be numeric.
betas_df %>%
  select(subject, pHipp:pAG, SceQuality, ColQuality, EmotionCorrect) %>%
  mutate(ColQuality = as.double(ColQuality > 0), SceQuality = as.double(SceQuality > 0)) %>%
  mutate(subject = as.factor(subject)) %>%
  mutate(subject = as.double(subject)) -> betas_df

# write -------------------------------------------------------------------

cat('Writing:\n')
write_delim(betas_df, 'tidy_roi_data.dat', col_names = F)