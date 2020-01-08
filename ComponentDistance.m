function [TurbDists,AnchDists] = ComponentDistance(currentTurbX,...
existingTurbsX,currentTurbY,existingTurbsY,currentAnchX,existingAnchsX,...
currentAnchY,existingAnchsY)
% Calculates distances between current turbine/anchors to those previously
% placed using Pythagorean theorem.
% OUTPUTS:
%       TurbDists: Vector of length existingTurbs containing distances
%       between the current turbine and existing turbines
%
%       AnchDists: Matrix of size existingTurbs*3 x 3. The matrix is split
%       into thirds, with the first third being the distances between
%       existing anchors and Anchor 1, second third being the distances
%       between existing anchors and Anchor 2, and so on.
%
%       By default:
%       Anchor 1 is due south of turbine
%       Anchor 2 is due northeast of turbine
%       Anchor 3 is due northwest of turbine

TurbDists = abs(sqrt((currentTurbX - existingTurbsX).^2 + (currentTurbY - existingTurbsY).^2));
count = 1;

for k = 1:3
    AnchDists(count:count+size(existingAnchsX,1)-1,:) =...
        abs(sqrt((currentAnchX(k) - existingAnchsX(:,:)).^2 +...
        (currentAnchY(k) - existingAnchsY(:,:)).^2));
    count = count+size(existingAnchsX,1);
end
end

