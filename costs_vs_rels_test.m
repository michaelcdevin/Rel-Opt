% Define range of OSFs to test
num_tests = 100;
osfs = single(1:.05:1.5);

% Preallocate arrays
rels = zeros(length(osfs), num_tests);
costs = zeros(length(osfs), num_tests);

% Load data
downtime_lengths = readmatrix('downtime_lengths_12hr.csv');
prob_of_12hr_window = readmatrix('prob_of_12hr_window.txt');
R = load('ReliabilityResultsLN_Final,0deg.mat');
Res = R.Res;
load('Surge_0deg.mat')

parfor j = 1:length(osfs)
    for k = 1:num_tests
        [costs(j,k), rels(j,k)] = Failure_Cost_Compute_returnfails(1:120, osfs(j), 10, 10, 1451, 'Real multi', 3000, 0, Displacements, Res, downtime_lengths, prob_of_12hr_window);
    end
end
