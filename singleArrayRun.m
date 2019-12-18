IterationLimit = 250;
StrengthenedAnchors = [1 10 20 30 40 50 60 70 80 90 100 110 120];
OverstrengthFactor = 1.5;
tempReliabilityList = zeros(IterationLimit,1);
FinalRels = zeros(length(OverstrengthFactor), 1);

for j = 1:length(OverstrengthFactor)
    currentOSF = OverstrengthFactor(j);
    for k = 1:IterationLimit 
        tempReliabilityList(k) = Visualization(StrengthenedAnchors, currentOSF);
    end
    FinalRels(j) = mean(tempReliabilityList);
end

CSVdata = [OverstrengthFactor, FinalRels];
csvwrite('OriginalCosinesControlTest.csv', CSVdata);