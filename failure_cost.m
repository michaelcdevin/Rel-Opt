function[failure_cost] = failure_cost(LineFailState, AnchorFail, IndAnchs,...
    AnchPricePerTon, MfgAnchorStrengths, TurbAnchConnect, TurbLineConnect,...
    NTurbs, NCols, TADistance, downtime_lengths, prob_of_12hr_window)

% Determines the total cost of a turbine failure for a particular
% simulation, including cost of materials, installation costs, and the lost
% energy from downtime.

% Constants
line_cost = 208750;
substructure_repair_cost = 323716;
cable_material_cost = 481; % $/m
cable_repair_cost = 154; % $/m
cable_length = TADistance*2; % cables won't actually run collinear with mooring, but it's a good estimate to account for water depth + slack
LCOE = 132; % $/MWh, as per NREL in 2018 Cost of Wind Energy report
max_turbine_power_output = 5; % MW
turbine_capacity_factor = .44;
vessel_transit_time = 3; % hours (each way, but only consider trip there for downtime)
anchor_repair_time = 14; % hours
line_repair_time = 4; % hours
cable_laying_rate = 400; % m/day

% Identify which anchors and lines failed in the simulation
failed_anchors = find(AnchorFail);
[failed_lines, ~] = find(LineFailState);
failed_lines = unique(failed_lines);
% disp(['Failed anchors: ', num2str(length(failed_anchors))])
% disp(['Failed lines: ', num2str(length(failed_lines))])

% For each failed anchor, determine its mass and cost
anchor_material_cost = 0;
for j = 1:length(failed_anchors)
    anchor_mass = get_anchor_mass(MfgAnchorStrengths(failed_anchors(j))) / 1000; % in metric tons
    anchor_material_cost = anchor_material_cost +...
        (anchor_mass * AnchPricePerTon);
end

line_material_cost = length(failed_lines) * line_cost;

% Determine repair costs for failed anchors and mooring lines
total_substructure_repair_cost =...
    (length(failed_anchors)+length(IndAnchs)) * substructure_repair_cost;

% Determine total length of inter-array cables needing repair, and the cost
% and time required to repair that length
[~, turbs_impacted_from_anchs] = find(ismember(TurbAnchConnect, failed_anchors));
[turbs_impacted_from_lines, ~] = find(ismember(TurbLineConnect, failed_lines));
total_turbs_impacted = unique([turbs_impacted_from_anchs; turbs_impacted_from_lines]);
total_cable_material_cost = cable_material_cost * length(total_turbs_impacted) * cable_length; 
total_cable_repair_cost = cable_repair_cost * length(total_turbs_impacted) * cable_length;

% Identify how many turbines go offline on average due to cable failures.
% Each set of five consecutive turbine #s are on the same serial
% inter-array cable (i.e. turbines 1-5 are on the same cable), assuming
% 10x10 turbine layout
[num_offline_turbs, num_cable_rows_affected] =...
    get_elec_failures(total_turbs_impacted, NTurbs, NCols);
avg_offline_turbs = mean(num_offline_turbs);

% Determine if there's a weather delay. If there is, randomly sample from
% Gulf of Maine data
randprob = rand;
if randprob <= prob_of_12hr_window
    weather_delay_time = 0;
else
    weather_delay_time = datasample(downtime_lengths, 1); % in hours
end

% Calculate downtime PER SITE FAILURE (in hours).
% Note that power_loss_cost includes power losses due to line-only
% failures, but still uses the same downtime length. This assumes that
% line-only failures and cable repairs are handled in the same weather
% window as anchor failures.
anchor_downtime = weather_delay_time + vessel_transit_time + anchor_repair_time;
line_downtime = weather_delay_time + vessel_transit_time + line_repair_time;
cable_downtime = weather_delay_time + cable_length / (cable_laying_rate * 12);

% Calculate power loss cost-equivalent from downtime lengths and total
% number of farm failures
power_loss_cost_from_anchors = LCOE * length(failed_anchors) *...
    (max_turbine_power_output * turbine_capacity_factor) * anchor_downtime;
power_loss_cost_from_lines = LCOE * length(IndAnchs) *...
    max_turbine_power_output * turbine_capacity_factor * line_downtime;
power_loss_cost_from_electrical =...
    LCOE * cable_downtime * avg_offline_turbs *...
    (max_turbine_power_output * turbine_capacity_factor) * num_cable_rows_affected;

total_power_loss_cost = power_loss_cost_from_anchors +...
    power_loss_cost_from_lines + power_loss_cost_from_electrical;

% Calculate total failure cost
failure_cost = anchor_material_cost + line_material_cost +...
    total_cable_material_cost + total_substructure_repair_cost +...
    total_cable_repair_cost + total_power_loss_cost;