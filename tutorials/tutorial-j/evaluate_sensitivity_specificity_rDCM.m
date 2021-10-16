function [sensitivity, specificity] = evaluate_sensitivity_specificity_rDCM(output,DCM)

% get true parameters
par_true = tapas_rdcm_ep2par(DCM.Tp);
idx_true = par_true ~= 0;

% get inferred connections
Ip_est  = tapas_rdcm_ep2par(output.Ip);
lb      = log(1/10);
idx_Ip  = log(Ip_est./(1-Ip_est)) > lb;

% specify which parameters to test (driving inputs where fixed)
temp2.A  = ones(size(DCM.a))-eye(size(DCM.a));
temp2.B  = zeros(size(DCM.b));
temp2.C  = zeros(size(DCM.c));
vector   = tapas_rdcm_ep2par(temp2);
vector   = vector == 1;

% evaluate TP, FP, TN, FN
true_positive   = sum((idx_Ip(vector) == 1) & (idx_true(vector) == 1));
false_positive  = sum((idx_Ip(vector) == 1) & (idx_true(vector) == 0));
true_negative   = sum((idx_Ip(vector) == 0) & (idx_true(vector) == 0));
false_negative  = sum((idx_Ip(vector) == 0) & (idx_true(vector) == 1));

% evaluate sensitivity and specifity
sensitivity = true_positive/(true_positive + false_negative);
specificity = true_negative/(true_negative + false_positive);

end