function [archive_idx, cost, num_sims] = query_archive(conn, config)

% Searches the SQL archive database for any archived configs that matches
% the current config. If no archived configs match, return zero for all
% outputs. The connection between MATLAB and the database is assumed to
% already be established prior to calling this function.

    % Write temporary row to 'configs' @ id=0 of the current config
    reshaped_config = reshape(config, 1, []);
    config_string = strjoin(string(reshaped_config),'');
    config_table = table(0, config_string, 'VariableNames', {'id', 'config'});
    sqlwrite(conn, 'configs', config_table);

    % Using get_config_num SQL function in database, see if config exists
    % in database.
    query = "select id from (select *, count(*) over (partition by config) as count from configs) tableWithCount where tableWithCount.count > 1 and id > 0";
    archive_idx = fetch(conn, query);
    
    % If config isn't archived, set all function outputs to zero. 
    if isempty(archive_idx)
        archive_idx = 0;
        cost = 0;
        num_sims = 0;
        
    % If config is archived, fetch outputs from SQL archive table
    else
        archive_idx = archive_idx{1,1};
        query_results = fetch(conn, ['select cost, sims from archive where id = ', num2str(archive_idx), ';']);
        cost = query_results{1,1};
        num_sims = query_results{1,2};
    end
    
    % Clean up config row
    fetch(conn, 'delete from configs where id = 0;');
    
end
