function matlabbatch = cpc_glm_dcm_subject(subjNum,derivs,doRun)

% teach_glm_subject(subjNum,derivs,doRun) performs/sets up a first level analysis. 
% Inputs:   subjNum -  number of subject (1 to 4)
%           derivs  -  use derivatis =1 or not =0
%           doRun   -  if 0 or not defined -> just create struct
%                      if 1 -> run directly
%                      if 2 -> rund interactively (open Batch editor with
%                      analysis)
%
% Outputs: matlabbatch  -  batch containing information about analysis.
% 
% Created: Oct 2018, Jakob Heinzle, Translational neuromodeling Unit, IBT
% University and ETH Zürich

if nargin < 1
    subjNum = 1;
end

if nargin < 2
    derivs = 0;
end

if nargin < 3
    doRun = 1;
end

% First, define, where the data is located. myDataFolder needs to point to the 
% folder where the Sub01 etc folders are located
[mFilePath,functionName] = fileparts(mfilename('fullpath'));
baseDir = fileparts(mFilePath);
myDataFolder = fullfile(baseDir,'data','visuomotor'); 
glmType= 'WedgeMotor'; % WedgeMod



pathData=fullfile(myDataFolder,sprintf('Sub%02.0f',subjNum));

if derivs % use derivatives
pathGLM=fullfile(pathData,'glm',sprintf('%s_derivs',glmType));
derivVec = [1 1];
funcReg =[1 2 3; 4 5 6; 7 8 9;10 11 12];
nFuncReg = numel(funcReg);
else
    pathGLM=fullfile(pathData,'glm',sprintf('%s_noderivs',glmType));
    derivVec = [0 0];
    funcReg =[1;2;3;4];
    nFuncReg = numel(funcReg);
end

mkdir(pathGLM);
delete(fullfile(pathGLM,'*'));

matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pathGLM);
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16;
for k=1 % cycle over runs.
    % load the data: Here s8wafmri..., Change next line if this is
    % different.
matlabbatch{1}.spm.stats.fmri_spec.sess(k).scans = cellstr(spm_select('ExtFPList',fullfile(pathData,'functional'),sprintf('s8wafmri%02.0f.nii',k),Inf));
matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(k).multi = cellstr(fullfile(pathData,'behav',sprintf('%sRegs%02.0f.mat',glmType,k)));
matlabbatch{1}.spm.stats.fmri_spec.sess(k).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess(k).multi_reg = cellstr(fullfile(pathData,'functional',sprintf('rp_afmri%02.0f.txt',k)));
matlabbatch{1}.spm.stats.fmri_spec.sess(k).hpf = 128;
end
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = derivVec;
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Main Effect';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = eye(nFuncReg);
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'repl';

matlabbatch{3}.spm.stats.con.consess{2}.fcon.name = 'Effect of motion';
matlabbatch{3}.spm.stats.con.consess{2}.fcon.weights = [zeros(6,nFuncReg) eye(6)];
matlabbatch{3}.spm.stats.con.consess{2}.fcon.sessrep = 'repl';

matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Wedge1 > Wedge2';
conVec = zeros(1,nFuncReg); conVec(funcReg(1,1))=1; conVec(funcReg(2,1))=-1;
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = conVec;
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'repl';

matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Wedge2 > Wedge1';
conVec = zeros(1,nFuncReg); conVec(funcReg(1,1))=-1; conVec(funcReg(2,1))=1;
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = conVec;
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'repl';

matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Left > Right';
conVec = zeros(1,nFuncReg); conVec(funcReg(3,1))=1; conVec(funcReg(4,1))=-1;
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = conVec;
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'repl';

matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Right > Left';
conVec = zeros(1,nFuncReg); conVec(funcReg(3,1))=-1; conVec(funcReg(4,1))=1;
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = conVec;
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'repl';

matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'Mean Effect of visual';
conVec = zeros(1,nFuncReg); conVec(funcReg(1,1))=1; conVec(funcReg(2,1))=1;
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = conVec;
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'repl';

matlabbatch{3}.spm.stats.con.delete = 0;

matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
matlabbatch{4}.spm.stats.results.conspec.contrasts = 5;
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.001;
matlabbatch{4}.spm.stats.results.conspec.extent = 0;
matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;
matlabbatch{4}.spm.stats.results.export{2}.pdf = true;

spm('defaults','FMRI');

if doRun == 2
spm_jobman('initcfg');
spm_jobman('interactive',matlabbatch);
elseif doRun == 1
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);
end
