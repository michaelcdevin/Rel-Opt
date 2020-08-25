function[cost] =...
    Failure_Cost_Compute(AnchorsOverstrengthened, OverstrengthFactors,...
    NRows, NCols, DefaultTurbSpacing, DesignType, NSims, theta)

% Reliability_Compute determines the reliability of a multiline FOWT system
% Spencer Hallowell, UMASS Amherst, 3/8/2018

% Inputs:
% AnchorsOverstrengthened: List of anchors (can range from 1-120) that have
%                        OnverstrengthFactor applied to their strength
% OverstrengthFactor: Factor to multiply the strength of each anchor in
%                     AnchorsOverstrengthed


Z3 = zeros(1,3); %Preallocated vector of zeros

%% Some geometry and other initialization variables
TADistance = DefaultTurbSpacing*(sqrt(3)/3); %Spacing of turbines
NTurbs = NRows*NCols;
NLineSegments = 6; %number of failure points in each mooring line
SegNum = 1:NLineSegments; %Line segment numbers
AnchPricePerTon = 12300; % USD

%% Load in results of FAST analyses. These matrices will have distribution
%  Parameters (LN and Normal distributions) for anchor and line forces.
R = load(['ReliabilityResultsLN_Final,',num2str(theta),'deg.mat']);
Res = R.Res;

%% Load in results from site metocean analysis.
downtime_lengths = readmatrix('downtime_lengths.csv');
prob_of_20hr_window = readmatrix('prob_of_20hr_window.txt');

%% Load in displacements of turbines in failed configurations
load(['Surge_',num2str(theta),'deg.mat'])

% Allocate displacements in a matrix.
D(1,1) = Displacements(1).Surge;
D(1,2) = Displacements(1).Sway;
D(2,1) = (.5*TADistance) + Displacements(2).Surge;
D(2,2) = Displacements(2).Sway;
D(3,1) = (-.25*TADistance) + Displacements(3).Surge;
D(3,2) = (.25*DefaultTurbSpacing) + Displacements(3).Sway;
D(4,1) = (-.25*TADistance) + Displacements(4).Surge;
D(4,2) = (-.25*DefaultTurbSpacing) + Displacements(4).Sway;
D(5,1) = (.5*TADistance) + Displacements(5).Surge;
D(5,2) = (.5*DefaultTurbSpacing) + Displacements(5).Sway;
D(6,1) = (.5*TADistance) + Displacements(6).Surge;
D(6,2) = (-.5*DefaultTurbSpacing) + Displacements(6).Sway;
D(7,1) = -TADistance + Displacements(6).Surge;
D(7,2) = Displacements(6).Sway;

%% Precompute line standard deviations
[Res] = LineStdev(Res,SegNum); %Standard deviations of line forces assumed constant along length


%% Create geometry and connectivity
[TurbX,TurbY,AnchorX,AnchorY,AnchLineConnect,...
    LineConnect,TurbLineConnect,TurbAnchConnect,NAnchs,NLines,...
    AnchorTurbConnect,~,~,~,AnchAnchConnect,...
    LineAnchConnect,LineLineConnect,~,ALC] =...
    Geo_Setup_original(NRows,NCols,DefaultTurbSpacing,TADistance,NTurbs);
ZNTurbs_3 = zeros(NAnchs,3); %Preallocated matrix of zeros
TurbXOriginal = TurbX; %Original location of the turbines
TurbYOriginal = TurbY;

% Designate between anchors with only 1 or two connected lines vs. one line
At = sum(AnchLineConnect==0,2); %Anchors with 2 lines
Asingle = find(At~=0); %Anchors with 1 line
Amulti = find(At==0); %Anchors with 3 lines

%% Compile structures to use for demand distributions.
R1 = Res(1);
R2 = Res(2);
R3 = Res(3);
R4 = Res(4);
R6 = Res(6);
R7 = Res(7);
R10 = Res(10);
LD1 = R1.LP1(SegNum,1)';
LD2 = R1.LP2(SegNum,1)';
LD3 = R1.LP3(SegNum,1)';
LD1(2,:) = mean(R1.L1stdev);
LD2(2,:) = mean(R1.L2stdev);
LD3(2,:) = mean(R1.L3stdev);

LD_mu = zeros(NTurbs*3,length(SegNum));
LD_sigma = zeros(NTurbs*3,length(SegNum));

LD_mu(1:3:end,:) = repmat(LD1(1,:),NTurbs,1);
LD_mu(2:3:end,:) = repmat(LD2(1,:),NTurbs,1);
LD_mu(3:3:end,:) = repmat(LD3(1,:),NTurbs,1);
LD_sigma(1:3:end,:) = repmat(LD1(2,:),NTurbs,1);
LD_sigma(2:3:end,:) = repmat(LD2(2,:),NTurbs,1);
LD_sigma(3:3:end,:) = repmat(LD3(2,:),NTurbs,1);

%% More input stuff
TurbList = 1:NTurbs; %List of turbine numbers
TACx = AnchorX(TurbAnchConnect); %Rearrance connectivity
TACy = AnchorY(TurbAnchConnect);
tt = repmat(1:NTurbs,3,1); %Lists of vectors
% CS = load('OriginalCosines.mat'); %Precomputed cosines and sines
% C1 = CS.C1;
% C2 = CS.C2;
% C3 = CS.C3;
% S1 = CS.S1;
% S2 = CS.S2;
% S3 = CS.S3;
C1 = cosd(theta-120).*ones(size(ZNTurbs_3));
C2 = cosd(theta).*ones(size(ZNTurbs_3));
C3 = cosd(theta+120).*ones(size(ZNTurbs_3));
S1 = sind(theta-120).*ones(size(ZNTurbs_3));
S2 = sind(theta).*ones(size(ZNTurbs_3));
S3 = sind(theta+120).*ones(size(ZNTurbs_3));

ra = AnchorsOverstrengthened; %This gives the layout of the overstrengthened anchors (list form, with anchor #)
LinesImpactedTemp = zeros(NLines,1);
AnchorsImpactedTemp = zeros(NAnchs,1);
maxc = zeros(NSims,1);
naf = zeros(NAnchs,1);
nlf = zeros(NLines,1);
sim_failure_cost = zeros(NSims, 1);

for nn = 1:1:NSims %This can be run in parallel using parfor
    TurbX_New = TurbX; %New orientation of turbines
    TurbY_New = TurbY;
    LinesImpacted = ones(NLines,1); %List of lines impacted
    AnchorsImpacted = ones(NAnchs,1); %List of anchors impacted
    LineFailState = zeros(NLines,1); %Line failure state (binary)
    AnchorImpactedCount = zeros(NAnchs,1); %Number of anchors impacted.
    
%     rng(nn) %%%%% Random number generator can be fixed
    
    %% Generate line and anchor capacities
    % AnchorStrengths compose the distributed anchor strenghts (for failure
    % uncertainty purposes). MfgAnchorStrengths compose the anchor strength
    % prescribed for manufacturing (for cost evaluation purposes).
    [LineStrengths,AnchorStrengths, MfgAnchorStrengths] =...
        Capacity_Setup_Full_Line(NTurbs,NAnchs,1,SegNum,Res,DesignType,Asingle,Amulti);
    
    %% Amplify strength of anchors of interest by overstrength factor.
    % Overstrength factors can either be a single value applied uniformly
    % to all overstrengthened anchors, or each overstrengthened anchor can
    % have its own overstrength factor.
    if length(OverstrengthFactors) == length(AnchorsOverstrengthened)
        AnchorStrengths(ra) = OverstrengthFactors .* AnchorStrengths(ra);
        MfgAnchorStrengths(ra) = OverstrengthFactors .* MfgAnchorStrengths(ra);
    elseif length(OverstrengthFactors) == 1
        AnchorStrengths(ra) = OverstrengthFactors .* AnchorStrengths(ra);
        MfgAnchorStrengths(ra) = OverstrengthFactors .* MfgAnchorStrengths(ra);
    else
        error('OverstrengthFactors must be of length 1 or length(AnchorsOverstrengthened)')
    end

    %% Run through simulation:
%     Capacities of lines are assumed to remain constant
%     Capacities of anchors can change if there is torsion on the anchor
%     (caused by large turbine drift)
%     Demands on lines and anchors can change if there is turbine drift
%     (caused by anchor or line failure)
%     Simulation ends if Capacity > Demand for every component

    AnchorFail = zeros(size(AnchorStrengths)); %Anchor Failure state
    TurbFail = zeros(NTurbs,1); %Turbine failures
    TurbFailState = zeros(NTurbs,3); %Turbine line states
    nf1 = 0; %Counting variables for progressive failure checks.
    nf2 = -1;
    count = 1;
    while nf1 ~= nf2
        if count > 1
            nf1 = nf2;
        end
        %% Generate demands on anchors and lines. These are randomly sampled from the probability distributions.
        [AnchorDemands,LineDemands] = DemandsLN_FullLine3(Res,NAnchs,...
            AnchorFail,AnchorTurbConnect,...
            NTurbs,TurbFailState,TurbAnchConnect,AnchorStrengths,...
            LinesImpacted,AnchorsImpacted,SegNum,LD_mu,LD_sigma,...
            R1,R2,R3,R4,R6,R7,R10,TurbX_New,TurbY_New,Z3,...
            tt,TACx,TACy,C1,C2,C3,S1,S2,S3,ZNTurbs_3);
        
        % Is this the first step in the simulation?
        if count == 1
            LinesImpactedOld = LinesImpacted*0;
            AnchorsImpactedOld = AnchorsImpacted*0;
        else
            LinesImpactedOld = LinesImpacted+LinesImpactedOld;
            AnchorsImpactedOld = AnchorsImpacted+AnchorsImpactedOld;
            LinesImpactedOld(LinesImpactedOld>1) = 1;
            AnchorsImpactedOld(AnchorsImpactedOld>1) = 1;
        end
        
        % Determine failure states. Remember to include surge and sway
        % offsets (7.5 and 0.1, respectively)
        [LineFail,AnchorFail,~,LineStrengths,AnchorStrengths,TurbFailState,TurbX_New,TurbY_New] =...
            Failures_FullLine2(AnchorStrengths,AnchorDemands,LineStrengths,...
            LineDemands,TurbFail,TurbXOriginal+7.4998,...
            TurbYOriginal+0.1063,TurbList,ALC,D,LineAnchConnect);
        
        LineFailState = any(LineFail,2); %Check to see if any lines have failed
        
        %% Determine which parts of the system have changed
        [LinesImpacted,AnchorsImpacted] = DetectChangedElements(LinesImpactedOld,...
                        AnchorsImpactedOld,LineFail,AnchorFail,...
                        AnchAnchConnect,LineLineConnect,...
                        AnchLineConnect,LineAnchConnect,LineConnect,...
                        TurbLineConnect,TurbAnchConnect,AnchorTurbConnect,nn,LinesImpactedTemp,AnchorsImpactedTemp);
        AnchorImpactedCount = AnchorImpactedCount + AnchorsImpacted;
        %% Reduce the strength of anchors who are under torsion due to a failure
        AnchorStrengths(AnchorImpactedCount==1) = AnchorStrengths(AnchorImpactedCount==1)*0.8;
        AnchorImpactedCount = AnchorImpactedCount + AnchorImpactedCount;
        
        %% Update number of failures
        na = sum(AnchorFail); %Number of anchor failures
        lftemp = sum(LineFail,2);
        lftemp(lftemp>1) = 1;
        nl = sum(sum(lftemp)); %Number of line failures
        nf2 = na + nl; %Total number of failures        
        count = count + 1;
    end %Simulation ends after this
    
    maxc(nn) = count; %Total number of iterations
    nlf = nlf + LineFailState; %Total number of lines failed (out of all simulations)
    naf = naf + AnchorFail; %Total number of anchors failed (out of all simulations)-

    % Calculate cost of failure for this simulation
    sim_failure_cost(nn) = failure_cost(LineFailState, AnchorFail,...
        AnchPricePerTon, MfgAnchorStrengths, downtime_lengths,...
        prob_of_20hr_window);
end

% Calculate added cost of overstrengthening anchors in this setup
OSF_cost = osf_cost(AnchorsOverstrengthened, AnchPricePerTon,...
    MfgAnchorStrengths, NAnchs);
% disp(['Total OSF costs: ', num2str(OSF_cost)])
% Average all of the failure costs from the Monte Carlo
avg_failure_cost = sum(sim_failure_cost)/NSims;
% disp(['Total failure costs: ', num2str(avg_failure_cost)])
        
% HeatMap(TurbX,TurbY,AnchorX,AnchorY,LineConnect,timesStrengthened)
%PaintLines(TurbX,TurbY,AnchorX,AnchorY,LineFail,LineConnect,AnchorFail,TurbFail,TurbAnchConnect)

cost = avg_failure_cost + OSF_cost;



