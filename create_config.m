function config = create_config(num_anchs, num_osf_increments)

% Creates a random generated num_anchs x num_osf_increments binary
% configuration of strengthened anchors.

    config = zeros(num_anchs, num_osf_increments);

    % Select which anchors are strengthened
    num_strengthened_anchs = ceil(num_anchs * rand);
    strengthened_anchs = randperm(num_anchs, num_strengthened_anchs);

    % Select which overstrength factor is used for each strengthened anchor
    osf_selections = randi(num_osf_increments, num_strengthened_anchs, 1);
    % Make sure only 1 OSF selection is made per strengthened anchor
    for k = 1:length(osf_selections)
        config(strengthened_anchs(k), osf_selections(k)) = 1;
    end

end