function [output] = cpc2021_setup_dcm()

% This function can be run without argument. It will look where it 
% is located and then will setup the path so that it includes your spm
% version and your code folder. In order for this to run, make sure, you have installed
% SPM and downloaded the data as described in the file .txt.
%

p = mfilename('fullpath');
[filePath,fileName] = fileparts(p);
tutorialRoot = fileparts(filePath);

% add paths for SPM and for code in 
spmPath = fullfile(filePath,'spm12');
disp(sprintf('Adding %s to the path!',spmPath));
addpath(spmPath);

ownPath = fullfile(filePath); % use genpath, in case there are subfolders.
disp(sprintf('Adding %s to the path!',ownPath));
addpath(ownPath);

disp(' ');
disp(' ');
disp('--------------------------------------------------------------');
disp('I am trying to find out which SPM version is installed.');
disp(' ');
try 
    [a,b] = spm('ver');
    disp(sprintf('You are running  %s, release number: %s.',a,b));
    output(1) = 1; % all good
catch
    disp('Something went wrong, SPM does not seem to be in your path!');
    output(1) = 0; % still some problem
end
disp(' ');
disp(' ');
disp('--------------------------------------------------------------');
dataPath = fullfile(tutorialRoot,'data');
disp('I am checking whether data is downloaded and in the right place.');
disp(' ');

checkFile = fullfile(dataPath,'visuomotor','Sub01','functional','s8wafmri01.nii'); % !!! This needs some checking.
if exist(checkFile)==2;
    disp(sprintf('Looks good. \nI found the header of the first functional: %s',checkFile));
    output(2) = 1;
else
    disp('Something went wrong!');
    disp(sprintf('Could not locate %s.',checkFile));
    output(2) = 0;
end

disp(' ');
disp(' ');
disp('------ Summary of this check ------');
if sum(output)==2
    disp('Great you are ready for the tutorial!');
else
    disp('Something is not ready yet. \n Please try again or ask the tutors to help with setup!');
end
disp('------------------------------------');