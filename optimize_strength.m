function [min_cost, best_config] = optimize_strength(varargin)

% Anchor optimization for reliability calculations of multiline FOWT array
% Michael Devin, Oregon State University, 2020 Aug 28

%% Optimization parameters
pop_size = 50; % population size
num_osf_increments = 11; % 1:.1:2 by default
cross_ptg = .3; % crossover percentage
clone_ptg = .2; % cloning percentage
convergence_its = 10; % number of iterations needed for convergence to be declared and loop to stop

osf_increments = linspace(1, 2, num_osf_increments);
num_children = round(cross_ptg * pop_size);
num_clones = round(clone_ptg * pop_size);
if mod(num_children,2) == 1 %if nChildren is odd, make it even
    num_children = num_children + 1;
    if num_children + num_clones > nPop %basically, if nPop = 2
        num_clones = 0;
    end
end

%% Evaluation parameters
rows = 10;
cols = 10;
turb_spacing = 1451;
design_type = 'Real multi';
num_sims = 5000; % remove later once you get modular checking working
theta = 0;

num_turbs = rows * cols;
turb_anch_distance = turb_spacing * sqrt(3)/3;
num_anchs = FindAnchors(rows, cols, turb_spacing, turb_anch_distance, num_turbs);

%% Preallocate matrices
current_gen = zeros(num_anchs, num_osf_increments, pop_size);
next_gen = zeros(num_anchs, num_osf_increments, num_children + num_clones);
gen_costs = zeros(pop_size, 1);
gen_costs_enum = zeros(pop_size, 2);

%% Start GA loop
converged = 0;
gen = 0; % generation counter
convergence_counter = 0; % if convergence_counter == convergence_its, problem is considered optimized

while ~converged
    gen = gen + 1; %increment generation counter
    
    %% Create population
    % Rows are different anchors, columns are different OSFs, pages are
    % different organisms.
    
    % Fill population with clones and children from last iteration (none if first iteration)
    current_gen(:,:,1:num_children+num_clones) = next_gen;
    
    % Fill remaining population with random configurations
    for j = num_children + num_clones + 1:pop_size
        num_strengthened_anchs = round(num_anchs * rand);
        strengthened_anchs = randperm(num_anchs, num_strengthened_anchs);
        osf_selections = randi(num_osf_increments, num_strengthened_anchs, 1);
        % Make sure only 1 OSF selection is made per strengthened anchor
        for k = 1:length(osf_selections)
            current_gen(strengthened_anchs(k), osf_selections(k), j) = 1;
        end
    end
    
    %% Evaluate population
    
    for j = 1:pop_size
        % current_gen is in binary values. To be readable by
        % Failure_Cost_Compute, translate positions of 1s to their 
        % corresponding anchor numbers and overstrength factors.
        [strengthened_anchs, osf_selections] = find(current_gen(:,:,j));
        osf_selections = osf_increments(osf_selections);

        % Evaluate configurations
        gen_costs(j) = Failure_Cost_Compute(strengthened_anchs, osf_selections,...
            rows, cols, turb_spacing, design_type, num_sims, theta);
        
        % pop_costs is enumerated so costs can be ranked without losing the
        % link to the respective configurations
        gen_costs_enum(j, :) = [j, gen_costs(j)];
        
    end
    
    % Sort costs from best to worst
    gen_costs_enum_sorted = sortrows(gen_costs_enum, 2);
    
    % Saves the lowest cost and respective configuration for the generation
    gen_min_cost = gen_costs_enum_sorted(1,2);
    [gen_best_strengthened_anchs, gen_best_osf_selections] =...
        find(current_gen(:,:,gen_costs_enum_sorted(1,1)));
    gen_best_config = [gen_best_strengthened_anchs gen_best_osf_selections];
    
    % Update overall lowest cost and respective configuration if applcble.
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
    
    convergence_counter = convergence_counter + 1;
    
    % Determine if problem is considered optimized.
    if convergence_counter == convergence_its
        converged = 1;
    end
    
    %% Generate new population
    
    % Cloning: copy best chromosomes to next generation. Note that cloned
    % chromosomes are also potential parents.
    next_gen(:,:,1:nClones) = current_gen(:,:,gen_costs_enum_sorted(1:nClones,1));

    % Kill: since the algorithm and evaluation already have a high amount
    % of stochasticity, all below-average chromosomes are removed to
    % improve convergence speed.
    gen_avg_cost = mean(gen_costs);
    gen_good_costs_enum =...
        gen_costs_enum_sorted(gen_costs_enum_sorted(:,2)>gen_avg_cost);
    
    % Fitness function: fitness of each configuration is equal to the
    % number of st. devs. above average it is out of the sum of total
    % st. devs. above average.
    gen_std = std(gen_costs);
    gen_fitness = (gen_good_costs_enum(:,2) - gen_avg_cost) / gen_std;
    gen_fitness = cumsum(gen_fitness / sum(gen_fitness));
    
    % Selection: there is no practical difference between mothers and
    % fathers, they are just more intuitive to use as variables than
    % "groupofparent1s" and "groupofparent2s". Each mother-father
    % combination produces 1 child, but there is nothing preventing the
    % same config to be used for multiple mother-father pairings since
    % monogamy is not a moral value in this algorithm.
    mother_probs = rand(num_children, 1);
    father_probs = rand(num_children, 1);
    
        % Connect probabilities to configs.
        %%%%%%%%%%%%%% NEED TO ADD PROPER ENUMERATION TO GEN_FITNESS!!!
    fitness_repmat = repmat(gen_fitness, [1 num_children]);
    mother_probs_diff = fitness_repmat - mother_probs';
    mother_probs_diff(mother_probs_diff<0) = nan;
    [~, mothers_idxs] = min(mother_probs_diff);
    mothers = current_gen(:,:,mothers_idxs);
    father_probs_diff = fitness_repmat - father_probs';
    father_probs_diff(father_probs_diff<0) = nan;
    [~, fathers_idxs] = min(father_probs_diff);
    fathers = current_gen(:,:,fathers_idxs);
    
    % Crossover: children are produced from a random combination of the
    % strengthened anchors of its two parents (keeping the OSF the same).
    % If the same anchor is selected from both parents, its OSF value is
    % averaged for the child.
    

    %% Mutation?

end

end