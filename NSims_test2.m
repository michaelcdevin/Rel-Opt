% NSims Sensitivity Test 2
clear
clc
clf
close all

% Problem parameters
nPop = 25;
nAnchors = 120;
nOverstrengthenedAnchors = 20;
nEndSims = 10000;
OverstrengthFactor = 1.5;
NRows = 10;
NCols = 10;
TurbSpacing = 1451;
DesignType = 'Real multi';
NSims = 5;
theta = 0;

% Plotting colors
set(0, 'DefaultAxesColorOrder', lines(100));
global_ind_rels = zeros(nPop, nEndSims);
global_avg_rels = zeros(nPop, nEndSims);
for j = 1:nPop
    anchors = randsample(nAnchors, nOverstrengthenedAnchors);
    for k = 1:nEndSims
        current_rel = Visualization_original(anchors, OverstrengthFactor,...
            NRows, NCols, TurbSpacing, DesignType, NSims, theta);
        global_ind_rels(j,k) = current_rel;
        global_avg_rels(j,k) = mean(global_ind_rels(j,1:k));
    end
    plot(global_avg_rels(j,:),NSims:NSims:nEndSims*NSims)
    hold on
end
title('Random Overstrenghtened Anchor Configs vs. NSims')
xlabel('Reliability')
ylabel('NSims')

print('NSims_test_2.pdf','-dpdf','-fillpage')
savefig('NSims_test_2.fig')