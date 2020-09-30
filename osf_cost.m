function[osf_cost] = osf_cost(AnchorsOverstrengthened,AnchPricePerTon,...
    MfgAnchorStrengths, NormalMfgStrength, NAnchs)

% Calculates the total added cost of increasing the anchor strength for all
% overstrengthened anchors

% Determine mass for overstrengthened anchors in metric tons
os_anchor_masses = zeros(1, length(AnchorsOverstrengthened));
for j = 1:length(AnchorsOverstrengthened)
    os_anchor_masses(j) = get_anchor_mass(MfgAnchorStrengths(AnchorsOverstrengthened(j))) / 1000; % /1000 converts kg to tons
end

% Find mass for normal strength anchors
normal_anchor_mass = get_anchor_mass(NormalMfgStrength) / 1000; % /1000 converts kg to tons

% Figure out total anchor costs for all overstrengthened anchors
os_anchor_cost = sum(os_anchor_masses) * AnchPricePerTon;
normal_anchor_cost = length(AnchorsOverstrengthened) * normal_anchor_mass * AnchPricePerTon;

% The total added cost of overstrenghtening
osf_cost = os_anchor_cost - normal_anchor_cost;