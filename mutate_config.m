function mutated_config = mutate_config(config, mut_rate)

% Mutates selected config by shifting the OSF of a selection of
% the strengthened anchors.

    [strengthened_anchs, osf_selections] = find(config);
    num_mut_anchs = round(length(strengthened_anchs) * mut_rate);
    mut_anchs = randperm(length(strengthened_anchs), num_mut_anchs);
    
    % Randomly shift OSFs +/- 2 of its original values
    new_osf_selections = osf_selections + randi([-2 2], [length(osf_selections) 1]);
        % Keep mutations within the upper bounds of the array
    new_osf_selections(new_osf_selections>size(config,2)) = size(config,2);
    
    % Remove original OSF value
    config(strengthened_anchs(mut_anchs), :) = 0;
    
    % Unstrengthen anchors that mutate beneath the minimum OSF
    new_osf_selections(new_osf_selections<1) = [];
    strengthened_anchs(new_osf_selections<1) = [];
    
    % Apply new OSF values (note there is a chance that this is unchanged
    % for some anchors).
    for j = 1:length(new_osf_selections)
        config(strengthened_anchs(j), new_osf_selections(j)) = 1;
    end
    
    mutated_config = config;
    
end