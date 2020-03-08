nStrenghtenedTurbs = 1:120;
OverstrengthFactor = 1.1:.1:2;
CSVFile = 'nStrenghtenedTurbsCompare.csv';
Rels = zeros(1,length(nStrenghtenedTurbs));

% Run original code (with shared anchors creating a lattice) across all
% potential turbine values. The resulting reliability values are expected
% to be lower for this than the random option.
for j = 1:length(nStrenghtenedTurbs)
    for k = 1:length(OverstrengthFactor)
        currentnStrengthenedTurbs = nStrenghtenedTurbs(j);
        currentOSF = OverstrengthFactor(k);
        [OptRel,OptTurbs] =...
            Anchor_Optimization(currentnStrengthenedTurbs,currentOSF);
        CSVFile = ['OptCompare_',currentnStrengthenedTurbs,'nST_',currentOSF,'OSF.csv'];
        CSVData = [currentnStrengthenedTurbs currentOSF OptRel OptTurbs];
        writematrix(CSVData, CSVFile);
    end
end