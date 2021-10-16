function plot_effect_of_hand_rDCM(LH,RH)
% 
% Input
%   LH      - structure containing rDCM results for left-hand movements
%   RH      - structure containing rDCM results for right-hand movements
%

% load left and right movement results (if inputs are empty)
if ( isempty(LH) || isempty(RH) )
    LH = load('DCM_model1_LH.mat'); % adapt filename respectively
    RH = load('DCM_model1_RH.mat'); % adapt filename respectively
end

% compute the difference
Amatrix_allSubjects_LR = LH.output.Ep.A - RH.output.Ep.A;

% plot the effect of hand on connectivity
figure('units','normalized','outerposition',[0 0 1 1])
imagesc(Amatrix_allSubjects_LR)
hold on

% plot lines highlighting motor-related regions in PcG and PoG
plot([54.5 54.5],[1 size(Amatrix_allSubjects_LR,1)],'k-')
plot([56.5 56.5],[1 size(Amatrix_allSubjects_LR,1)],'k-')
plot([1 size(Amatrix_allSubjects_LR,1)],[54.5 54.5],'k-')
plot([1 size(Amatrix_allSubjects_LR,1)],[56.5 56.5],'k-')
plot([126.5 126.5],[1 size(Amatrix_allSubjects_LR,1)],'k-')
plot([128.5 128.5],[1 size(Amatrix_allSubjects_LR,1)],'k-')
plot([1 size(Amatrix_allSubjects_LR,1)],[126.5 126.5],'k-')
plot([1 size(Amatrix_allSubjects_LR,1)],[128.5 128.5],'k-')

text(size(Amatrix_allSubjects_LR,1)+2, 55, 'to PrG (M1)','FontSize',12)
text(size(Amatrix_allSubjects_LR,1)+2, 127, 'to PoG (SM1)','FontSize',12)
text(size(Amatrix_allSubjects_LR,1)+2, 55, 'to PrG (M1)','FontSize',12)
h = text(55, -2, 'from PrG (M1)','FontSize',12); set(h,'Rotation',30);
h = text(127, -2, 'from PoG (SM1)','FontSize',12); set(h,'Rotation',30);


% labels and colormap
caxis([-0.02 0.02])
axis square
xlabel('region (from)','FontSize',14)
ylabel('region (to)','FontSize',14)

end