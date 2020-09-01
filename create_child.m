function child = create_child(mother, father)

% Performs crossover for a single mother-father pairing.
% Children are produced from a random combination of the
% strengthened anchors of its two parents (keeping the OSF the same).
% If the same anchor is selected from both parents, its OSF value is
% averaged for the child.
    
    child = zeros(size(mother));
    
    [mother_anchs, mother_osfs] = find(mother);
    [father_anchs, father_osfs] = find(father);
    parent_anchs_pool = [mother_anchs mother_osfs;father_anchs father_osfs];
    parent_anchs_pool_unique = unique(parent_anchs_pool(:,1));
    
    child_anchs =...
        parent_anchs_pool_unique(randperm(length(parent_anchs_pool_unique),...
        ceil(length(parent_anchs_pool_unique) * rand)));

    for k = 1:length(child_anchs)
        child_current_osf =...
            round(mean(parent_anchs_pool(find(parent_anchs_pool(:,1)==child_anchs(k)), 2)));
        child(child_anchs(k), child_current_osf) = 1;
    end

end