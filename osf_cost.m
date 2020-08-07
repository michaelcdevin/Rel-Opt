function[osf_cost] = osf_cost(AnchorsOverstrengthened, OverstrengthFactor,...
    AnchPricePerTon, AnchorStrengths)

% Calculates the total added cost of increasing the anchor strength for all
% overstrengthened anchors

steel_density = 7850; %kg/m3, assume A36

nOSA = length(AnchorsOverstrengthened);

normal_strength = AnchorStrengths;
OSF_strength = normal_strength * OverstrengthFactor;

normal_mass = get_anchor_mass(normal_strength);
OSF_mass = get_anchor_mass(OSF_strength);

normal_anchor_cost = nOSA * OSF_mass * AnchPricePerTon; %check this for kg vs. tons (metric tons?)
osf_anchor_cost = nOSA * normal_mass * AnchPricePerTon;

osf_cost = osf_anchor_cost - normal_anchor_cost;