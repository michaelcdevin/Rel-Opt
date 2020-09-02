function anchor_mass = get_anchor_mass(anchor_capacity)

% Determines the geometry and mass of a suction pile anchor (in kilgrams)
% based on its capacity. These equations are generated from Table 5.5 from
% "Offshore Anchor Data for Preliminary Design of Anchors of Floating
% Offshore Wind Turbines" from the American Bureau of Shipping.

steel_density = 7850; %kg/m3, assume A36

L = 1.1161 * anchor_capacity ^ .3442;
D = .3095 * anchor_capacity ^ .2798;
T = 2.058 * anchor_capacity ^ .2803 / 1000;

anchor_mass = ((pi*(D/2)^2 * L) - (pi*(((D-2*T)/2)^2 * L))) * steel_density; % in kg
