% Anchor optimization for reliability calculations of multiline FOWT array
% For use in research of Spencer Hallowell and/or Bryony DuPont
% Michael Devin, Oregon State University, 4/2/2018

function [BestRel,Op_Turbines] = Anchor_Optimization_RBDO_Iterative(nStrengthenedAnchors,OverstrengthFactor)

% Problem parameters
Iteration_Limit = 100;
nPop = 100;
nAnchors = 120;
nInitialTests = 25;
cross_ptg = .3;
nChildren = round(cross_ptg*nPop);
clone_ptg = .2;
nClones = round(clone_ptg*nPop);

BestRel = 0;

% Preallocate matrices                                           
Anchors_Array = zeros(nPop, nAnchors);
newgen = zeros(nChildren+nClones, nAnchors);
InitialTests = zeros(1, nInitialTests);
Reliability = zeros(1, nPop);
RelEnum = zeros(nPop, 2);

% If archives are stored in the directory, load the archives. If not,
% generate matrices for a new archive
if isfile('storedRels.csv')
    storedRels = csvread('storedRels.csv');
else
    storedRels = [];
end
if isfile('storedConfigs.csv')
    storedConfigs = csvread('storedConfigs.csv');
else
    storedConfigs = zeros(1, nAnchors); %the only reason this isn't an empty matrix is so the ismember function works the first time
end
if isfile('storedTestIts.csv')
    storedTestIts = csvread('storedTestIts.csv');
else
    storedTestIts = [];
end

% Main Loop
for n = 1:Iteration_Limit
    
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
            % If current configuration is unique, run 10 initial
            % reliability tests to determine the set reliability of
            % current array
            parfor j = 1:nInitialTests
                InitialTests(j) = Reliability_Compute(Strengthened_Turbines, OverstrengthFactor);
            end
            % Average initial tests to determine the set reliabiliy of current array
            Reliability(i) = mean(InitialTests);
            % Enumeration so original array config can be referenced
            RelEnum(i, :) = [i, Reliability(i)]; 
            % Archive new reliability value, configuration, and
            % number of reliabilities averaged
            storedRels =  [storedRels; Reliability(i)];
            if isequal(storedConfigs, zeros(1, nAnchors))
                storedConfigs(1,:) = Anchors_Array(i,:);
            else
                storedConfigs = [storedConfigs; Anchors_Array(i,:)];
            end
            storedTestIts = [storedTestIts; nInitialTests];
            
        else
            % Current configuration has been previously saved. A
            % single extra test is added to adjust the set
            % reliability
            AddedRel = Reliability_Compute(Strengthened_Turbines, OverstrengthFactor);
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
        elseif Anchors_Array(RelEnum(1,1),:) == BestArray
            BestRel = RelEnum(1,2);
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

% Writes current archives (storedRels, storedConfigs, storedTestIts) to
% csv file to be called upon the next time the script is run
csvwrite('storedRels.csv', storedRels);
csvwrite('storedConfigs.csv', storedConfigs);
csvwrite('storedTestIts.csv', storedTestIts);

end