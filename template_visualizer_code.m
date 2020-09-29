osf_increments = single(1.05:.05:1.4);
random_configs = randsample(4500:length(costs), 50);
for j = 1:length(random_configs)
config = best_configs(:,:,random_configs(j));
anchs = config(:,1);
osfs = config(:,2);
visualize_anchors(10, 10, 1451, 1451*sqrt(3)/3, 100, anchs, osfs, osf_increments, ['config',num2str(j),'.pdf']);
end