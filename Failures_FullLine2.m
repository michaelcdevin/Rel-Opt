function[LineFail,AnchorFail,TurbFail,LineStrengths,AnchorStrengths,...
    TurbFailState,TurbX,TurbY,IndAnchs] =...
    Failures_FullLine2(AnchorStrengths,AnchorDemands,LineStrengths,...
    LineDemands,TurbFail,TurbX,TurbY,TList,ALC,D)

%% Start with line failures
LineFail = LineDemands >= LineStrengths;

% IndLineFails designates line failures unrelated to anchor failures
[IndLineFails,~] = find(LineFail);
IndLineFails = unique(IndLineFails);

%% Next, find anchor failures
AnchorFail = AnchorDemands >= AnchorStrengths;
% Set failed anchor capacities equal to zero so that they continue to be
% failed
AnchorStrengths(AnchorFail) = 0;

% Next, fail the lines connected to the failed anchors
LF = ALC(AnchorFail,:);
AnchLineFails = reshape(LF,[],1);
% LineFail2 = LineFail;
LineFail(LF(LF~=0),:) = 1;
LineStrengths(LineFail) = 0;

% Isolate the anchors connected to lines that fail independently
IndLineFails = IndLineFails(~ismember(IndLineFails, AnchLineFails));
if ~isempty(IndLineFails) % non-failed anchors associated with failed lines
    [IndAnchs,~] = find(ismember(ALC, IndLineFails));
else
    IndAnchs = [];
end

%Next, update the turbine failure state and indicate if a turbine has
%failed
TurbFailState = LineFail;
TurbFailState = sum(TurbFailState,2);
TurbFailState(TurbFailState>0) = 1;
TurbFailState = reshape(TurbFailState,3,[])';
%% Now update the location of the turbines !!!!!!!!!!!!! NEED TO UPDATE THIS FOR MULTIPLE ANGLES AND ACTUAL SURGE AND DRIFTS !!!!!!!!!!!!!!

% Add turbine displacements with no failures
n_ind = any(TurbFailState,2);
for i = TList(n_ind)
    lf = TurbFailState(i,:);
    if lf(1) == 0 && lf(2) == 0 && lf(3) == 0 %sum(lf == [0 0 0]) == 3 % strcmp(lf,'0  0  0')
        TurbX(i) = TurbX(i) + D(1,1); %Displacements(1).Surge;
        TurbY(i) = TurbY(i) + D(1,2); %Displacements(1).Sway;
    elseif lf(1) == 1 && lf(2) == 0 && lf(3) == 0 %sum(lf == [1 0 0]) == 3 % strcmp(lf,'1  0  0')
        TurbX(i) = TurbX(i) + D(2,1); % 418.8 + Displacements(2).Surge;
        TurbY(i) = TurbY(i) + D(2,2); % 0 + Displacements(2).Sway;
    elseif lf(1) == 0 && lf(2) == 1 && lf(3) == 0 %sum(lf == [0 1 0]) == 3 %strcmp(lf,'0  1  0')
        TurbX(i) = TurbX(i) + D(3,1); % -209.4 + Displacements(3).Surge;
        TurbY(i) = TurbY(i) + D(3,2); % 362.7 + Displacements(3).Sway;
    elseif lf(1) == 0 && lf(2) == 0 && lf(3) == 1 %sum(lf == [0 0 1]) == 3 % strcmp(lf,'0  0  1')
        TurbX(i) = TurbX(i) + D(4,1); % -209.4 + Displacements(4).Surge;
        TurbY(i) = TurbY(i) + D(4,2); % -362.7 + Displacements(4).Sway;
    elseif lf(1) == 1 && lf(2) == 1 && lf(3) == 0 %sum(lf == [1 1 0]) == 3 % strcmp(lf,'1  1  0')
        TurbX(i) = TurbX(i) + D(5,1); % 418.8 + Displacements(5).Surge;
        TurbY(i) = TurbY(i) + D(5,2); % 725.4 + Displacements(5).Sway;
    elseif lf(1) == 1 && lf(2) == 0 && lf(3) == 1 %sum(lf == [1 0 1]) == 3 % strcmp(lf,'1  0  1')
        TurbX(i) = TurbX(i) + D(6,1); % 418.8 + Displacements(6).Surge;
        TurbY(i) = TurbY(i) + D(6,2); % -725.4 + Displacements(6).Sway;
    elseif lf(1) == 0 && lf(2) == 1 && lf(3) == 1 % sum(lf == [0 1 1]) == 3%  strcmp(lf,'0  1  1')
        TurbX(i) = TurbX(i) + D(7,1); % 837.6 + Displacements(6).Surge;
        TurbY(i) = TurbY(i) + D(7,2); % 0 + Displacements(6).Sway;
    end    
end
