function [] = add_archive_entry(conn, archive_idx, config, cost, num_sims)

% Adds a new entry to 'archive' table in SQL database, and creates a new\
% table called 'config_#' (where '#' = archive_idx) to the SQL database.

    % Add new entry to archive table
    new_entry = table(archive_idx, cost, num_sims, 'VariableNames',{'id','cost','sims'});
    sqlwrite(conn, 'archive', new_entry)
    
    % Add new config table to database
    reshaped_config = reshape(config, 1, []);
    config_string = strjoin(string(reshaped_config),'');
    config_table = table(archive_idx, config_string, 'VariableNames', {'id', 'config'});
    sqlwrite(conn, 'configs', config_table);