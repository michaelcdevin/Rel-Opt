nTurbs = 3:125;
nIts = 500;
CSVFile = 'TurbRelCompare.csv';
Rels = zeros(nIts,length(nTurbs));

% Run original code (with shared anchors creating a lattice) across all
% potential turbine values. The resulting reliability values are expected
% to be lower for this than the random option.
for j = 1:length(nTurbs)
    currentnTurbs = nTurbs(j);
    parfor k = 1:nIts
        Rels(k,j) = Visualization_autofit([], 1, currentnTurbs, 1451,...
            'Real multi', 5000, 0);
    end
end    

% Output the gathered reliability values in a CSV file
relData = [nan nTurbs; [1:nIts]' Rels];
writematrix(relData, CSVFile)