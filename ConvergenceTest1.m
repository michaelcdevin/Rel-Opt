%% Strengthened Anchor Heat Map Generation
% Generates a heat map of the standard multi-line anchor configuration
% used by Reliability_Compute.m, and a CSV file with all optimized
% reliabilities and configurations found in each test.
%
% Michael Devin, Oregon State University, 20 January 2019

clear
clc
tic

% User inputs
nTests = 25;
nStrengthenedAnchors = 10;
OverstrengthFactor = 1.3;
nAnchors = 120;

% Preallocate arrays
BestRels = zeros(nTests,1);
BestConfigs = zeros(nTests, nStrengthenedAnchors);
timesStrengthened = zeros(nAnchors, 1);

% Run optimization and determine number of times each anchor was selected
for j = 1:nTests
    [BestRel,Op_Turbines] = Anchor_Optimization_RBDO_Iterative(nStrengthenedAnchors, OverstrengthFactor);
    BestRels(j,1) = BestRel;
    BestConfigs(j,:) = Op_Turbines;
end

for j = 1:nAnchors
    timesStrengthened(j,1) = sum(BestConfigs(:)==j);
end

% Test timesStrenghtened
%     timesStrengthened = randi([0,50],120,1);
    
% Generate variables for base configuration map
Spacing = 837.6/(sqrt(3)/3); %Spacing of turbines
Hypot = Spacing*sqrt(3)/3; %Hypotnuse between turbines
NRows = 10; %Number of rows
NCols = 10; %Number of columns
NTurbs = NRows*NCols; %Number of turbines

[TurbX,TurbY,AnchorX,AnchorY,~,LineConnect,~,~,~,~,~,~,~,~,~,~,~,~,~] =...
    Geo_Setup(NRows,NCols,Spacing,Hypot,NTurbs);

% Create heatmap
HeatMap(TurbX,TurbY,AnchorX,AnchorY,LineConnect,timesStrengthened)

% Export results to CSV file
CSVdata = [BestRels,BestConfigs];
csvwrite('ConvergenceValues.csv',CSVdata);

toc;