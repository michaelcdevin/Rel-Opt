NSims = [1 10 50 100 500 1000 5000 10000 50000 100000 500000 1000000];
Tests = 100;
Costs = zeros(length(NSims), Tests);
Means = zeros(length(NSims), 1);
Stdevs = zeros(length(NSims), 1);

for j = 1:length(NSims)
    num_sims = NSims(j);
    parfor k = 1:Tests
        Costs(j,k) = Failure_Cost_Compute([13 23 35 48 56 67 71 89 91 93],...
            1.3, 10, 10, 1451, 'Real multi', num_sims, 0);
    end

    Means(j) = mean(Costs(j, :));
    Stdevs(j) = std(Costs(j, :));
    disp(['NSims = ', num2str(NSims(j)), ' complete.'])
    disp(['Mean = ', num2str(Means(j))])
    disp(['Standard deviation = ', num2str(Stdevs(j))])
end

writematrix(Costs, 'testcosts.xlsx')
writematrix([Means Stdevs], 'coststats.xlsx')
        