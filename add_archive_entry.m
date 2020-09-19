function [] = add_archive_entry(conn, archive_idx, config, cost, num_sims)

% Adds a new entry to 'archive' table in SQL database, and creates a new\
% table called 'config_#' (where '#' = archive_idx) to the SQL database.

    % Add new entry to archive table
    new_entry = table(archive_idx, cost, num_sims, 'VariableNames',{'id','cost','sims'});
    sqlwrite(conn, 'archive', new_entry)
    
    % Add new config table to database
    [anchs, osfs] = find(config);
    anchs = uint8(anchs);
    osfs = uint8(osfs);
    config_stats = [anchs osfs];
    column_names = {'anch', 'osf'};
    new_config_table = array2table(config_stats, 'VariableNames', column_names);
    sqlwrite(conn, ['config_', num2str(archive_idx)], new_config_table)