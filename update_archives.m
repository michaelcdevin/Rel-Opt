function [stored_configs, stored_costs, stored_num_sims] =...
    update_archives(current_gen, gen_costs, num_sims, gen_archive_idxs,...
    new_archive_idx, stored_configs, stored_costs, stored_num_sims)

% Updates archival variables with new values from current generation.

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
end