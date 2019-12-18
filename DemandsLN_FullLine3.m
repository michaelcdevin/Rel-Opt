function[AnchorDemands,LineDemands] = DemandsLN_FullLine3(Res,NAnchs,...
    AnchorFail,AnchorTurbConnect,...
    NTurbs,TurbFailState,TurbAnchConnect,AnchorStrengths,...
    LinesImpacted,AnchorsImpacted,SegNum,LD_mu,LD_sigma,...
    R1,R2,R3,R4,R6,R7,R10,TurbX,TurbY,Z3,...
    tt,TACx,TACy,C1,C2,C3,S1,S2,S3,ZNTurbs_3)
%% Generate demands. we have 2 cases: no failures, and at least 1 failure
LineDemands = zeros(NTurbs*3,length(SegNum));
AnchorDemands = zeros(NAnchs,1);
AnchorNumbers = repmat([1;2;3],1,NTurbs);

if sum(sum(TurbFailState)) == 0
%     No failures
    [LineDemands,A1,A2,A3] =...
        LineDistributions_NoFail(Res,SegNum,NAnchs,NTurbs,LD_mu,LD_sigma);
    
    [AnchorDemands] = AnchorDemands_NoFail2(A1,A2,A3,AnchorTurbConnect,...
                        C1,C2,C3,S1,S2,S3,ZNTurbs_3);
else
%     At least 1 failure 

%     Vectorize line demands:
    B = [LinesImpacted(1:3:end),LinesImpacted(2:3:end),LinesImpacted(3:3:end)];
    inds = any(B,2);
    LList = 1:NTurbs;
    TurbFailStates = TurbFailState(inds,:);
    SumMat = [1;5;7];
    C = TurbFailStates*SumMat;
    nc = length(C);
    LineMu1 = zeros(length(C),6);
    LineMu2 = zeros(length(C),6);
    LineMu3 = zeros(length(C),6);
    LineStd1 = LineMu1;
    LineStd2 = LineMu2;
    LineStd3 = LineMu3;
    
    
    %% Second one 1 0 0
    ind2 = C == 1;
    n2 = sum(ind2);
    n = 1:nc;
    if n2 > 0
        LineMu2(n(ind2),:) = repmat(R2.LP2(:,1)',n2,1);
        LineMu3(n(ind2),:) = repmat(R2.LP3(:,1)',n2,1);
        LineStd2(n(ind2),:) = R2.L2stdev;
        LineStd3(n(ind2),:) = R2.L3stdev;
    end
    
    %% Third one 0 1 0
    ind3 = C == 5;
    n3 = sum(ind3);
    n = 1:nc;
    if n3 > 0
        LineMu1(n(ind3),:) = repmat(R3.LP1(:,1)',n3,1);
        LineMu3(n(ind3),:) = repmat(R3.LP3(:,1)',n3,1);
        LineStd1(n(ind3),:) = R3.L1stdev;
        LineStd3(n(ind3),:) = R3.L3stdev;
    end
    
    %% Fourth one 0 0 1
    ind4 = C == 7;
    n4 = sum(ind4);
    n = 1:nc;
    if n4 > 0
        LineMu1(n(ind4),:) = repmat(R4.LP1(:,1)',n4,1);
        LineMu2(n(ind4),:) = repmat(R4.LP2(:,1)',n4,1);
        LineStd1(n(ind4),:) = R4.L1stdev;
        LineStd2(n(ind4),:) = R4.L2stdev;
    end
    
    %% Fifth one 1 1 0
    ind5 = C == 6;
    n5 = sum(ind5);
    n = 1:nc;
    if n5 > 0
        LineMu3(n(ind5),:) = repmat(Res(5).LP3(:,1)',n5,1);
        LineStd3(n(ind5),:) = Res(5).L3stdev;
    end
    
    %% Sixth one 1 0 1
    ind6 = C == 8;
    n6 = sum(ind6);
    n = 1:nc;
    if n6 > 0
        LineMu2(n(ind6),:) = repmat(Res(6).LP2(:,1)',n6,1);
        LineStd2(n(ind6),:) = repmat(Res(6).LP2(:,2)',n6,1);
    end
    
    %% Seventh one 0 1 1
    ind7 = C == 12;
    n7 = sum(ind7);
    n = 1:nc;
    if n7 > 0
        LineMu1(n(ind7),:) = repmat(Res(8).LP1(:,1)',n7,1);
        LineStd1(n(ind7),:) = Res(8).L1stdev;
    end
    

    rn1 = randn(nc,6); %Generate random normal numbers
    rn2 = randn(nc,6);
    rn3 = randn(nc,6);
    
    
    LineN1 = exp(rn1.*LineStd1 + LineMu1); %Lognormal
    LineN2 = exp(rn2.*LineStd2 + LineMu2); 
    LineN3 = exp(rn3.*LineStd3 + LineMu3);
    
    LineDemands((LList(inds)-1)*3+1,:) = LineN1;
    LineDemands((LList(inds)-1)*3+2,:) = LineN2;
    LineDemands((LList(inds)-1)*3+3,:) = LineN3;
    
    TCx = TurbX(tt);
    TCy = TurbY(tt);
    dx = TCx - TACx;
    dy = TCy - TACy;
    hypot = sqrt(dx.^2+dy.^2);
    Cx = dx./hypot;
    Sx = dy./hypot;
    for i = 1:NAnchs
        if AnchorsImpacted(i)
            %% Resample line tensions for the appropriate anchors
            TurbsConnected = AnchorTurbConnect(:,i);
            if TurbsConnected(1) ~= 0
                t1 = TurbsConnected(1);
                TFS = TurbFailState(t1,:);
                ANum1 = AnchorNumbers(TurbAnchConnect(:,t1)==i);
                
                [A1] = AnchorDemandFail(TFS,Res,ANum1,...
                    R1,R2,R3,R4,R6,R7,R10,Z3);
            else
                t1 = NaN;
                A1 = Z3;
            end
            if TurbsConnected(2) ~= 0
                t2 = TurbsConnected(2);
                TFS = TurbFailState(t2,:);
                ANum2 = AnchorNumbers(TurbAnchConnect(:,t2)==i);
                
                [A2] = AnchorDemandFail(TFS,Res,ANum2,...
                    R1,R2,R3,R4,R6,R7,R10,Z3);
            else
                t2 = NaN;
                A2 = Z3;
            end
            if TurbsConnected(3) ~= 0
                t3 = TurbsConnected(3);
                TFS = TurbFailState(t3,:);
                ANum3 = AnchorNumbers(TurbAnchConnect(:,t3)==i);
                
                [A3] = AnchorDemandFail(TFS,Res,ANum3,...
                    R1,R2,R3,R4,R6,R7,R10,Z3);
            else
                A3 = Z3;
                t3 = NaN;
            end
            
            if t1 == 0 || isnan(t1)
                af1 = [0 0 0];
            else
                af1 = [A1(ANum1),A2(ANum1),A3(ANum1)];
            end
            if t2 == 0 || isnan(t2)
                af2 = [0 0 0];
            else
                af2 = [A1(ANum2),A2(ANum2),A3(ANum2)];
            end
            if t3 == 0 || isnan(t3)
                af3 = [0 0 0];
            else
                af3 = [A1(ANum3),A2(ANum3),A3(ANum3)];
            end
            if isnan(t1)
                f1x = Z3;
                f1y = Z3;
            else
                f1x = af1*Cx(ANum1,t1);
                f1y = af1*Sx(ANum1,t1);
            end
            if isnan(t2)
                f2x = Z3;
                f2y = Z3;
            else
                f2x = af2*Cx(ANum2,t2);
                f2y = af2*Sx(ANum2,t2);
            end
            if isnan(t3)
                f3x = Z3;
                f3y = Z3;
            else
                f3x = af3*Cx(ANum3,t3);
                f3y = af3*Sx(ANum3,t3);
            end
            
            fx = f1x + f2x + f3x;
            fy = f1y + f2y + f3y;
            f = sqrt(fx.^2 + fy.^2);
            AnchorDemands(i) = max(f);
        end
    end
end

%% Now, using the line loads at the anchor, determine anchor forces
AnchorDemands(AnchorFail == 1) = AnchorStrengths(AnchorFail == 1) + 1;

