function [newTurbX,newTurbY,newAnchX,newAnchY,lastConflicts,conflicts] =...
    AnchConflictResolution(SiteX,SiteY,Angles,TADistance,eps,...
    AnchDists,minAnchDist,minTurbDist,existingTurbX,existingTurbY,existingAnchX,...
    existingAnchY,lastConflicts)
% Resolves distance conflicts between anchors that are too close to each
% other (i.e. less than minAnchDist from each other; 500 meters by
% default). If using single line anchors, the current turbine randomly
% moves to a different location in the site until no anchor conflicts
% remain. If using multiline anchors, the current turbine moves to the
% appropriate position to allow the conflicting anchors to instead share an
% anchor.
conflicts = 1;
currentConflicts = AnchDists(AnchDists < minAnchDist & AnchDists > eps);
% If an anchor is caught between two other anchors less than minAnchDist
% apart, pop it to a random other location. This prevents an infinite loop
% from occurring where the anchor switches back and forth between the two
% nearby anchors
if any(ismember(round(currentConflicts,4),round(lastConflicts,4)))
    newTurbX = SiteX*rand;
    newTurbY = SiteY*rand;
    newAnchX = newTurbX + TADistance*cosd(Angles);
    newAnchY = newTurbY + TADistance*sind(Angles);
    [TurbDists,AnchDists] = ComponentDistance(newTurbX,existingTurbX,...
        newTurbY,existingTurbY,newAnchX,existingAnchX,...
        newAnchY,existingAnchY);
    if all(TurbDists < eps | TurbDists > minTurbDist) && all(AnchDists(:) < eps | AnchDists(:) > minAnchDist)
        conflicts = 0;
    end
else
    [conflictedAnchRow,conflictedAnchCol] = find(AnchDists < minAnchDist & AnchDists > eps);
    % If conflicting anchors are in congruent positions to their
    % respective turbines (e.g. anchor 1 conflicts with a previous
    % anchor 1), pop the current turbine to a different location.
    % Without this, turbines could overlap on one another.
    for k = 1:length(conflictedAnchCol)
        if conflictedAnchRow(k) >= 1 && conflictedAnchRow(k) <= length(existingTurbX)
            if conflictedAnchCol(k) == 1
                newTurbX = SiteX*rand;
                newTurbY = SiteY*rand;
                newAnchX = newTurbX + TADistance*cosd(Angles);
                newAnchY = newTurbY + TADistance*sind(Angles);
                % If conflicting anchors are in complementary positions,
                % move the current position to where the anchors overlap.
                % This will result in the extra anchor being eliminated
                % and the remaining one acting as a shared anchor later on.
            else
                RelocationCoordX = existingAnchX(conflictedAnchRow(k), conflictedAnchCol(k));
                RelocationCoordY = existingAnchY(conflictedAnchRow(k), conflictedAnchCol(k));
                newTurbX = RelocationCoordX - TADistance*cosd(Angles(1));
                newTurbY = RelocationCoordY - TADistance*sind(Angles(1));
                newAnchX = newTurbX + TADistance*cosd(Angles);
                newAnchY = newTurbY + TADistance*sind(Angles);
            end
        elseif conflictedAnchRow(k) >= length(existingTurbX)+1 && conflictedAnchRow(k) <= 2*length(existingTurbX)
            if conflictedAnchCol(k) == 2
                newTurbX = SiteX*rand;
                newTurbY = SiteY*rand;
                newAnchX = newTurbX + TADistance*cosd(Angles);
                newAnchY = newTurbY + TADistance*sind(Angles);
            else
                RelocationCoordX = existingAnchX(conflictedAnchRow(k)-length(existingTurbX), conflictedAnchCol(k));
                RelocationCoordY = existingAnchY(conflictedAnchRow(k)-length(existingTurbX), conflictedAnchCol(k));
                newTurbX = RelocationCoordX - TADistance*cosd(Angles(2));
                newTurbY = RelocationCoordY - TADistance*sind(Angles(2));
                newAnchX = newTurbX + TADistance*cosd(Angles);
                newAnchY = newTurbY + TADistance*sind(Angles);
            end
        elseif conflictedAnchRow(k) >= 2*length(existingTurbX)+1 && conflictedAnchRow(k) <= 3*length(existingTurbX)
            if conflictedAnchCol(k) == 3
                newTurbX = SiteX*rand;
                newTurbY = SiteY*rand;
                newAnchX = newTurbX + TADistance*cosd(Angles);
                newAnchY = newTurbY + TADistance*sind(Angles);
            else
                RelocationCoordX = existingAnchX(conflictedAnchRow(k)-2*length(existingTurbX), conflictedAnchCol(k));
                RelocationCoordY = existingAnchY(conflictedAnchRow(k)-2*length(existingTurbX), conflictedAnchCol(k));
                newTurbX = RelocationCoordX - TADistance*cosd(Angles(3));
                newTurbY = RelocationCoordY - TADistance*sind(Angles(3));
                newAnchX = newTurbX + TADistance*cosd(Angles);
                newAnchY = newTurbY + TADistance*sind(Angles);
            end
        end
    end
    % Recalculate turbine and anchor distances to determine if
    % all distance conflicts are resolved.
    [TurbDists,AnchDists] = ComponentDistance(newTurbX,existingTurbX,...
        newTurbY,existingTurbY,newAnchX,existingAnchX,...
        newAnchY,existingAnchY);
    if all(TurbDists < eps | TurbDists > minTurbDist) && all(AnchDists(:) < eps | AnchDists(:) > minAnchDist)
        conflicts = 0;
    end
    lastConflicts = currentConflicts;
end
end
