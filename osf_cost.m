function[osf_cost] = osf_cost(AnchorsOverstrengthened,AnchPricePerTon,...
    MfgAnchorStrengths, NAnchs)

% Calculates the total added cost of increasing the anchor strength for all
% overstrengthened anchors

% Determine mass for overstrengthened anchors in metric tons
os_anchor_masses = zeros(1, length(AnchorsOverstrengthened));
for j = 1:length(AnchorsOverstrengthened)
    os_anchor_masses(j) = get_anchor_mass(MfgAnchorStrengths(AnchorsOverstrengthened(j))) / 1000;
end

% Find mass for normal strength anchors in metric tons by randomly
% selecting a non-overstrengthened anchor in the array
rnd_anchor_num = randperm(NAnchs, 1);
while ismember(rnd_anchor_num, AnchorsOverstrengthened)
    rnd_anchor_num = randperm(NAnchs, 1);
end
normal_anchor_mass = get_anchor_mass(MfgAnchorStrengths(rnd_anchor_num)) / 1000;

% Figure out total anchor costs for the entire farm
os_anchor_cost = sum(os_anchor_masses) * AnchPricePerTon;
normal_anchor_cost = length(AnchorsOverstrengthened) * normal_anchor_mass * AnchPricePerTon;

% The total added cost of overstrenghtening
osf_cost = os_anchor_cost - normal_anchor_cost;