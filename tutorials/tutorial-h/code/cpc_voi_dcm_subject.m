function matlabbatch = cpc_voi_dcm_subject(doRun)

% cpc_voi_dcm_subject(doRun) performs/sets up a first level analysis.
% Inputs:   doRun   -  if 0 -> just create struct
%                      if 1 -> run directly
%                      if 2 -> rund interactively (open Batch editor with
%                      analysis)
%
% Outputs: matlabbatch  -  batch containing information about analysis.
%
% Created: Aug 2019, Sam Harrison, Translational Neuromodeling Unit
% University and ETH Zürich

if nargin < 1
    doRun = 1;
end
subjNum = 1;
glmType= 'WedgeMotor_noderivs';

% First, define, where the data is located. myDataFolder needs to point to the
% folder where the Sub01 etc folders are located
[mFilePath,~] = fileparts(mfilename('fullpath'));
baseDir = fileparts(mFilePath);
myDataFolder = fullfile(baseDir,'data','visuomotor');

pathData=fullfile(myDataFolder,sprintf('Sub%02.0f',subjNum));
pathGLM=fullfile(pathData, 'glm', glmType);


% VOI extraction
matlabbatch = {};

% Common params
voi = struct();
voi.spmmat = {fullfile(pathGLM, 'SPM.mat')};
voi.adjust = 1;  % 'Main Effect - All Sessions'
voi.session = 1;
% Subject-specific mask
voi.roi{1}.mask.image = {fullfile(pathGLM, 'mask.nii')};
voi.roi{1}.mask.threshold = 0.5;
% Contrast image
voi.roi{2}.spm.spmmat = {fullfile(pathGLM, 'SPM.mat')};
voi.roi{2}.spm.threshdesc = 'none';
voi.roi{2}.spm.thresh = 1.0;  % On p-value, i.e. no thresh
% Sphere for extraction
voi.roi{3}.sphere.centre = [0 0 0]; % Global max
voi.roi{3}.sphere.radius = 8;
voi.roi{3}.sphere.move.global.spm = 2;  % i.e. `voi.roi{2}`
voi.roi{3}.sphere.move.global.mask = 'i1';
% Combine brain-mask and sphere for extraction
voi.expression = 'i1 & i3';

% Individual params
voi.name = 'Mot_R';
voi.roi{2}.spm.contrast = 5;  % 'Left > Right - All Sessions'
matlabbatch{end+1}.spm.util.voi = voi;
voi.name = 'Mot_L';
voi.roi{2}.spm.contrast = 6;  % 'Right > Left - All Sessions'
matlabbatch{end+1}.spm.util.voi = voi;
voi.name = 'Vis_R';
voi.roi{2}.spm.contrast = 3;  % 'Wedge1 > Wedge2 - All Sessions'
matlabbatch{end+1}.spm.util.voi = voi;
voi.name = 'Vis_L';
voi.roi{2}.spm.contrast = 4;  % 'Wedge2 > Wedge1 - All Sessions'
matlabbatch{end+1}.spm.util.voi = voi;

% Run
spm('defaults','FMRI');
if doRun == 2
    spm_jobman('initcfg');
    spm_jobman('interactive',matlabbatch);
elseif doRun == 1
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end

return