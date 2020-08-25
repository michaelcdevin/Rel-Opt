function[failure_cost] = failure_cost(LineFailState, AnchorFail,...
    AnchPricePerTon, MfgAnchorStrengths, downtime_lengths,...
    prob_of_20hr_window)

% Determines the total cost of a turbine failure for a particular
% simulation, including cost of materials, installation costs, and the lost
% energy from downtime.

% Constants
line_cost = 208750;
site_repair_cost = 323716;
LCOE = 132; % $/MWh, as per NREL in 2018 Cost of Wind Energy report
max_turbine_power_output = 5; % MW
turbine_capacity_factor = .44;
vessel_transit_time = 3; % hours (each way, but only consider trip there for downtime)
anchor_repair_time = 14; % hours

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

repair_cost = length(failed_anchors) * site_repair_cost;

% Determine if there's a weather delay. If there is, randomly sample from
% Gulf of Maine data
randnum = rand;
if randnum <= prob_of_20hr_window
    weather_delay_time = 0;
else
    weather_delay_time = datasample(downtime_lengths, 1); % in hours
end

% Calculate total downtime and lost cost-equivalent
downtime = weather_delay_time + vessel_transit_time + anchor_repair_time;
power_loss_cost = LCOE * length(failed_anchors) *...
    (max_turbine_power_output * turbine_capacity_factor) * downtime;

% Calculate total failure cost
failure_cost = anchor_material_cost + line_material_cost + repair_cost +...
    power_loss_cost;