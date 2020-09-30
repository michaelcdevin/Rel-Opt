function mutated_config = mutate_config(config, mut_rate)

% Mutates selected config by shifting the OSF of a selection of
% the strengthened anchors.

    [strengthened_anchs, osf_selections] = find(config);
    num_mut_anchs = round(length(strengthened_anchs) * mut_rate);
    mut_anch_idxs = randperm(length(strengthened_anchs), num_mut_anchs);
    
    % Randomly shift OSFs +/- 2 of its original values
    new_osf_selections = osf_selections(mut_anch_idxs) + randi([-2 2], [length(mut_anch_idxs) 1]);
        % Keep mutations within the upper bounds of the array
    new_osf_selections(new_osf_selections>size(config,2)) = size(config,2);
    
    % Remove original OSF value
    config(strengthened_anchs(mut_anch_idxs), :) = 0;
    
    % Prevent anchors that mutate beneath the minimum OSF from being
    % restrengthened.
    mut_anch_idxs(new_osf_selections<1) = [];
    new_osf_selections(new_osf_selections<1) = [];
    
    % Apply new OSF values (note there is a chance that this is unchanged
    % for some anchors).
    for j = 1:length(mut_anch_idxs)
        config(strengthened_anchs(mut_anch_idxs(j)), new_osf_selections(j)) = 1;
    end
    
    mutated_config = config;
    
end