tbl_one = readtable('intermediate/01_Extracted_ROI_data_1s.csv');
tbl_four = readtable('intermediate/01_Extracted_ROI_data_4s.csv');
tbl_old = readtable('intermediate/01_Extracted_ROI_data_old.csv');

%% Four vs One

head(tbl_one)
head(tbl_four)

% The trial subjects, sessions, trialNum, and onsets are the same
isequal(tbl_one.subject, tbl_four.subject)
isequal(tbl_one.sess, tbl_four.sess)
isequal(tbl_one.trialNum, tbl_four.trialNum)
isequal(tbl_one.ons, tbl_four.ons)

% How correlated are the trial series?
hipp = corr(tbl_one.pHipp, tbl_four.pHipp)
prec = corr(tbl_one.PREC, tbl_four.PREC)
pcc  = corr(tbl_one.PCC, tbl_four.PCC)
mpfc = corr(tbl_one.MPFC, tbl_four.MPFC)
phc  = corr(tbl_one.PHC, tbl_four.PHC)
rsc  = corr(tbl_one.RSC, tbl_four.RSC)
aAG  = corr(tbl_one.aAG, tbl_four.aAG)
pAG  = corr(tbl_one.pAG, tbl_four.pAG)

M = mean([hipp, prec, pcc, mpfc, phc, rsc, aAG, pAG])

%% One vs Old

head(tbl_one)
head(tbl_old)

% The trial subjects, sessions, trialNum, and onsets are the same
isequal(tbl_one.subject, tbl_old.subject)
isequal(tbl_one.sess, tbl_old.sess)
isequal(tbl_one.trialNum, tbl_old.trialNum)
isequal(tbl_one.ons, tbl_old.ons)

% How correlated are the trial series?
hipp = corr(tbl_one.pHipp, tbl_old.pHipp) 
prec = corr(tbl_one.PREC, tbl_old.PREC) 
pcc  = corr(tbl_one.PCC, tbl_old.PCC) 
mpfc = corr(tbl_one.MPFC, tbl_old.MPFC) 
phc  = corr(tbl_one.PHC, tbl_old.PHC) 
rsc  = corr(tbl_one.RSC, tbl_old.RSC) 
aAG  = corr(tbl_one.aAG, tbl_old.aAG) 
pAG  = corr(tbl_one.pAG, tbl_old.pAG) 

M = mean([hipp, prec, pcc, mpfc, phc, rsc, aAG, pAG])
