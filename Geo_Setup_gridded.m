function[TurbX,TurbY,AnchorXu,AnchorYu,AnchLineConnect,...
    LineConnect,TurbLineConnect,TurbAnchConnect,NAnchs,NLines,...
    AnchTurbConnect,LineFail,AnchorFail,TurbFail,AnchAnchConnect,...
    LineAnchConnect,LineLineConnect,LAC,ALC] =...
    Geo_Setup(NRows,NCols,SiteX,SiteY,DefaultTurbSpacing,TADistance,NTurbs)

Angles = [180,300,420]; %Line angles

%Preallocation of anchor and turbine coordinates
TurbX = zeros(NTurbs,1);
TurbY = zeros(NTurbs,1);
AnchorX = zeros((NTurbs),3);
AnchorY = zeros((NTurbs),3);

%Set a uniform grid of turbines evenly spaced across the site. This is
%used as the basis for the random setup, as modifying this instead of doing
%a completely random layout is much more efficient than doing a true random
%setup with constraint corrections.
SpacingX = SiteX/NCols;
SpacingY = SiteY/NRows;
count = 1;

for j = 1:NRows
    for k = 1:NCols
        TurbX(count) = (k-1)*SpacingX + SpacingX/2;
        TurbY(count) = (j-1)*SpacingY + SpacingY/2;
            
        % Anchor positions are generated in identical configurations for each
        % turbine, based on the turbine placement
        AnchorX(count,:) = TurbX(count) + TADistance*cosd(Angles);
        AnchorY(count,:) = TurbY(count) + TADistance*sind(Angles);
        count = count + 1;
        if count > NTurbs
            break;
        end
    end
end

% Rearrange anchors into a vector form, and if anchors are in identical
% coordinates, delete redundant anchors (this is only relevant for
% multiline configurations)
AnchorYr = reshape(AnchorY',[],1);
AnchorXr = reshape(AnchorX',[],1);
XY = [AnchorXr,AnchorYr];
XY = round(XY*1000000)/1000000;
[~,ind] = unique(XY,'rows','first');
XYu = XY(sort(ind),:);

AnchorXu = XYu(:,1);
AnchorYu = XYu(:,2);
NAnchs = length(AnchorXu); %Total number of anchors
%% Now map the connections between the floaters and the anchors
% This gives us connectivity matrices that can be used as lookup tables
% later on
AList = 1:length(AnchorXu); %List of anchor numbers
NLines = NTurbs*3; %Total number of lines
LineConnect = zeros(NLines,2); %Turbine/line connectivity
TurbLineConnect = zeros(NTurbs,3); %Line/turbine connectivity
TurbAnchConnect = zeros(3,NTurbs); %Turbine anchor connectivity

%% Turbine anchor and line connectivity
for i = 1:NTurbs    
    Ax = round((TurbX(i) + TADistance*cosd(Angles))*1000000)/1000000;
    Ay = round((TurbY(i) + TADistance*sind(Angles))*1000000)/1000000;
    
    TurbAnchConnect(1,i) = AList(AnchorXu == Ax(1) & AnchorYu == Ay(1));
    TurbAnchConnect(2,i) = AList(AnchorXu == Ax(2) & AnchorYu == Ay(2));
    TurbAnchConnect(3,i) = AList(AnchorXu == Ax(3) & AnchorYu == Ay(3));
    
    LineConnect(3*i-2:3*i,1) = i;
    LineConnect(3*i-2,2) = TurbAnchConnect(1,i);
    LineConnect(3*i-1,2) = TurbAnchConnect(2,i);
    LineConnect(3*i,2) = TurbAnchConnect(3,i);
    
    TurbLineConnect(i,1) = 3*i-2;
    TurbLineConnect(i,2) = 3*i-1;
    TurbLineConnect(i,3) = 3*i;
end

%% Anchor connectivity
AnchTurbConnect = zeros(3,NAnchs);
for i = 1:NAnchs
    [a,b] = find(TurbAnchConnect == i);
    ind = [];
    if i == 12
        6;
    end
    for j = 1:length(a)
        if a(j) == 1
            ind(j) = 2;
        elseif a(j) == 2
            ind(j) = 3;
        elseif a(j) == 3
            ind(j) = 1;
        end        
    end
    AnchTurbConnect(ind,i) = b;
end

%% Anchor line connections
AnchLineConnect = zeros(NAnchs,9); %All lines associated with given anchor
for i = 1:NAnchs
    [r,c] = find(TurbAnchConnect == i); %Find turbines directly connected to this anchor
    for j = 1:length(r)
        if r(j) == 1 %Upwind line
            AnchLineConnect(i,1:3) = TurbLineConnect(c(j),:);
        elseif r(j) == 2 %bottom right line
            AnchLineConnect(i,4:6) = TurbLineConnect(c(j),:);
        elseif r(j) == 3 %top right line
            AnchLineConnect(i,7:9) = TurbLineConnect(c(j),:);
        end
    end
end

%% Develop anchor to anchor connections (Anchor associated with all other anchors
AnchAnchConnect = zeros(NAnchs,9); %All anchors associated with given anchor
for i = 1:NAnchs
    [r,c] = find(TurbAnchConnect == i); %Find turbines directly connected to this anchor
    for j = 1:length(r)
        if r(j) == 1 %Upwind line
            AnchAnchConnect(i,1:3) = TurbAnchConnect(:,c(j));
        elseif r(j) == 2 %Bottom right line
            AnchAnchConnect(i,4:6) = TurbAnchConnect(:,c(j));
        elseif r(j) == 3 %Top right line
            AnchAnchConnect(i,7:9) = TurbAnchConnect(:,c(j));
        end
    end
end

%% Develop line and anchor connections
LineAnchConnect = zeros(NLines,3); %All anchors associated with a given line
LineLineConnect = zeros(NLines,3); %All lines associated with a given line
for i = 1:NLines
    TurbNum = LineConnect(i,1);
    Anums = TurbAnchConnect(:,TurbNum);
    LineAnchConnect(i,:) = Anums;
    
    LineNums = TurbLineConnect(TurbNum,:);
    LineLineConnect(i,:) = LineNums;
end

LineFail = zeros(NTurbs*3,6); %Preallocated line failures
AnchorFail = zeros(NAnchs,1); %Preallocated anchor failures
TurbFail = zeros(NTurbs,1); %Preallocated turbine failures

%% Make a list showing which line is directly connected to which anchor
LAC = zeros(NLines,1);
for i = 1:NTurbs
    LineNums = TurbLineConnect(i,:);
    AnchNums = TurbAnchConnect(:,i);
    LAC(LineNums) = AnchNums;
end

%% Make a list that goes from anchor to lines
ALC = zeros(NAnchs,3);
LineList = 1:NLines;
for i = 1:NAnchs
    ac = LineList(LAC==i);
    ALC(i,1:length(ac)) = ac;
end