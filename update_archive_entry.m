function [] = update_archive_entry(conn, archive_idx, cost, num_sims)

% Updates an existing entry to 'archive' table in SQL database.

    % Delete current row with archive_idx since the update function in
    % Matlab is hilariously stupid and allow different type inputs than
    % sqlwrite allowing floating point errors to emerge.
    fetch(conn, ['delete from archive where id = ', num2str(archive_idx)]);
    
    % Add new entry to archive table
    new_entry = table(archive_idx, cost, num_sims, 'VariableNames',{'id','cost','sims'});
    sqlwrite(conn, 'archive', new_entry)