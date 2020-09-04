function child = create_child(mother, father, num_anchs, rows)

% Performs crossover for a single mother-father pairing.
% Children are produced from a random combination of sets of anchors from
% each parent. Each set is num_anchs / num_rows long. All OSFs are kept the
% same as the parent (OSFs can be modified via mutation).
    
    child = zeros(size(mother));
    
    num_crossover_pts = num_anchs / rows; % since num_anchs = rows * cols, this will always be an integer
    
    crossover_sets = reshape(1:num_anchs, [rows num_crossover_pts]);
    
    for j = 1:num_crossover_pts
        prob = rand;
        if prob <= .5
            child(crossover_sets(:,j), :) = mother(crossover_sets(:,j), :);
        elseif prob > .5
            child(crossover_sets(:,j), :) = father(crossover_sets(:,j), :);
        end
    end

end