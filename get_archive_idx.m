function [archive_idx] = get_archive_idx(config, stored_configs)

% Searches stored_configs to see if any archived configs matches the input
% config. Returns the archive index of the config, or zero if config is
% not archived.

    % Search archives to see if config has been encountered before
    archive_idx = find(all(config==stored_configs, [1 2]));

    % Config is not in archive
    if isempty(archive_idx)
        archive_idx = 0;
    end
    
end