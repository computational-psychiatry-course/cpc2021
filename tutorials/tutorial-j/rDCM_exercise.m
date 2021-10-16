%% Computational Psychiatry Course (CPC) 2021
%
% Tutorial: Regression dynamic causal modeling
% 
% This script describes the use of the regression dynamic causal modeling 
% (rDCM) toolbox for whole-brain effective connectivity analyses. The 
% script will ask you to perform several simulations, exploring different 
% aspects of the model and offering a better feeling for the behaviour of 
% the model.
% 

% ----------------------------------------------------------------------
% 
% stefanf@biomed.ee.ethz.ch
%
% Author: Stefan Fraessle, TNU, UZH & ETHZ - 2021
% Copyright 2021 by Stefan Fraessle <stefanf@biomed.ee.ethz.ch>
%
% Licensed under GNU General Public License 3.0 or later.
% Some rights reserved. See COPYING, AUTHORS.
% 
% ----------------------------------------------------------------------



%% load dummy large-scale DCM and display the connectivity matrix

% set the RNG for reproducibility
rng(0)

% get path of rDCM toolbox
P        = mfilename('fullpath');
rDCM_ind = strfind(P,fullfile('rDCM','code'));

% load the example network architecture
temp = load(fullfile(P(1:rDCM_ind-1),'rDCM','test','DCM_LargeScaleSmith_model1.mat'));
DCM  = temp.DCM;


% display the connectivity structure and the time series
figure('units','normalized','outerposition',[0 0 1 1])
imagesc(DCM.Ep.A)
title('Ground truth: endogenous connectivity','FontSize',20)
axis square
caxis([-1 1])
xlabel('region (from)','FontSize',18)
ylabel('region (to)','FontSize',18)



% -----------------------------------------------------------------------
%   Regression DCM under fixed connectivity
% -----------------------------------------------------------------------

%% specify options for rDCM analysis and generate synthetic data

% specify the options for the synthetic BOLD signal 
% (note that these options are only required for simulating synthetic data 
%  but not for model inversion. Hence, they are only necessary for 
%  simulations but not when analyzing empirical data.)
options.SNR             = 3;
options.y_dt            = 0.5;

% specify additional options
% (note that these options refer to specific setting for model inversion 
%  during the rDCM analysis; for details on the respective options,
%  please refer to the Manual.pdf)
options.filter_str      = 4;

% run a simulation (synthetic) analysis
type = 's';

% generate synthetic data (for simulations)
DCM = tapas_rdcm_generate(DCM, options, options.SNR);


%% model estimation (fixed network architecture)

% get time
currentTimer = tic;

% run rDCM analysis with network architecture (performs model inversion)
[output, options] = tapas_rdcm_estimate(DCM, type, options, 1);

% output elapsed time
toc(currentTimer)

% plotting options
plot_regions = [1 12];
plot_mode    = 2; 

% visualize the results
tapas_rdcm_visualize(output, DCM, options, plot_regions, plot_mode)

% output a summary of the results
fprintf('\nSummary (rDCM - fixed)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model parameter recovery: \n')
fprintf('Root mean squared error (RMSE): %.3G\n',sqrt(output.statistics.mse))

% evaluate sensitivity and specificity (function provided in folder)
[sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output,DCM);

% output sensitivity and specificity
fprintf('Sensitivity: %.3G - Specificity: %.3G\n',sensitivity,specificity)



%% vary signal-to-noise ratio of synthetic data

% asign new DCM
DCM2 = temp.DCM;

% specify the options; use an SNR = 1 for the synthetic BOLD signal
... % ADD

% generate synthetic data (for simulations)
DCM2 = ... % ADD
    
% run rDCM analysis
[output2, options] = ... % ADD
    
% visualize the results, BUT plotting the power spectral density
... % ADD

% output a summary of the results
... % ADD



% -----------------------------------------------------------------------
%   Regression DCM under sparsity constraints
% -----------------------------------------------------------------------

%% set options for sparse rDCM analysis

% clear the output files and DCM files
clear output output2 options options2 DCM DCM2

% specify the options for the synthetic BOLD signal 
% (note that these options are only required for simulating synthetic data 
%  but not for model inversion. Hence, they are only necessary for 
%  simulations but not when analyzing empirical data.)
options.SNR             = 3;
options.y_dt            = 0.5;

% specify additional options
% (note that these options refer to specific setting for model inversion 
%  during the sparse rDCM analysis; for details on the respective options,
%  please refer to the Manual.pdf)
options.p0_all          = 0.15;  % single p0 value (for computational efficiency)
options.iter            = 100;
options.filter_str      = 5;
options.restrictInputs  = 1;



%% model estimation (sparsity constraints)

% asign DCM
DCM = temp.DCM;

% generate synthetic data (for simulations)
DCM = ... % ADD

% run rDCM analysis with sparsity constraints (performs model inversion)
[output, options] = ... % ADD

% visualize the results
... % ADD

% evaluate sensitivity and specificity (function provided in folder)
[sensitivity, specificity] = ... % ADD

% output a summary of the results
fprintf('\nSummary (rDCM - sparsity)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model architecture and parameter recovery: \n')
fprintf('Sensitivity: %.3G - Specificity: %.3G\n',sensitivity,specificity)
fprintf('Root mean squared error (RMSE): %.3G\n',sqrt(output.statistics.mse))



%% allow driving inputs to be pruned

% change options to allow for driving inputs to be pruned as well
... % ADD
    
% run rDCM analysis with sparsity constraints (performs model inversion)
[output2, options2] = ... % ADD

% visualize the results
... % ADD
    
% evaluate sensitivity and specificity (function provided in folder)
[sensitivity, specificity] = ... % ADD

% output a summary of the results
fprintf('\nSummary (rDCM - sparsity - All inputs)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model architecture and parameter recovery: \n')
fprintf('Sensitivity: %.3G - Specificity: %.3G\n',sensitivity,specificity)
fprintf('Root mean squared error (RMSE): %.3G\n',sqrt(output2.statistics.mse))



%% alter prior assumptions on sparsity of the network

% change options to fix driving inputs again
options.restrictInputs  = 1;

% set the p0 values
p0_test = [0 1];

% results cell
output_all = cell(2,1);

% reduce number of permutations (for computational efficiency)
options.iter = 50;

% run rDCM analysis with sparsity constraints - p0 = 0
options.p0_all          = p0_test(1);
[output_p1, options_p1] = ... % ADD

% run rDCM analysis with sparsity constraints - p0 = 1
options.p0_all          = p0_test(2);
[output_p2, options_p2] = ... % ADD

% visualize the results
tapas_rdcm_visualize(output_p1, DCM, options_p1, plot_regions, plot_mode)
tapas_rdcm_visualize(output_p2, DCM, options_p2, plot_regions, plot_mode)


% output a summary of the results
fprintf('\nSummary (rDCM - sparsity)\n')
fprintf('-------------------\n\n')
fprintf('Accuracy of model architecture recovery: \n')


% output sensitivits and specificity
for int = 1:length(p0_test)
    switch int
        case 1
            [sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output_p1,DCM);
        case 2
            [sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output_p2,DCM);
    end
    fprintf('p0 = %d || Sensitivity: %.3G - Specificity: %.3G\n',p0_test(int),sensitivity,specificity)
end
