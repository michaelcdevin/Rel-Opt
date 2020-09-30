function child = create_child(mother, father)

% Performs crossover for a single mother-father pairing.
% Children are produced via uniform crossover, where every anchor is has a
% 50-50 chance of being the mother's or father's version of that anchor.
    
    child = zeros(size(mother));
    
    % Makes sure child isn't identical to either parent. If this is not
    % achieved after awhile, create a random config for the child.
    nonclone = 0;
    nonclone_tries = 0;
    max_nonclone_tries = 5;
    while ~nonclone
        for j = 1:length(mother)
            prob = rand;
            if prob <= .5
                child(j, :) = mother(j, :);
            elseif prob > .5
                child(j, :) = father(j, :);
            end
        end
        
        % Child is not identical to either parent
        if (~all(child==mother, [1 2])) && (~all(child==father, [1 2]))
            nonclone = 1;
        else
            nonclone_tries = nonclone_tries + 1;
            if nonclone_tries > max_nonclone_tries
                child = create_config(size(mother, 1), size(mother, 2));
                nonclone = 1;
            end
        end
    end

end