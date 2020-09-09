%% COST OPTIMIZATION FOR MULTILINE FOWT ARRAY
%  ==========================================
%  Written by Michael C. Devin, Oregon State University, 2020 Aug 28

clear
clc

%% Optimization parameters
pop_size = 100; % population size
num_osf_increments = 20; % 1.05:.05:2 by default
cross_ptg = .7; % crossover percentage
clone_ptg = .1; % cloning percentage
kill_ptg = .2; % kill percentage
mut_ptg = .1; % mutation percentage (number of individuals mutated)
mut_rate = .1; % mutation rate (mutated genes per mutated individual)
archive_length = 100000; % extra rows preallocated for archival variables
max_gen = 10000; % extra rows preallocated for tracker variables
tracker_reset = 50; % number of generations before storing and reseting tracker variables

osf_increments = linspace(1.05, 2, num_osf_increments)';
num_children = round(cross_ptg * pop_size);
num_clones = round(clone_ptg * pop_size);
num_killed = round(kill_ptg * pop_size);
num_mutated = round(mut_ptg * pop_size);
num_for_convergence = num_clones + round(num_children/2); % individuals used to determine convergence

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
% The data type specifications are due to memory space issues if default.
current_gen = zeros(num_anchs, num_osf_increments, pop_size, 'uint8');
next_gen = zeros(num_anchs, num_osf_increments, num_children + num_clones, 'uint8');
gen_archive_idxs = zeros(pop_size, 1, 'uint32');
stored_configs = zeros(num_anchs, num_osf_increments, archive_length, 'uint8');
stored_costs = zeros(archive_length, 1, 'single');
stored_num_sims = zeros(archive_length, 1, 'uint32');
gen_costs = zeros(pop_size, 1, 'single');
gen_costs_enum = zeros(pop_size, 2, 'single');
tracker = struct('best_config', zeros(num_anchs, 2, tracker_reset, 'single'),...
       'gen_best_config', zeros(num_anchs, 2, tracker_reset, 'single'),...
       'min_cost', zeros(tracker_reset, 1, 'single'),...
       'gen_min_cost', zeros(tracker_reset, 1, 'single'));
tracker_filenames = strings(round(max_gen/tracker_reset), 1);

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
num_convergence_gens = 100; % # of generations the optima must remain unchanged before considered converged
gens_as_best = 0; % # of generation the optima has remained unchanged
num_tracker_files = 0;

while ~converged
    gen = gen + 1; %increment generation counter
    if gen == max_gen % hard stop loop in case it can't converge
        converged = 1;
    end
    
    %% Create population
    % Rows are different anchors, columns are different OSFs, pages are
    % different organisms.

    % For first generation, seed initial configurations, and fill the rest
    % of the population with random configurations
    if gen == 1
        current_gen(:,:,1:num_seeded_configs) = seeded_configs;
        clear seeded_configs
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
    gen_best_config =...
        get_config_stats(current_gen(:,:,gen_costs_enum_sorted(1,1)), osf_increments);
    
    % Update overall lowest cost and respective configuration if applicable
    if gen == 1 % first generation has nothing to compare to
        min_cost = gen_min_cost;
        best_config = gen_best_config;
        gens_as_best = gens_as_best + 1; % gens_as_best = 1
    else % after the first generation
        % Since an identical config can result in different costs, this
        % prevents an inaccurately low cost for a specific configuration
        % being saved for all time.
        if isequal(gen_best_config, best_config)
            min_cost = gen_min_cost;
            gens_as_best = gens_as_best + 1;
        % If gen_best_config isn't best_config, proceed as normal.
        elseif gen_min_cost < min_cost
            min_cost = gen_min_cost;
            best_config = gen_best_config;
            gens_as_best = 1; % since config changes, resets convergence counter
        end
    end
    
    % Save current best values to tracker struct
    tracker.min_cost(gen-(num_tracker_files*tracker_reset)) = min_cost;
    tracker.gen_min_cost(gen-(num_tracker_files*tracker_reset)) = gen_min_cost;
    tracker.best_config(:, :, gen-(num_tracker_files*tracker_reset)) =...
        [best_config; zeros(num_anchs-length(best_config), 2)];
    tracker.gen_best_config(:, :, gen-(num_tracker_files*tracker_reset)) =...
        [gen_best_config; zeros(num_anchs-length(gen_best_config), 2)];
    
    % Determine if problem is considered optimized.
    if gens_as_best >= num_convergence_gens
        converged = 1;
    end
    
    % Update archives. This section is a direct copy-and-paste from the
    % update_archives function. It is included here to prevent array
    % duplication, as stored_configs in particular is a very large array
    % and runs into memory issues if duplicated.
    for j = 1:length(gen_costs)
        % config not in archive
        if gen_archive_idxs(j) == 0
            % check how many times new config appears in current_gen
            % (otherwise, this could lead to the same config being archived
            % twice using two indices)
            gen_config_occurrences = find(all(current_gen(:,:,j)==current_gen, [1 2]));
            
            if j == min(gen_config_occurrences)
                
                if length(gen_config_occurrences) == 1
                % if this is the only occurrence of this config in current_gen,
                % add a new archive entry (this happens the vast majority of
                % the time)
                    new_archive_idx = new_archive_idx + 1;
                    stored_configs(:,:,new_archive_idx) = current_gen(:,:,j);
                    stored_costs(new_archive_idx) = gen_costs(j);
                    stored_num_sims(new_archive_idx) = num_sims;
                
                elseif length(gen_config_occurrences) > 1 
                % if there are other identical configs in current_gen,
                % create one new archive entry that covers all of them.
                    new_archive_idx = new_archive_idx + 1;
                    stored_configs(:,:,new_archive_idx) = current_gen(:,:,j);
                    stored_costs(new_archive_idx) = mean(gen_costs(gen_config_occurrences));
                    stored_num_sims(new_archive_idx) = num_sims * length(gen_config_occurrences);
                end
            end
        
        % if config is in archive, update archive values
        elseif gen_archive_idxs(j) > 0
            stored_costs(gen_archive_idxs(j)) = gen_costs(j);
            stored_num_sims(gen_archive_idxs(j)) =...
                stored_num_sims(gen_archive_idxs(j)) + num_sims/2;
        end
    end
    
    %% Generate new population

    % Cloning: copy best chromosomes to next generation. Note that cloned
    % chromosomes are also potential parents.
    next_gen(:,:,1:num_clones) =...
        current_gen(:,:,gen_costs_enum_sorted(1:num_clones,1));

    % Kill: worst-performing individuals are removed from selection to
    % get rid of extreme negative outliers (due to fitness function method)
    gen_surviving_costs_enum =...
        gen_costs_enum_sorted(1:end-num_killed, :);
    surviving_gen_std = std(gen_surviving_costs_enum(:,2));
    
    % Fitness function: fitness of each configuration is equal to the
    % number of st. devs. above the worst surviving cost it is out of the
    % sum of total st. devs. above the worst surviving cost.
    worst_surviving_cost = gen_surviving_costs_enum(end,2);
    gen_fitness = (abs(gen_surviving_costs_enum(:,2) - worst_surviving_cost)) / surviving_gen_std;
    gen_fitness = cumsum(gen_fitness / sum(gen_fitness));
    gen_fitness_enum = [gen_surviving_costs_enum(1:end-1,1) gen_fitness(1:end-1)];
    disp(gen_fitness_enum)
    
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
    clear mothers fathers
    
    % Mutation: OSFs are shifted for a select number of children
    mut_pop_idxs = randperm(num_children, num_mutated);
    mut_pop = next_gen(:,:,num_clones+mut_pop_idxs);
    for j = 1:num_mutated
        next_gen(:,:,num_clones+mut_pop_idxs(j)) =...
            mutate_config(mut_pop(:,:,j), mut_rate);
    end
    clear mut_pop
    
    % Print current lowest cost and best config to command window
    disp('Current best configuration:')
    disp(best_config)
    disp(['Cost: ', num2str(min_cost)])
    disp(['Generation std: ', num2str(surviving_gen_std)])
    
    % To save memory, store tracking variables to hard disk every tracker_reset
    % generations. These will all be appended after convergence.
    if mod(gen,tracker_reset) == 0
        num_tracker_files = num_tracker_files + 1;
        tracker_filenames(num_tracker_files) =...
            ['optimize_strength_tracking_gen_',num2str(gen),'.mat'];
        save(tracker_filenames(num_tracker_files), 'tracker')
        tracker = struct('best_config', zeros(num_anchs, 2, tracker_reset, 'single'),...
           'gen_best_config', zeros(num_anchs, 2, tracker_reset, 'single'),...
           'min_cost', zeros(tracker_reset, 1, 'single'),...
           'gen_min_cost', zeros(tracker_reset, 1, 'single')); %reset tracker
    end
            

end

%% After the algorithm converges, export data
t = datetime('now', 'Format', 'yyyy-MM-dd''_''HHmmss'); % current clock time

% Print final outputs to a CSV file
writematrix(min_cost, ['min_cost_',char(t),'.txt'])
writematrix(best_config, ['best_config_',char(t),'.csv'])

% Remove empty rows at the end of tracking variable and combine all saved
% tracking data.
if gen_min_cost(end) ~= 0
    tracker.gen_min_cost(gen-(num_tracker_files*tracker_reset)+1:end) = [];
    tracker.min_cost(gen-(num_tracker_files*tracker_reset)+1:end) = [];
    tracker.gen_best_config(:,:,gen-(num_tracker_files*tracker_reset)+1:end) = [];
    tracker.best_config(:,:,gen-(num_tracker_files*tracker_reset)+1:end) = [];
end

final_tracker_filename = ['optimize_strength_tracking_',char(t),'.mat'];
final_tracker = struct('best_config', zeros(120, 2, gen, 'single'),...
       'gen_best_config', zeros(120, 2, gen, 'single'),...
       'min_cost', zeros(gen, 1, 'single'),...
       'gen_min_cost', zeros(gen, 1, 'single'));
idx = 1;
for j = 1:num_tracker_files
    saved_tracker = importdata(tracker_filenames(j));
    final_tracker.best_config(:,:,idx:idx+size(saved_tracker.best_config,3)-1) = saved_tracker.best_config;
    final_tracker.gen_best_config(:,:,idx:idx+size(saved_tracker.gen_best_config,3)-1) = saved_tracker.gen_best_config;
    final_tracker.min_cost(idx:idx+length(saved_tracker.min_cost)-1) = saved_tracker.min_cost;
    final_tracker.gen_min_cost(idx:idx+length(saved_tracker.gen_min_cost)-1) = saved_tracker.gen_min_cost;
    idx = idx + size(saved_tracker.best_config, 3) - 1;
    delete(tracker_filenames(j))
    clear saved_tracker
end
final_tracker.best_config(:,:,idx:idx+size(tracker.best_config,3)-1) = tracker.best_config;
final_tracker.gen_best_config(:,:,idx:idx+size(tracker.gen_best_config,3)-1) = tracker.gen_best_config;
final_tracker.min_cost(idx:idx+length(tracker.min_cost)-1) = tracker.min_cost;
final_tracker.gen_min_cost(idx:idx+length(tracker.gen_min_cost)-1) = tracker.gen_min_cost;
save(final_tracker_filename, 'final_tracker')