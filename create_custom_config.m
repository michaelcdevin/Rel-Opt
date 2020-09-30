% this is a super rough script meant to create a set of binary configs.
% Each config must have uniform OSFs. This is useful for creating seeded
% initial configs.

osf_selections = 1:4;

config_set = zeros(120, 20, length(osf_selections));

strengthened_anchs = [2:2:120]';

for j = 1:length(osf_selections)
config_set(strengthened_anchs, osf_selections(j), j) = 1;
end