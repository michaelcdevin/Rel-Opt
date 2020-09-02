function [stored_configs, stored_costs, stored_num_sims] =...
    update_archives(current_gen, gen_costs, num_sims, gen_archive_idxs,...
    new_archive_idx, stored_configs, stored_costs, stored_num_sims)

% Updates archival variables with new values from current generation.

    for j = 1:length(gen_costs)
        % if config not in archive, create new entry
        if gen_archive_idxs(j) == 0
            new_archive_idx = new_archive_idx + 1;
            stored_configs(:,:,new_archive_idx) = current_gen(:,:,j);
            stored_costs(new_archive_idx) = gen_costs(j);
            stored_num_sims(new_archive_idx) = num_sims;
        % if config is in archive, update archive values
        elseif gen_archive_idxs(j) > 0
            stored_costs(gen_archive_idxs(j)) = gen_costs(j);
            stored_num_sims(gen_archive_idxs(j)) =...
                stored_num_sims(gen_archive_idxs(j)) + num_sims/2;
        end
    end
end