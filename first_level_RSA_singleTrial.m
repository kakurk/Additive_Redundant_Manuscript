function [] = first_level_RSA_singleTrial(i)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% specifies first level model for single trial estimates - only specification and not
% estimation as it only acts as a template for single trial model script:
% 'generate_RSA_singleTrial.m'

% Rose Cooper Dec 2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

b.scriptdir = pwd;
addpath(b.scriptdir);

% SPM info
addpath('/gsfs0/data/cooperrn/Documents/fmri-core/spm12'); %using mine and not lab's because of a bug fix to est_non-sphericty for explicit masks
spm_jobman('initcfg')
spm('defaults', 'FMRI');

phases = {'Retrieval'};
times = {'4'}; %times of the epoch - stored in conditions filename


for p = 1:length(phases)
    
    this_phase = phases{p};
    
    %where is preprocessed, unsmoothed encoding data
    b.derivDir     = '/gsfs0/data/ritcheym/data/fmri/orbit/data/derivs/task_timeseries/';
    %where are my condition onsets and nuisance regressors
    b.behavDir     = ['/gsfs0/data/ritcheym/data/fmri/orbit/analysis/orbit/' this_phase '/RSA/regressors/'];
    %where to put model output
    b.analysisDir  = ['/gsfs0/data/ritcheym/data/fmri/orbit/analysis/orbit/' this_phase '/RSA/first-level/unsmoothed/'];
    % define all subjects who have regressors:
    subjs = struct2cell(dir(b.behavDir));
    %clear rows that are not subjects:
    subjs = subjs(1,contains(subjs(1,:),'sub'));
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    b.curSubj = subjs{i};
    fprintf('\nRunning first level %s model specification for %s...\n',this_phase,b.curSubj);
    
    % create first level analysis folder for this subject
    if ~exist([b.analysisDir b.curSubj],'dir'),mkdir([b.analysisDir b.curSubj]); end
    
    
    %% Run FIRST LEVEL MODEL
    
    clear matlabbatch
    % Model Specification
    %--------------------------------------------------------------------------
    matlabbatch{1}.spm.stats.fmri_spec.dir                 = {fullfile(b.analysisDir,b.curSubj)};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units  = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT      = 1.5;
    
    % get all scan run regressor files:
    ons_regexp = ['\<' b.curSubj '.*onsets_RSA.mat'];
    onsetFiles = sort(cellstr(spm_select('FPList', [b.behavDir b.curSubj '/'],ons_regexp)));
    nui_regexp = ['\<' b.curSubj '.*nuisance'];
    covarFiles = sort(cellstr(spm_select('FPList', [b.behavDir b.curSubj '/'],nui_regexp)));
    
    % get encoding unsmoothed functional data (starts with subject number =
    % unsmoothed, otherwise starts with 'smooth'). Returns in run order
    func_regexp = ['\<' b.curSubj '.*MNI.*' lower(this_phase) '.nii$'];
    scanRuns = sort(cellstr(spm_select('List', [b.derivDir b.curSubj '/'], func_regexp)));
    nRuns = size(onsetFiles,1);

    if length(covarFiles) ~= length(scanRuns)
        error('Number of scan files does not match number of regressor files');
    end
    
    
    %% loop through runs
    %select all scans (only valid ones were smoothed, so don't need to restrict here):
    for run = 1:nRuns
        % get all 3D TRs of 4D .nii file for this run
        scan_regexp = ['\<' scanRuns{run,:}];
        scans = cellstr(spm_select('ExtFPListRec', [b.derivDir b.curSubj '/'], scan_regexp));
        
        % add data files, motion regressors, and onsets
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans       = scans;
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi        = onsetFiles(run);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = covarFiles(run);
    end % end of scan run loop
    
    % model masks
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;  % note- this has been changed to -inf in our spm_defaults.m
    matlabbatch{1}.spm.stats.fmri_spec.mask      = {'/gsfs0/data/ritcheym/data/fmri/orbit/analysis/orbit/myROIs/PMAT-MNI-space/wb_graymatter_mask.nii,1'};
    
    % Run specification
    %--------------------------------------------------------------------------
    spm_jobman('run',matlabbatch);
    clear matlabbatch
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
