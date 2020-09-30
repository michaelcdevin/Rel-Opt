% NSims Sensitivity Test 3
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

% Load data needed for the simulation
R = load(['ReliabilityResultsLN_Final,',num2str(theta),'deg.mat']);
Res = R.Res;
downtime_lengths = readmatrix('downtime_lengths_12hr.csv');
prob_of_12hr_window = readmatrix('prob_of_12hr_window.txt');
load(['Surge_',num2str(theta),'deg.mat']);

% Plotting colors
set(0, 'DefaultAxesColorOrder', lines(100));

global_ind_cost = zeros(nPop, nEndSims);
global_avg_cost = zeros(nPop, nEndSims);
for j = 1:2:25
    disp(j)
    anchors = randsample(nAnchors, nOverstrengthenedAnchors);
    for k = 1:nEndSims
        current_cost = Failure_Cost_Compute(anchors, OverstrengthFactor,...
            NRows, NCols, TurbSpacing, DesignType, NSims, theta,...
            Displacements, Res, downtime_lengths, prob_of_12hr_window);
        global_ind_cost(j,k) = current_cost;
        global_avg_cost(j,k) = mean(global_ind_cost(j,1:k));
    end
    semilogx(NSims:NSims:nEndSims*NSims, global_avg_cost(j,:), 'LineWidth', 1)
    hold on
end
h = gcf;
set(gca, 'FontName', 'Baskerville', 'FontSize', 12, 'LineWidth', 1)
ylabel('Failure cost [USD]')
xlabel('Number of simulations')
grid on
xlim([5 50000])


set(h,'PaperOrientation','landscape');
set(h,'PaperPosition', [1 1 28 19]);
print('num_sims_test_3.pdf','-dpdf','-fillpage')
savefig('NSims_test_3.fig')