function[failure_cost] = failure_cost(LineFail, AnchorFail,...
    AnchPricePerTon, AnchorStrengths, AnchorsImpacted, OSF_mat)

% Determines the total cost of a turbine failure for a particular
% simulation, including cost of materials, installation costs, and the lost
% energy from downtime.

failed_anchors = find(AnchorFail);
[failed_lines, ~] = find(LineFail);
failed_lines = unique(failed_lines);

line_cost = 208750;
site_repair_cost = 323716;
LCOE = 132; % $/MWh, as per NREL in 2018 Cost of Wind Energy report
max_turbine_power_output = 5; % MW
turbine_capacity_factor = .44;
anchor_repair_time = 12; % hours

anchor_material_cost = 0;
for j = 1:length(failed_anchors)
    anchor_mass = get_anchor_mass(Anchor_Strengths * OSF_mat(j));
    anchor_material_cost = anchor_material_cost +...
        (anchor_mass * AnchPricePerTon); %check this for kg vs. tons (metric tons?)
end
line_material_cost = length(failed_lines) * line_cost;

repair_cost = length(AnchorsImpacted) * site_repair_cost;

%%%%%%%%%%%%% need to define weather_delay_time function
downtime = weather_delay_time + anchor_repair_time;
power_loss_cost = LCOE *...
    (max_turbine_power_output * turbine_capacity_factor) * downtime;

failure_cost = anchor_material_cost + line_material_cost + repair_cost +...
    power_loss_cost;