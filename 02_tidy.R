# Data Cleaning

# requirements ------------------------------------------------------------

shhh <- suppressPackageStartupMessages

shhh(require(tidyverse))
shhh(require(pbapply))
shhh(require(tictoc))
shhh(require(glue))
shhh(require(tictoc))
shhh(require(assertthat))
shhh(require(magrittr))

nest   <- nest_legacy
unnest <- unnest_legacy

# parameters --------------------------------------------------------------
# user specified input parameters

root <- '/gsfs0/data/kurkela/Desktop/Additive_Redundant_Manuscript'

# Where the extracted ROI data is
extracted.data.File <- file.path(root, 'Extracted_ROI_data.csv')

# load data ---------------------------------------------------------------

cat('Loading Data:\n')

# load extracted ROI data from the csv files

# body --------------------------------------------------------------------

betas.df <- read_csv(extracted.data.File) %>%
            mutate(across('subject', factor))

# clean -------------------------------------------------------------------

# The orbit data directory on sirius
orbit_data.dir <- file.path(root, 'orbit-data')

# the subject exclusions csv
SS_exclusions    <- file.path(orbit_data.dir, 'derivs', 'excluded-runs-elife.csv')
SelectCols       <- cols_only(SubID = col_character(), Memory = col_logical())
SS_exclusions.df <- read_csv(SS_exclusions, col_types = SelectCols)

# the fmri behavioral data
behav_data <- file.path(orbit_data.dir, 'behavior', 'AllData_OrbitfMRI-behavior.csv')
behav.df   <- read_csv(file = behav_data) %>%
              mutate(Run = as.integer(Run))

BIDS_format_ID <- function(NumericID, BIDS.prepend = 's'){
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

# We are going to tidy the behav.df to match that of the betas.df
behav.df %<>%
  # Changes the numeric subject ID system of `behav.df`
  # to the BIDS format of `betas.df`
  mutate(SubID = map_chr(SubID, BIDS_format_ID, BIDS.prepend = 'sub-s')) %>%
  mutate(Run = if_else(SubID == 'sub-s009', as.integer(Run - 1), Run)) %>%
  mutate(onsetRemember = round(onsetRemember, 3)) %>%
  # 57 and 30 are from Cooper & Ritchey (2019)
  mutate(ColQuality = calc_quality(ColAbsError, thresh = 57)) %>%
  mutate(SceQuality = calc_quality(SceAbsError, thresh = 30)) %>%
  mutate(MemoryQuality = ColQuality + SceQuality + EmotionCorrect)

# the fmri behavioral data, only Ss included in elife paper
GoodSs <- SS_exclusions.df %>% filter(Memory) %>% pull(SubID)
behav.df %<>% 
  filter(SubID %in% GoodSs)

# Next, we are going to tidy the betas.df to have a session column
betas.df %<>%
  mutate(sess = str_extract(sess, '(?<=Sess)0[1-6]'),
         sess = as.integer(sess)) %>%
  mutate(ons = round(ons, 3))

# match the behavioral data to the betas data
betas.df <- left_join(betas.df, behav.df, 
                      by = c('subject' = 'SubID', 
                             'sess' = 'Run', 
                             'ons' = 'onsetRemember'))

# select only the variables of interest; make SceQuality and ColQuality binary; coerce
# subject to be numeric
betas.df <- betas.df %>%
            select(subject, pHipp:pAG, SceQuality, ColQuality, EmotionCorrect) %>%
	    mutate(ColQuality = as.double(ColQuality > 0), SceQuality = as.double(SceQuality > 0)) %>%
	    mutate(subject = as.factor(subject)) %>%
            mutate(subject = as.double(subject))

# write -------------------------------------------------------------------

cat('Writing:\n')
write_delim(betas.df, 'tidy_roi_data.dat', col_names = F)
