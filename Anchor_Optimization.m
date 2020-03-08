% Anchor optimization for reliability calculations of multiline FOWT array
% For use in research of Spencer Hallowell and/or Bryony DuPont
% Michael Devin, Oregon State University, 4/2/2018

function [BestRel,Op_Turbines] =...
    Anchor_Optimization(nStrengthenedAnchors,...
    OverstrengthFactor, varargin)

% Default problem parameters (can be modified with input arguments)

nPop = 100;
nRows = 10;
nCols = 10;
TurbSpacing = 1451;
DesignType = 'Real multi';
theta = 0;

% Problem parameters and variable argument definitions
for j = 1:2:length(varargin)
    switch(varargin{j})
        case 'nPop'
            if rem(varargin{j+1},1) == 0 && varargin{j+1} > 1
                nPop = varargin{j+1};
            else
                error('nPop must be a integer greater than 1')
            end
        case 'nRows'
            if rem(varargin{j+1},1) == 0 && varargin{j+1} > 0
                nRows = varargin{j+1};
            else
                error('nRows must be a positive integer')
            end
        case 'nCols'
            if rem(varargin{j+1},1) == 0 && varargin{j+1} > 0
                nCols = varargin{j+1};
            else
                error('nCols must be a positive integer')
            end
        case 'TurbSpacing'
            if isnumeric(varargin{j+1}) && varargin{j+1} > 1260
                TurbSpacing = varargin{j+1};
            elseif isnumeric(varargin{j+1}) && varargin{j+1} > 504 &&...
                    varargin{j+1} < 1260
                warning('TurbSpacing less than 1260 meters are subject to non-negligible wind wake effects, which are not taken into account in this simulation')
            elseif isnumeric(varargin{j+1}) && varargin{j+1} < 504
                error('TurbSpacing must be greater than 504 meters (four rotor diameters)')
            end
        case 'DesignType'
            if ischar(varargin{j+1})
                possibleStrings = {'Real multi', 'Real single',...
                    'Exact multi', 'Exact single'};
                k = 1;
                while k <= length(possibleStrings)
                    if strcmp(varargin{j+1}, possibleStrings{k})
                        DesignType = varargin{j+1};
                        break
                    else
                        k = k + 1;
                    end
                    if k > length(possibleStrings)
                        error('DesignType must be ''Real multi'', ''Real single'', ''Exact multi'', or ''Exact single''')
                    end
                end
            else
                error('DesignType must be a char')
            end
        case 'theta'
            if isnumeric(varargin{j+1})
                if varargin{j+1} >= 0 && varargin{j+1} <= 360
                    theta = varargin{j+1};
                else
                    error('theta must be between 0 and 360 degrees')
                end
            else
                error('theta must be an integer between 0 and 360')
            end

    end
end

% Other parameters (shouldn't need to be changed once code is finalized)
nSims = 5000;
Convergence_Its = 10;
Convergence_Threshold = 0.001;
nInitialTests = 25;
cross_ptg = .3;
clone_ptg = .2;
nChildren = round(cross_ptg*nPop);
nClones = round(clone_ptg*nPop);
if mod(nChildren,2) == 1 %if nChildren is odd, make it even
    nChildren = nChildren + 1;
    if nChildren + nClones > nPop %basically, if nPop = 2
        nClones = 0;
    end
end
nTurbs = nRows*nCols;
TADistance = TurbSpacing*sqrt(3)/3;
nAnchors = FindAnchors(nRows, nCols, TurbSpacing, TADistance, nTurbs);
It_Limit = 500; %maximum number of iterations before algorithm automatically stops
archivalSpace = 100000; %extra rows preallocated for archival variables

BestRel = 0;
fileID = 'OptimalConfigs.csv';

% Preallocate matrices                                           
Anchors_Array = zeros(nPop, nAnchors);
newgen = zeros(nChildren+nClones, nAnchors);
InitialTests = zeros(1, nInitialTests);
Reliability = zeros(1, nPop);
RelEnum = zeros(nPop, 2);
ItBestRel = zeros(length(It_Limit), 1);
ItBestArray = zeros(length(It_Limit), nStrengthenedAnchors);
RelRunAvg = zeros(length(It_Limit), 1);
RunAvgRng = zeros(length(It_Limit), 1);

% Determine file name format to match parameters
switch DesignType
    case 'Real multi'
        DesignType_abv = 'RM';
    case 'Real single'
        DesignType_abv = 'RS';
    case 'Exact multi'
        DesignType_abv = 'EM';
    case 'Exact single'
        DesignType_abv = 'ES';
end
parform = [num2str(nStrengthenedAnchors),'Anch_',...
    num2str(OverstrengthFactor),'OSF_',num2str(nPop),'Pop_',num2str(nRows),...
    'R_',num2str(nCols),'C_',num2str(TurbSpacing),'LL_',DesignType_abv,'_',...
    num2str(theta),'deg'];

% If archives are stored in the directory, load the archives. If not,
% generate matrices for a new archive
if exist(['storedRels_',parform,'.csv'], 'file') == 2
    storedRels = csvread(['storedRels_',parform,'.csv']);
    storedRels = [storedRels; zeros(archivalSpace, 1)];
    storedRels_ind = find(~storedRels); %identifies last nonzero for indexing
    storedRels_ind = storedRels_ind(1) - 1;
else
    storedRels = zeros(archivalSpace, 1); %pre-allocated 100,000 heuristically; trimmed at end of run
    storedRels_ind = 0;
end
if exist(['storedConfigs_',parform,'.csv'], 'file') == 2
    storedConfigs = csvread(['storedConfigs_',parform,'.csv']);
    storedConfigs = [storedConfigs; zeros(archivalSpace, nAnchors)];
    storedConfigs_ind = find(~any(storedConfigs,2)); %identifies last nonzero for indexing
    storedConfigs_ind = storedConfigs_ind(1) - 1;
else
    storedConfigs = zeros(archivalSpace, nAnchors);
    storedConfigs_ind = 0;
end
if exist(['storedTestIts_',parform,'.csv'], 'file') == 2
    storedTestIts = csvread(['storedTestIts_',parform,'.csv']);
    storedTestIts = [storedTestIts; zeros(archivalSpace, 1)];
    storedTestIts_ind = find(~storedTestIts); %identifies last nonzero for indexing
    storedTestIts_ind = storedTestIts_ind(1) - 1;
else
    storedTestIts = zeros(archivalSpace, 1);
    storedTestIts_ind = 0;
end

n = 0; %iteration counter
m1 = 0; %offset iteration counter 1 (off by 10)
m2 = 0; %offset iteration counter 2 (off by 20)
newInd = 0; %counter of new array configurations added
converged = 0;

% Main Loop
while converged == 0
    n = n + 1;
    disp(n)
%     resultsfile = fopen(fileID, 'a');
%     fprintf(resultsfile, 'Iteration %d\r\n\n', n);
%     fclose(resultsfile);
    % Fill population with previous clones and children (none if first iteration)
    Anchors_Array(1:nChildren+nClones,:) = newgen;
    
    % Changes number of new organisms generated depending on if it's the
    % first generation (i.e. no children) or not
    if n == 1
        genstart = 1;
    else
        genstart = nChildren+nClones+1;
        % Fill population with previous children (none if first iteration)
        Anchors_Array(1:nChildren+nClones,:) = newgen;
    end
    
    % Fill remaining population with random guesses
    for i = genstart:nPop
        Anchors_Array(i, :) = 0;
        Anchors_Array(i, randperm(nAnchors, nStrengthenedAnchors)) = 1;
    end
    
    % Takes the created configurations and calculates the reliability for
    % each using the supplied code
    for i = 1:nPop
        % Creates matrix of only strengthened turbines (to fit with
        % parameters of source code)
        Strengthened_Turbines = find(Anchors_Array(i,:));
        
        % If configuration is identical to a previously stored array, the
        % previous reliability value is recalled, and one more reliability
        % value is calculated to modify the stored average reliability
        [~,archiveIndex] = ismember(Anchors_Array(i,:), storedConfigs, 'rows');
        
        if archiveIndex == 0
            % If current configuration is unique, run nInitialTests
            % reliability tests to determine the set reliability of
            % current array
            newInd = newInd + 1;
            for j = 1:nInitialTests
                InitialTests(j) = Reliability_Compute_original(Strengthened_Turbines,...
                OverstrengthFactor,nRows, nCols, TurbSpacing, DesignType,...
                nSims, theta);
            end
            % Average initial tests to determine the set reliabiliy of current array
            Reliability(i) = mean(InitialTests);
            % Enumeration so original array config can be referenced
            RelEnum(i, :) = [i, Reliability(i)]; 
            % Archive new reliability value, configuration, and
            % number of reliabilities averaged
            storedRels(storedRels_ind + newInd) =  Reliability(i);
            storedConfigs(storedConfigs_ind + newInd, :) = Anchors_Array(i,:);
            storedTestIts(storedTestIts_ind + newInd) = nInitialTests;
            
        else
            % Current configuration has been previously saved. A
            % single extra test is added to adjust the set
            % reliability
            AddedRel = Reliability_Compute_original(Strengthened_Turbines,...
                OverstrengthFactor,nRows, nCols, TurbSpacing, DesignType,...
                nSims, theta);
            Reliability(i) = (storedRels(archiveIndex)*storedTestIts(archiveIndex) + AddedRel)/(storedTestIts(archiveIndex)+1);
            RelEnum(i, :) = [i, Reliability(i)];
            % Modify stored reliability and number of reliabilities
            % averaged for configuration
            storedRels(archiveIndex) = Reliability(i);
            storedTestIts(archiveIndex) = storedTestIts(archiveIndex) + 1;
        end 
    end
    
    % Sorts reliability from best to worst
    RelEnum = flipud(sortrows(RelEnum, 2));
    
    % If first iteration, saves best reliability and configuration of generation
    if n == 1
        BestRel = RelEnum(1,2);
        BestArray = Anchors_Array(RelEnum(1,1),:);
    % If not first iteration:
    else
        % If a better configuration is found different than current best
        % configuration, overwrites best reliability and configuration
        if RelEnum(1,2) > BestRel && ~isequal(Anchors_Array(RelEnum(1,1),:), BestArray)
            BestRel = RelEnum(1,2);
            BestArray = Anchors_Array(RelEnum(1,1),:);
        % If best configuration is the same, overwrites best reliability
        % value (even if it is lower -- this prevents an inaccurately high
        % reliability value for a specific configuration being saved for
        % all time)
        elseif isequal(Anchors_Array(RelEnum(1,1),:), BestArray)
            BestRel = RelEnum(1,2);
        end
    end
    
    % Track iteration-best reliabilities and arrays
    ItBestRel(n) = RelEnum(1,2);
    ItBestArray(n,:) = find(Anchors_Array(RelEnum(1,1),:));
    
%     resultsfile = fopen(fileID, 'a');
%     fprintf(resultsfile,...
%         'Overall Best Reliability:\r\n%f\r\nBest Array:\r\n%s %s %s %s %s %s %s %s %s %s\r\n\n',...
%         BestRel, string(find(BestArray)));
%     fprintf(resultsfile,...
%         'Iteration Best Reliability:\r\n%f\r\nBest Array:\r\n%s %s %s %s %s %s %s %s %s %s\r\n\n',...
%         ItBestRel(n), string(ItBestArray(n,:)));
%     fclose(resultsfile);
    
    % Once the algorithm hits Convergence_Its, takes a running
    % average of the previous Convergence_Its iteration-best reliabilities
    if n >= Convergence_Its
        m1 = m1 + 1;
        RelRunAvg(m1) = mean(ItBestRel(n-Convergence_Its+1:n));
    end
    
    % Once the algorithm hits Convergence_Its*2 iterations, tracks
    % the range of the last Convergence_Its running averages
    if n >= Convergence_Its*2
        m2 = m2 + 1;
        RunAvgRng(m2) = range(RelRunAvg(m1-Convergence_Its+1:m1));
    end

    % Convergence check: if the iteration-best array has not changed for
    % Convergence_Its iterations, and the range of the past 10 running averages
    % Convergence_Its running averages have all been Convergence_Threshold
    % or less, the problem has converged and the optimization is complete.
    if n >= Convergence_Its*3 &&...
            all(RunAvgRng(m2-Convergence_Its+1:m2) < Convergence_Threshold)
        if n == It_Limit
            converged = 1;
            break;
        end
        for k = 1:Convergence_Its
            if any(ItBestArray(n-k,:) ~= ItBestArray(n,:))
                converged = 1;
                break;
            end
        end
    end
            
    % Cloning: Members of population with the highest fitness are copied
    % exactly to the next generation. Note that the individuals who are
    % cloned are also potential parents
    for k = 1:nClones
        newgen(k, :) = Anchors_Array(RelEnum(k,1),:);
    end
        
    
    % Fitness function; fitness of each anchor array is equal to the
    % percentage of the reliability difference of each array > average and
    % the sum of all arrays > average (arrays <= average aren't taken into
    % account and are therefore not possible parents)
    AvgRel = mean(Reliability);
    GoodRels = RelEnum(:,2);
    GoodRels = GoodRels(GoodRels>AvgRel);
    RelDiffs = GoodRels - AvgRel;
    fitness = zeros(1, length(GoodRels));
    fitness(1) = RelDiffs(1)/sum(RelDiffs);
    for i = 2:length(GoodRels)
        fitness(i) = fitness(i-1) + (RelDiffs(i)/sum(RelDiffs));
    end
    % Select parents
    for k = nClones+1:2:nClones+nChildren
        p1 = fitness(end)*rand;
        p2 = fitness(end)*rand;
        for i = 1:length(fitness)
            if p1 <= fitness(i)
                parent1 = Anchors_Array(RelEnum(i,1), :);
                break
            end
        end
        for i = 1:length(fitness)
            if p2 <= fitness(i)
                parent2 = Anchors_Array(RelEnum(i,1), :);
                break
            end
        end
        % Create children array (random combination of strengthened anchors from two parents)
        offspring_pool = [find(parent1) find(parent2)];
        offspring_pool = unique(offspring_pool);
        offspring1 = offspring_pool(randperm(length(offspring_pool),nStrengthenedAnchors));
        offspring2 = offspring_pool(randperm(length(offspring_pool),nStrengthenedAnchors));
        % Anchor configuration of children is stored in a new array
        newgen(k, :) = 0;
        newgen(k+1, :) = 0;
        newgen(k,offspring1) = 1;
        newgen(k+1,offspring2) = 1;
    end
  
end
% Writes best reliability and corresponding strengthened anchors
Op_Turbines = find(BestArray);

% Remove any excess rows of zeros at the end of archival variables
storedRels(newInd+1:end) = [];
storedConfigs(newInd+1:end, :) = [];
storedTestIts(newInd+1:end) = [];

% Close parallel pools (to prevent memory issues if running code in larger
% loop)
curpool = gcp('nocreate');
delete(curpool);

% Writes current archives (storedRels, storedConfigs, storedTestIts) to
% csv file to be called upon the next time the script is run
csvwrite(['storedRels_',parform,'.csv'], storedRels);
csvwrite(['storedConfigs_',parform,'.csv'], storedConfigs);
csvwrite(['storedTestIts_',parform,'.csv'], storedTestIts);

end