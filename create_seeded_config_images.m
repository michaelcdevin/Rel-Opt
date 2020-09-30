clear
clc
clf
close all
load('seeded_configs_10x10.mat');
config_count = 0;
for j = 1:4:size(seeded_configs,3)
    config_count = config_count + 1;
    [strengthened_anchs, ~] = find(seeded_configs(:,:,j));
    visualize_anchors(10, 10, 1451, 1451*sqrt(3)/3, 100, strengthened_anchs, [], 0, ['seeded_config_',num2str(config_count),'.pdf']);
end