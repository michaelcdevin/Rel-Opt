%% Strengthened Anchor Sweep Test
% Tracks reliabilities and strengthened anchors for a range of number of
% overstrengthened anchors in order to determine when optimizing a smaller
% number of anchors is superior to slightly strengthening all anchors
%
% Michael Devin, Oregon State University, 2019 July 05

clear
clc
tic

% User inputs
nStrengthenedAnchors = 5:5:120;
OverstrengthFactor = 1.5;
nAnchors = 120;

% Preallocate arrays
BestRels = zeros(length(nStrengthenedAnchors),1);
BestConfigs = zeros(length(nStrengthenedAnchors), max(nStrengthenedAnchors));

% Run optimization for each nStrengthenedAnchors
for j = 1:length(nStrengthenedAnchors)
    [BestRel,Op_Turbines] = Anchor_Optimization_2019_09_16(nStrengthenedAnchors(j), OverstrengthFactor);
    BestRels(j,1) = BestRel;
    BestConfigs(j,1:length(Op_Turbines)) = Op_Turbines;
end

% Test timesStrenghtened
%     timesStrengthened = randi([0,50],120,1);
    
% % Generate variables for base configuration map
% Spacing = 837.6/(sqrt(3)/3); %Spacing of turbines
% Hypot = Spacing*sqrt(3)/3; %Hypotnuse between turbines
% NRows = 10; %Number of rows
% NCols = 10; %Number of columns
% NTurbs = NRows*NCols; %Number of turbines
% 
% [TurbX,TurbY,AnchorX,AnchorY,~,LineConnect,~,~,~,~,~,~,~,~,~,~,~,~,~] =...
%     Geo_Setup(NRows,NCols,Spacing,Hypot,NTurbs);
% 
% % Create heatmap
% HeatMap(TurbX,TurbY,AnchorX,AnchorY,LineConnect,timesStrengthened)

% Export results to CSV file
CSVdata = [nStrengthenedAnchors',BestRels,BestConfigs];
csvwrite('ConvergenceValues_2019_09_23.csv',CSVdata);

toc;