function config_cost =...
    evaluate_config(config, rows, cols,...
    turb_spacing, design_type, num_sims, theta, osf_increments,...
    archive_idx, stored_costs, stored_num_sims)

% Evaluates the cost of a specified configuration. If the config has been
% encountered before, the archived cost is retrieved, averaged with a new
% num_sims/2 evaluations. If a config is new, it is evaluated for num_sims
% simulations.

    % config is in binary values. To be readable by
    % Failure_Cost_Compute, translate positions of 1s to their 
    % corresponding anchor numbers and overstrength factors.
    [strengthened_anchs, osf_selections] = find(config);
    osf_selections = osf_increments(osf_selections);

    % config not archived: simulate num_sims times.
    if archive_idx == 0
        config_cost = Failure_Cost_Compute(strengthened_anchs, osf_selections,...
            rows, cols, turb_spacing, design_type, num_sims, theta);
    
    % config archived: retrieve stored values, simulate for num_sims/2 times.
    elseif archive_idx > 0
        old_cost = stored_costs(archive_idx);
        added_cost = Failure_Cost_Compute(strengthened_anchs, osf_selections,...
            rows, cols, turb_spacing, design_type, round(num_sims/2), theta);
        config_cost = (old_cost * (stored_num_sims(archive_idx)/num_sims) + (added_cost/2)) /...
            ((stored_num_sims(archive_idx) + num_sims/2)/num_sims);
    end
        
end