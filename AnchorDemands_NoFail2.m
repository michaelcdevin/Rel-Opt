function[AnchorDemands] = AnchorDemands_NoFail2(A1,A2,A3,AnchorTurbConnect,...
    C1,C2,C3,S1,S2,S3,ZNTurbs_3)

af1 = ZNTurbs_3;
af2 = af1;
af3 = af1;
T1 = AnchorTurbConnect(1,:);
T2 = AnchorTurbConnect(2,:);
T3 = AnchorTurbConnect(3,:);

ind1 = (T1 ~= 0 & ~isnan(T1));
ind2 = (T2 ~= 0 & ~isnan(T2));
ind3 = (T3 ~= 0 & ~isnan(T3));
af1(ind1,:) = [A1(T1(ind1),3),A2(T1(ind1),3),A3(T1(ind1),3)];
af2(ind2,:) = [A1(T2(ind2),1),A2(T2(ind2),1),A3(T2(ind2),1)];
af3(ind3,:) = [A1(T3(ind3),2),A2(T3(ind3),2),A3(T3(ind3),2)];

f1x = af1.*C1;
f2x = af2.*C2;
f3x = af3.*C3;
f1y = af1.*S1;
f2y = af2.*S2;
f3y = af3.*S3;
fx = f1x + f2x + f3x;
fy = f1y + f2y + f3y;
f = sqrt(fx.^2 + fy.^2);

AnchorDemands = max(f,[],2);