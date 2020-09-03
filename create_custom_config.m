% this is a super rough script meant to create a set of binary configs.
% Each config must have uniform OSFs. This is useful for creating seeded
% initial configs.

osf_selections = [5 10 15 20];

box = zeros(120, 20, length(osf_selections));

strengthened_anchs = [3 7 11 15 19 23 31 34 42 45 53 56 64 67 75 78 86 89 97 100 101 103 105 107 108]';

for j = 1:length(osf_selections)
box(strengthened_anchs, osf_selections(j), j) = 1;
end