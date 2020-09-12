function child = create_child(mother, father)

% Performs crossover for a single mother-father pairing.
% Children are produced via uniform crossover, where every anchor is has a
% 50-50 chance of being the mother's or father's version of that anchor.
    
    child = zeros(size(mother));
    
    for j = 1:length(mother)
        prob = rand;
        if prob <= .5
            child(j, :) = mother(j, :);
        elseif prob > .5
            child(j, :) = father(j, :);
        end
    end

end