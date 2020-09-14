function[failure_cost] = failure_cost(LineFailState, AnchorFail,...
    AnchPricePerTon, MfgAnchorStrengths, TurbAnchConnect, TurbLineConnect,...
    NTurbs, NCols, TADistance, downtime_lengths, prob_of_12hr_window)

% Determines the total cost of a turbine failure for a particular
% simulation, including cost of materials, installation costs, and the lost
% energy from downtime.

% Constants
line_cost = 208750; % $/line
substructure_repair_cost = 343720; % $/anchor
anch_decom_cost = 903828; % $/anchor
anch_disposal_cost = 495887; % $
turb_tow_cost = 727942; % $/turbine
cable_material_cost = 481; % $/m
cable_repair_cost = 154; % $/m
cable_length = TADistance*2; % cables won't actually run collinear with mooring, but it's a good estimate to account for water depth + slack
LCOE = 132; % $/MWh, as per NREL in 2018 Cost of Wind Energy report
max_turbine_power_output = 5; % MW
turb_capacity_factor = .44;
ahts_transit_time_notow = 3; % hours (each way, but only consider trip there for downtime)
ahts_transit_time_tow = 10; % hours
anchor_repair_time = 14; % hours
turb_reconnect_time = 4; % hours
cable_laying_rate = 400; % m/day
turb_quayside_time = 168; % hours
quayside_material_cost = 10200; % $
quayside_repair_cost = 109985; % $ (for a week's worth of work)


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
    length(failed_anchors) * substructure_repair_cost +...
    length(failed_anchors) * anch_decom_cost +...
    anch_disposal_cost;

% Determine total length of inter-array cables needing repair, and the cost
% and time required to repair that length
[~, turbs_impacted_from_anchs] = find(ismember(TurbAnchConnect, failed_anchors));
[turbs_impacted_from_lines, ~] = find(ismember(TurbLineConnect, failed_lines));
total_turbs_impacted = unique([turbs_impacted_from_anchs; turbs_impacted_from_lines]);
total_cable_material_cost = cable_material_cost * length(total_turbs_impacted) * cable_length; 
total_cable_repair_cost = cable_repair_cost * length(total_turbs_impacted) * cable_length;

% Determine cost from towing the turbines to and from quayside for
% inspection
total_turb_tow_cost = turb_tow_cost * length(total_turbs_impacted);

% Identify how many turbines go offline on average due to cable failures.
% Each set of five consecutive turbine #s are on the same serial
% inter-array cable (i.e. turbines 1-5 are on the same cable), assuming
% 10x10 turbine layout
[num_offline_turbs, num_cable_rows_affected] =...
    get_elec_failures(total_turbs_impacted, NTurbs, NCols);
avg_offline_turbs = mean(num_offline_turbs);

% Calculate repair time PER ANCHOR SITE FAILURE (in hours).
cable_repair_time = cable_length / (cable_laying_rate * 12);
site_repair_time_noweather = ahts_transit_time_notow + ahts_transit_time_tow +...
    anchor_repair_time + turb_quayside_time + ahts_transit_time_tow +...
    turb_reconnect_time + cable_repair_time;

% Determine how much time is added waiting for weather windows to open.
days_of_labor = ceil((site_repair_time_noweather-turb_quayside_time) / 12);
randprobs = rand([days_of_labor 1]);
weather_delay_time =...
    sum(datasample(downtime_lengths, length(randprobs(randprobs>prob_of_12hr_window))));
total_site_repair_time = weather_delay_time + site_repair_time_noweather;

% Calculate power loss cost-equivalent from downtime lengths and total
% number of farm failures
total_power_loss_cost = LCOE * avg_offline_turbs *...
    (max_turbine_power_output * turb_capacity_factor) *...
    num_cable_rows_affected * total_site_repair_time;

% Calculate total failure cost
failure_cost = anchor_material_cost + line_material_cost +...
    total_cable_material_cost + quayside_material_cost +...
    total_substructure_repair_cost + quayside_repair_cost +...
    total_cable_repair_cost + total_turb_tow_cost + total_power_loss_cost;