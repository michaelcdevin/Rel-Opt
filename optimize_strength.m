%% COST OPTIMIZATION FOR MULTILINE FOWT ARRAY
%  ==========================================
%  Written by Michael C. Devin, Oregon State University, 2020 Aug 28

clear
clc

%% Optimization parameters
pop_size = 100; % population size
num_osf_increments = 20; % 1.05:.05:2 by default
cross_ptg = .6; % crossover percentage
clone_ptg = .2; % cloning percentage
kill_ptg = .2; % kill percentage
mut_ptg = .05; % mutation percentage (number of individuals mutated)
mut_rate = .1; % mutation rate (mutated genes per mutated individual)
archive_length = 100000; % extra rows preallocated for archival variables

osf_increments = linspace(1.05, 2, num_osf_increments)';
num_children = round(cross_ptg * pop_size);
num_clones = round(clone_ptg * pop_size);
num_killed = round(kill_ptg * pop_size);
num_mutated = round(mut_ptg * pop_size);

%% Evaluation parameters
rows = 10;
cols = 10;
turb_spacing = 1451;
design_type = 'Real multi';
num_sims = 3000;
theta = 0;

num_turbs = rows * cols;
turb_anch_distance = turb_spacing * sqrt(3)/3;
num_anchs = FindAnchors(rows, cols, turb_spacing, turb_anch_distance, num_turbs);

%% Preallocate matrices
current_gen = zeros(num_anchs, num_osf_increments, pop_size);
next_gen = zeros(num_anchs, num_osf_increments, num_children + num_clones);
gen_archive_idxs = zeros(pop_size, 1);
stored_configs = zeros(num_anchs, num_osf_increments, archive_length);
stored_costs = zeros(archive_length, 1);
stored_num_sims = zeros(archive_length, 1);
gen_costs = zeros(pop_size, 1);
gen_costs_enum = zeros(pop_size, 2);
gen_min_cost_tracker = zeros(archive_length,1);
gen_best_config_tracker = cell(archive_length,1);
min_cost_tracker = zeros(archive_length,1);
best_config_tracker = cell(archive_length,1);

%% Load seeded configurations
seeding_file = 'seeded_configs_10x10.mat';
seeded_configs = importdata(seeding_file);
num_seeded_configs = size(seeded_configs,3);
% truncate the number of seeded configs if it's larger than pop_size
if num_seeded_configs > pop_size
    seeded_configs = seeded_configs(:,:,1:pop_size);
    num_seeded_configs = pop_size;
end

%% Start GA loop
converged = 0;
new_archive_idx = 0; % index of archive variables to add new config information
gen = 0; % generation counter
convergence_std = 5000; % if a generation's st. dev. is <, problem is converged

while ~converged
    gen = gen + 1; %increment generation counter
    
    %% Create population
    % Rows are different anchors, columns are different OSFs, pages are
    % different organisms.

    % For first generation, seed initial configurations, and fill the rest
    % of the population with random configurations
    if gen == 1
        current_gen(:,:,1:num_seeded_configs) = seeded_configs;
        for j = num_seeded_configs+1:pop_size
            current_gen(:,:,j) = create_config(num_anchs, num_osf_increments);
        end
        
    % After the first generation, fill population with clones and children
    % from last generation
    else
        current_gen(:,:,1:num_children+num_clones) = next_gen;
        % Fill remaining population with random configurations
        for j = num_children + num_clones + 1:pop_size
            current_gen(:,:,j) = create_config(num_anchs, num_osf_increments);
        end
    end
    
    % Find members of population stored in archive, and get the archive
    % indices for the population.
    for j = 1:pop_size
        gen_archive_idxs(j) = get_archive_idx(current_gen(:,:,j), stored_configs);
    end
    
    %% Evaluate population

    parfor j = 1:pop_size
        gen_costs(j) =...
            evaluate_config(current_gen(:,:,j), rows, cols, turb_spacing,...
            design_type, num_sims, theta, osf_increments,...
            gen_archive_idxs(j), stored_costs, stored_num_sims);
        
        % gen_costs is enumerated so costs can be ranked without losing the
        % link to the respective configurations
        gen_costs_enum(j, :) = [j, gen_costs(j)];
        
    end
    
    % Sort costs from best to worst
    gen_costs_enum_sorted = sortrows(gen_costs_enum, 2);
    
    % Saves the lowest cost and respective configuration for the generation
    gen_min_cost = gen_costs_enum_sorted(1,2);
    [gen_best_strengthened_anchs, gen_best_osf_selections] =...
        find(current_gen(:,:,gen_costs_enum_sorted(1,1)));
    gen_best_config =...
        [gen_best_strengthened_anchs osf_increments(gen_best_osf_selections)];
    
    % Update overall lowest cost and respective configuration if applicable
    if gen == 1 % first generation has nothing to compare to
        min_cost = gen_min_cost;
        best_config = gen_best_config;
    else % after the first generation
        % Since an identical config can result in different costs, this
        % prevents an inaccurately low cost for a specific configuration
        % being saved for all time.
        if isequal(gen_best_config, best_config)
            min_cost = gen_min_cost;
        % If gen_best_config isn't best_config, proceed as normal.
        elseif gen_min_cost > min_cost
            min_cost = gen_min_cost;
            best_config = gen_best_config;
            convergence_counter = 0;
        end
    end
    
    % Save current best values to tracking datasets
    min_cost_tracker(gen) = min_cost;
    gen_min_cost_tracker(gen) = gen_min_cost;
    best_config_tracker{gen} = best_config;
    gen_best_config_tracker{gen} = gen_best_config;
    
    % This is where the kill is actually performed since it is used to
    % determine if convergence has been reached, and doing that here saves
    % time on the final iteration.
    gen_surviving_costs_enum =...
        gen_costs_enum_sorted(1:end-num_killed, :);
    surviving_gen_std = std(gen_surviving_costs_enum(:,2));
    
    % Determine if problem is considered optimized.
    if surviving_gen_std <= convergence_std
        converged = 1;
    end
    
    % Update archives
    [stored_configs, stored_costs, stored_num_sims] =...
        update_archives(current_gen, gen_costs, num_sims, gen_archive_idxs,...
        new_archive_idx, stored_configs, stored_costs, stored_num_sims);
    
    %% Generate new population

    % Cloning: copy best chromosomes to next generation. Note that cloned
    % chromosomes are also potential parents.
    next_gen(:,:,1:num_clones) =...
        current_gen(:,:,gen_costs_enum_sorted(1:num_clones,1));

    % Kill: worst-performing individuals are removed from selection to
    % get rid of extreme negative outliers (due to fitness function method)
    % This comment is left for readability -- the actual kill calculation
    % is done before the convergence check.
    
    % Fitness function: fitness of each configuration is equal to the
    % number of st. devs. above the worst surviving cost it is out of the
    % sum of total st. devs. above the worst surviving cost.
    worst_surviving_cost = gen_surviving_costs_enum(end,2);
    gen_fitness = (abs(gen_surviving_costs_enum(:,2) - worst_surviving_cost)) / surviving_gen_std;
    gen_fitness = cumsum(gen_fitness / sum(gen_fitness));
    gen_fitness_enum = [gen_surviving_costs_enum(1:end-1,1) gen_fitness(1:end-1)];

    % Selection: there is no practical difference between mothers and
    % fathers, they are just more intuitive to use as variables than
    % "groupofparent1s" and "groupofparent2s".
    [mothers, fathers] = get_parents(num_children, current_gen, gen_fitness_enum);

    % Crossover: Each mother/father pairing produces 1 child, but there is
    % nothing preventing the same config from being used for multiple
    % mother/father pairings since monogamy is not a moral value in this
    % algorithm.
    for j = 1:num_children
        next_gen(:,:,num_clones+j) =...
            create_child(mothers(:,:,j), fathers(:,:,j), num_anchs, rows);
    end
    
    % Mutation: OSFs are shifted for a select number of children
    mut_pop_idxs = randperm(num_children, num_mutated);
    mut_pop = next_gen(:,:,num_clones+mut_pop_idxs);
    for j = 1:num_mutated
        next_gen(:,:,num_clones+mut_pop_idxs(j)) =...
            mutate_config(mut_pop(:,:,j), mut_rate);
    end
    
    % Print current lowest cost and best config to command window
    disp('Current best configuration:')
    disp(best_config)
    disp(['Cost: ', num2str(min_cost)])
    disp(['Generation std: ', num2str(surviving_gen_std)])

end

%% After the algorithm converges, export data
t = datetime('now', 'Format', 'yyyy-MM-dd''_''HHmmss'); % current clock time

% Print final outputs to a CSV file
writematrix(min_cost, ['min_cost_',char(t),'.txt'])
writematrix(best_config, ['best_config_',char(t),'.csv'])

% Remove empty rows at the end of tracking variables and save them as .mat
gen_min_cost_tracker(gen+1:end) = [];
min_cost_tracker(gen+1:end) = [];
gen_best_config_tracker(gen+1:end) = [];
best_config_tracker(gen+1:end) = [];
save(['optimize_strength_tracking_',char(t),'.mat'], 'min_cost_tracker',...
    'gen_min_cost_tracker', 'best_config_tracker', 'gen_best_config_tracker')
    