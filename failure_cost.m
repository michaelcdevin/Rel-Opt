function[failure_cost] = failure_cost(LineFailState, AnchorFail,...
    IndAnchs, AnchPricePerTon, MfgAnchorStrengths, TurbAnchConnect,...
    centerline_distance, downtime_lengths, prob_of_20hr_window)

% Determines the total cost of a turbine failure for a particular
% simulation, including cost of materials, installation costs, and the lost
% energy from downtime.

% Constants
line_cost = 208750;
substructure_repair_cost = 323716;
cable_material_cost = 481; % $/m
cable_repair_cost = 154; % $/m
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

% Determine number of sites needing repair, for either a failed anchor or a
% failed line
repair_cost = (length(failed_anchors)+length(IndAnchs)) * substructure_repair_cost;

% Determine total length of inter-array cables needing repair, and the cost
% and time required to repair that length
TurbsImpactedFromAnchs = find(ismember(TurbAnchConnect, failed_anchors));
TurbsImpactedFromLines = find(ismember(TurbLineConnect, failed_lines));
TotalTurbsImpacted = unique([TurbsImpactedFromAnchs; TurbsImpactedFromLines]);
total_damaged_cable_length = sum(centerline_distance(TotalTurbsImpacted));
total_cable_material_cost = cable_material_cost * total_damaged_cable_length; 
total_cable_repair_cost = cable_repair_cost * total_damaged_cable_length;

% Determine if there's a weather delay. If there is, randomly sample from
% Gulf of Maine data
randnum = rand;
if randnum <= prob_of_20hr_window
    weather_delay_time = 0;
else
    weather_delay_time = datasample(downtime_lengths, 1); % in hours
end

% Calculate total downtime and lost cost-equivalent
% Note that power_loss_cost includes power losses due to line-only
% failures, but still uses the same downtime length. This assumes that
% line-only failures and cable repairs are handled in the same weather
% window as anchor failures. Also, the average cable downtime 
anchor_downtime = weather_delay_time + vessel_transit_time + anchor_repair_time;
line_downtime = weather_delay_time + vessel_transit_time + line_repair_time;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
avg_cable_downtime = mean(centerline_distance(TotalTurbsImpacted)) / cable_laying_rate * 12;
power_loss_cost = LCOE * length(failed_anchors) *...
    (max_turbine_power_output * turbine_capacity_factor) * anchor_downtime...
    + LCOE * length(IndAnchs) * (max_turbine_power_output *...
    turbine_capacity_factor) * line_downtime;

% Calculate total failure cost
failure_cost = anchor_material_cost + line_material_cost +...
    total_cable_material_cost + substructure_repair_cost +...
    total_cable_repair_cost + power_loss_cost;