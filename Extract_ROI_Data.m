% Extract single trial estimates from select ROIs. Write output to a csv file for further analysis

% add spm12 to searchpath
spm_dir = fullfile(fileparts(mfilename('fullfile')), 'spm12');
addpath(spm_dir);

%% Parameters

roi_dir = '/gsfs0/data/kurkela/Desktop/Masters/rois';
roi_file = 'PM_voxel_clusters.nii'; % single .nii file. contains all ROIs for analysis
roi_full_file = fullfile(roi_dir, roi_file);

PM_rois_names = {'pHipp' 'PREC', 'PCC', 'MPFC', 'PHC', 'RSC', 'aAG', 'pAG'};
PM_rois_indx = cell(1,length(PM_rois_names));

singleTrialEst_dir = fullfile(fileparts(mfilename('fullfile')), 'st_estimates');

%% Routine

% relice ROIs
ref = spm_select('FPList', fullfile(singleTrialEst_dir, 'sub-s001', 'spmTs'), 'Sess01_Remember_001_T.nii');
matlabbatch{1}.spm.spatial.coreg.write.ref = {ref};
matlabbatch{1}.spm.spatial.coreg.write.source = {roi_full_file};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
spm_jobman('run', matlabbatch);

% load ROIs
roi_full_file = fullfile(roi_dir, ['r' roi_file]);
ROIs_V = spm_vol(roi_full_file);
[ROIs_Y, ROIs_XYZmm] = spm_read_vols(ROIs_V);

% specify single trial estimates
st_estimate_files = cellstr(spm_select('FPListRec', singleTrialEst_dir, '.*Remember.*_T\.nii'));
st_estimate_mats = cellstr(spm_select('FPListRec', singleTrialEst_dir, 'SPM.mat'));
st_estimate_mats = st_estimate_mats(contains(st_estimate_mats, 'Remember'));

assert(length(st_estimate_files) == length(st_estimate_mats), 'error')

% loops

subject_list = cell(length(st_estimate_files), 1);
sess_list = cell(length(st_estimate_files), 1);
trialNum_list = cell(length(st_estimate_files), 1);
ons_list = nan(length(st_estimate_files), 1);
roi_tbl = array2table(nan(3888, length(PM_rois_names)), 'VariableNames', PM_rois_names);

for s = 1:length(st_estimate_files)

   fprintf('\n%d/%d\n', s, length(st_estimate_files));

   subject = regexp(st_estimate_files{s}, 'sub-s[0-9]{3}', 'match', 'once');
   sess = regexp(st_estimate_files{s}, 'Sess[0-9]{2}', 'match', 'once');
   trialNum = regexp(st_estimate_files{s}, '(?<=_)[0-9]{3}(?=_)', 'match', 'once');

   subF = contains(st_estimate_mats, subject);
   sesF = contains(st_estimate_mats, sess);
   triF = contains(st_estimate_mats, trialNum);
   trial_mat = st_estimate_mats{subF & sesF & triF};
   assert(size(trial_mat, 1) == 1, 'error')

   load(trial_mat)
   ons = SPM.Sess.U(1).ons;

   for i = 1:length(PM_rois_names)

      % extract ST estimate in this ROI. Take the mean. Add to the table
      indx = find(ROIs_Y == i);
      [x,y,z] = ind2sub(size(ROIs_Y), indx);
      XYZ = [x y z]';

      roi_tbl{s, PM_rois_names{i}} = mean(spm_get_data(st_estimate_files{s}, XYZ), 2);

   end

  % store everything
  subject_list{s} = subject;
  sess_list{s} = sess;
  trialNum_list{s} = trialNum;
  ons_list(s) = ons;

  clc;

end

metaData_tbl = table(subject_list, sess_list, trialNum_list, ons_list, 'VariableName', {'subject', 'sess', 'trialNum', 'ons'});

final_tbl = [metaData_tbl, roi_tbl];

writetable(final_tbl, 'Extracted_ROI_data.csv', 'Filetype', 'text');
