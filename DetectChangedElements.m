function[LinesChanged,AnchorsChanged] = DetectChangedElements(LinesImpactedOld,...
    AnchorsImpactedOld,LineFail,AnchorFail,...
    AnchAnchConnect,LineLineConnect,AnchLineConnect,...
    LineAnchConnect,LineConnect,TurbLineConnect,...
    TurbAnchConnect,AnchTurbConnect,nn,LinesImpacted,AnchorsImpacted)


%% Find failed lines and check to see if anything has changed
% Through current formulation, lines impacted by failed anchors are already
% failed, no  need to detect them separately

LineFail = any(LineFail,2);

LI = LineLineConnect(LineFail==1,:);
LI = LI(:);
LinesImpacted(LI) = 1;

lc = LinesImpacted-LinesImpactedOld;
LinesChanged = lc~=0;

%% Find failed anchors and check to see if anything has changed
% Need to find anchors associated with failed lines, as well as anchors
% associated with failed anchors

%Anchors impacted by lines
AI = LineAnchConnect(LineFail==1,:);
AI = AI(:);
AnchorsImpacted(AI) = 1;



% Anchors impacted by anchors
AA = AnchAnchConnect(AnchorFail==1,:);
AA = AA(:);
AA(AA==0) = [];
AnchorsImpacted(AA) = 1;

ac = AnchorsImpacted-AnchorsImpactedOld;
AnchorsChanged = ac~=0;

