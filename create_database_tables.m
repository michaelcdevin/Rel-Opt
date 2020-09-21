function [] = create_database_tables(conn, num_anchs, num_osf_increments)

% Creates the SQL database 'archive' and 'configs' tables in the proper
% format with the proper column types.

    % Create archive table
    dummy_archive_data = zeros(1,3);
    dummy_archive_table = array2table(dummy_archive_data, 'VariableNames', {'id', 'cost', 'sims'});
    archive_column_types = ["int primary key" "numeric" "numeric"];
    sqlwrite(conn, 'archive', dummy_archive_table, 'ColumnType', archive_column_types);
    fetch(conn, 'truncate archive'); % removes the dummy data

    % Create configs table
    configs_col_names = {'id', 'config'};
    dummy_configs_table = table(0, "00000", 'VariableNames', configs_col_names);
    configs_column_types = ["int primary key" strjoin(["char(",num2str(num_anchs*num_osf_increments),")"],'')];
    sqlwrite(conn, 'configs', dummy_configs_table, 'ColumnType', configs_column_types);
    fetch(conn, 'truncate configs');
    
end