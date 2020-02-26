function[TurbX,TurbY,AnchorXu,AnchorYu,AnchLineConnect,...
    LineConnect,TurbLineConnect,TurbAnchConnect,NAnchs,NLines,...
    AnchTurbConnect,LineFail,AnchorFail,TurbFail,AnchAnchConnect,...
    LineAnchConnect,LineLineConnect,LAC,ALC] =...
    Geo_Setup_autofit_corrected(NRows,NCols,TurbSpacing,TADistance,NTurbs)

Angles = [180,300,420]; %Line angles

%Preallocation of anchor and turbine coordinates
TurbX = zeros(NTurbs,1);
TurbY = zeros(NTurbs,1);
AnchorX = zeros((NTurbs),3);
AnchorY = AnchorX;
Count = 1;
TriNum = .5*NRows*(NRows+1); %next closest triangle number to NTurbs
toprowCount = TriNum - NTurbs;
if toprowCount <= TriNum-2 && toprowCount > 0
    starttopRow = 2;
elseif toprowCount >= TriNum || toprowCount == 0
    starttopRow = 1;
end

% Create windfarm layout
% Bottom NCol-1 rows
startCol = ceil(NRows/2);
rowCount = 1;
for j = 1:NRows-1
    for i = 1:NCols
        if i >= startCol && i <= rowCount+startCol-1
            TurbX(Count,1) = (j-1)*1.5*TADistance;
            if mod(j,2) ~= 0
                TurbY(Count,1) = (i-1)*TurbSpacing+TurbSpacing/2;
            else
                TurbY(Count,1) = (i-1)*TurbSpacing;
            end
            AnchorX(Count,:) = TurbX(Count) + TADistance*cosd(Angles);
            AnchorY(Count,:) = TurbY(Count) + TADistance*sind(Angles);
            Count = Count + 1;
        end
    end

    rowCount = rowCount + 1;
    if mod(j,2) == 0
        startCol = startCol - 1;
    end
end

% Top row
remTurbs = NTurbs - Count + 1;
while remTurbs > 0
    TurbX(Count,1) = (NCols-1)*1.5*TADistance;
    if mod(NCols,2) ~= 0
        TurbY(Count,1) = (starttopRow-1)*TurbSpacing+TurbSpacing/2;
    else
        TurbY(Count,1) = (starttopRow-1)*TurbSpacing;
    end
    AnchorX(Count,:) = TurbX(Count) + TADistance*cosd(Angles);
    AnchorY(Count,:) = TurbY(Count) + TADistance*sind(Angles);
    Count = Count + 1;
    starttopRow = starttopRow + 1;
    remTurbs = remTurbs - 1;
end

% Rearrange anchors
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