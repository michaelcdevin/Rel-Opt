nTurbs = [4 9 16 25 36 49 64 81 100];
nIts = 5000;
originalFile = 'RelOriginal.csv';
randomFile = 'RelRandom.csv';
originalRels = zeros(nIts,length(nTurbs));
randomRels = zeros(nIts,length(nTurbs));

% Run original code (with shared anchors creating a lattice) across all
% potential turbine values. The resulting reliability values are expected
% to be lower for this than the random option.
for j = 1:length(nTurbs)
    parfor k = 1:nIts
        originalRels(k,j) = Visualization_original([], 1, sqrt(nTurbs(j)),...
            sqrt(nTurbs(j)), 1451, 'Real multi', 5000, 0);
    end
end    

% Run new code (with random turbine layout w/ constraints, only sharing
% anchors if turbines are sufficiently close). The resulting reliabity
% values are expected to be consistently higher than the original code,
% with the reliability being lower the more anchors are shared.
for j = 1:length(nTurbs)
    parfor k = 1:nIts
        randomRels(k,j) = Visualization([], 1, nTurbs(j), 1451,...
            'Real multi', 5000, 0);
    end
end

% Output the gathered reliability values in a CSV file
originalData = [nan nTurbs; [1:nIts]' originalRels];

randomData = [nan nTurbs; [1:nIts]' randomRels];

writematrix(originalData, originalFile)
writematrix(randomData, randomFile)