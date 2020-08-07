NSims = [1 10 50 100 500 1000 5000 10000 50000 100000 500000 1000000];
Tests = 100;
Rels = zeros(length(NSims), Tests);
Means = zeros(length(NSims), 1);
Stdevs = zeros(length(NSims), 1);

for j = 1:length(NSims)
    for k = 1:Tests
        Rels(j,k) = Visualization_original([13 23 35 48 56 67 71 89 91 93], 1.3, 10, 10, 1451, 'Real multi', NSims(j), 0);
        if Rels(j,k) == Inf
            while Rels(j,k) == Inf
                Rels(j,k) = Visualization_original([13 23 35 48 56 67 71 89 91 93], 1.3, 10, 10, 1451, 'Real multi', NSims(j), 0);
            end
        end
    end
    Means(j) = mean(Rels(j, :));
    Stdevs(j) = std(Rels(j, :));
    disp(['NSims = ', num2str(NSims(j)), ' complete.'])
    disp(['Mean = ', num2str(Means(j))])
    disp(['Standard deviation = ', num2str(Stdevs(j))])
end

writematrix(Rels, 'testrels.xlsx')
writematrix([Means Stdevs], 'relstats.xlsx')
        