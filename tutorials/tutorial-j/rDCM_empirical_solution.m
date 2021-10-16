%% Computational Psychiatry Course (CPC) 2021
%
% Tutorial: Regression dynamic causal modeling
% 
% This script describes the use of the regression dynamic causal modeling 
% (rDCM) toolbox for whole-brain effective connectivity analyses. The 
% script demonstrates how to apply the rDCM toolbox for an actual empirical
% dataset (from a single subject), how to perform Bayesian model comparison
% and how to compare different conditions.
%
% Note that this script will not simply run because you are not provided
% the data (i.e., BOLD signal time series) and structural connectome. This
% is because of legal (ethical) considerations that prevent us from sharing 
% the data.
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


% get path of function
P     = mfilename('fullpath');
P_ind = strfind(P,'rDCM_empirical_solution');

% load the structural connectome
temp = load(fullfile(P(1:P_ind-1),'fMRI_motor','StructConn.mat'));
args.a = temp.conn;

% load the BOLD signal time series from the LH session
load(fullfile(P(1:P_ind-1),'fMRI_motor','Data_LH.mat'))

% set-up a DCM structure, using the structural connectome as network architecture
DCM = tapas_rdcm_model_specification(Y,U,args);

% perform model inversion
[output,~] = tapas_rdcm_estimate(DCM,'r',[],1);

% save the results for the LH session
LH.output = output;

% clear variables
clear DCM output


% set-up a DCM structure, fully connected model
DCM = tapas_rdcm_model_specification(Y,U,[]);

% perform model inversion
[output,~] = tapas_rdcm_estimate(DCM,'r',[],1);

% save the results for the LH session
LH_full.output = output;


% create matrix containing negative free energies of the two models
F = [LH.output.logF, LH_full.output.logF];

% perform fixed-effects Bayesian model selection (using own code)
% alternatively, SPM routines can be used to perform BMS
F    = F - max(F);
eF   = exp(F);
post = eF/sum(eF);

% plot the posterior probability
figure;
col = [0.6 0.6 0.6];
bar(post,'FaceColor',col);
xlim([0 3])
set(gca,'xtick',[1 2])
set(gca,'xticklabel',{'Struct. Conn.','Full'},'FontSize',14)
title('Posterior probability (FFX BMS)')
ylabel('posterior prob.')
box off

% clear variable
clear U Y DCM output


% load the BOLD signal time series from the RH session
load(fullfile(P(1:P_ind-1),'fMRI_motor','Data_RH.mat'))

% set-up a DCM structure, using the structural connectome as network architecture
DCM = tapas_rdcm_model_specification(Y,U,args);

% perform model inversion
[output,~] = tapas_rdcm_estimate(DCM,'r',[],1);

% save the results for the LH session
RH.output = output;


% plot the effect of hand movement condition
plot_effect_of_hand_rDCM(LH,RH)
