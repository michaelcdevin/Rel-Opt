function [archive_idx, cost, num_sims] = query_archive(conn, config)

% Searches the SQL archive database for any archived configs that matches
% the current config. If no archived configs match, return zero for all
% outputs. The connection between MATLAB and the database is assumed to
% already be established prior to calling this function.

    % Write new database table, 'ml_config', to match new config.
    [anchs, osfs] = find(config);
    anchs = uint8(anchs);
    osfs = uint8(osfs);
    config_stats = [anchs osfs];
    column_names = {'anch', 'osf'};
    ml_config_table = array2table(config_stats, 'VariableNames', column_names);
    sqlwrite(conn, 'ml_config', ml_config_table)

    % Using get_config_num SQL function in database, see if config exists
    % in database.
    archive_idx = fetch(conn, 'select get_config_num();');
    archive_idx = archive_idx{1,1};
    
    % If config isn't archived, set all function outputs to zero. 
    if isnan(archive_idx)
        archive_idx = 0;
        cost = 0;
        num_sims = 0;
        
    % If config is archived, fetch outputs from SQL archive table
    else
        query_results = fetch(conn, ['select cost, sims from archive where id = ', num2str(archive_idx), ';']);
        cost = query_results{1,1};
        num_sims = query_results{1,2};
    end
    
    % Clean up so ml_config doesn't keep getting appended.
    fetch(conn, 'drop table if exists ml_config;');
    
end
