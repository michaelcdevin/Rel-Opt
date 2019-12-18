function[nAnchs] =...
    FindAnchors(NRows,NCols,TurbSpacing,TADistance,NTurbs)

Angles = [180,300,420]; %Line angles

%Preallocation of anchor and turbine coordinates
TurbX = zeros(NTurbs,1);
TurbY = zeros(NTurbs,1);
AnchorX = zeros((NTurbs),3);
AnchorY = AnchorX;
Count = 1;

%Create windfarm layout
for j = 1:NRows    
    for i = 1:NCols
        if mod(j,2) == 0
            TurbX(Count,1) = (i-1)*1.5*TADistance;
        else
            TurbX(Count,1) = (i-1)*1.5*TADistance;
        end
        if mod(i,2) == 0
            TurbY(Count,1) = (j-1)*TurbSpacing+TurbSpacing/2;
        else
            TurbY(Count,1) = (j-1)*TurbSpacing;
        end
        
        AnchorX(Count,:) = TurbX(Count) + TADistance*cosd(Angles);
        AnchorY(Count,:) = TurbY(Count) + TADistance*sind(Angles);
        Count = Count + 1;
    end
end

% Rearrange anchors
AnchorYr = reshape(AnchorY',[],1);
AnchorXr = reshape(AnchorX',[],1);
XY = [AnchorXr,AnchorYr];
XY = round(XY*1000000)/1000000;
[~,ind] = unique(XY,'rows','first');
XYu = XY(sort(ind),:);
AnchorXu = XYu(:,1);

nAnchs = length(AnchorXu); %Total number of anchors

end