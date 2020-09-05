function config_stats = get_config_stats(config, osf_increments)

% Returns a 2 column array of the anchor numbers and OSFs for a given
% binary config. This is very useful for troubleshooting.

    [anchs, osfs]  = find(config);
    config_stats = [anchs osf_increments(osfs)];

end