create or replace function get_config_num() returns integer as $$
declare
	tables cursor for
		select tablename
		from pg_tables
		where schemaname = 'public'
		and tablename like 'config_%'
		order by tablename;
	matching_config boolean;
	config_num integer;	
begin
	for config in tables loop
		execute 'select case when exists(table ml_config except table ' || config.tablename || ') or exists (table ' || config.tablename || ' except table ml_config) then 0 else 1 end as result;'
		into matching_config;
			if matching_config then
				 config_num := substring(config.tablename from 8);
			end if;
	end loop;
	return config_num;
end;
$$ language plpgsql;