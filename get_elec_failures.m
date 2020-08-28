function [num_offline_turbs, num_cable_rows_affected] =...
   get_elec_failures(total_turbs_impacted, NTurbs, NCols)

% Given the size of the farm and the turbines impacted by an anchor or
% line failure, calculates how many total turbines lose power connection 
% due to the resulting inter-array cable failures.

num_turbs_on_cable = floor(NCols/2); % @mcd: this doesn't work for odd numbered NCols (since there will be a line of turbines in the middle)
turbs_accounted_for = zeros(1, length(total_turbs_impacted));
count = 1;
num_offline_turbs = 0;
num_cable_rows_affected = 0;

turbine_cable_connect = 1:NTurbs;
turbine_cable_connect = transpose(reshape(turbine_cable_connect, [num_turbs_on_cable, NTurbs/num_turbs_on_cable]));
for j = 1:length(total_turbs_impacted)
    if ~ismember(total_turbs_impacted(j), turbs_accounted_for)
        num_cable_rows_affected = num_cable_rows_affected + 1;
        turbs_on_cable = turbine_cable_connect(ceil(total_turbs_impacted(j)/num_turbs_on_cable), :);
        failed_turbs_on_cable =...
           total_turbs_impacted(find(ismember(total_turbs_impacted, turbs_on_cable)));
        if (0 < mod(total_turbs_impacted(j),floor(NTurbs/NCols))) &&...
                mod(total_turbs_impacted(j),floor(NTurbs/NCols)) <= num_turbs_on_cable
            critical_turb = max(failed_turbs_on_cable);
            downed_turbs = turbs_on_cable(turbs_on_cable <= critical_turb);
        else
            critical_turb = min(failed_turbs_on_cable);
            downed_turbs = turbs_on_cable(turbs_on_cable >= critical_turb);
        end
        num_offline_turbs = num_offline_turbs + length(downed_turbs);
        turbs_accounted_for(count+1:count+length(failed_turbs_on_cable)) = failed_turbs_on_cable;
        count = count + length(failed_turbs_on_cable);
    end
end