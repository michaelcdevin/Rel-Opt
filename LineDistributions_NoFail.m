function[Ltension,A1,A2,A3] =...
    LineDistributions_NoFail(Res,SegNum,NAnchs,NTurbs,LD_mu,LD_sigma)



%% Generate line tensions in bulk since all of the distributions are known
% LD_mu = zeros(NTurbs*3,length(SegNum));
% LD_sigma = zeros(NTurbs*3,length(SegNum));
% 
% LD_mu(1:3:end,:) = repmat(LineDist1(1,:),NTurbs,1);
% LD_mu(2:3:end,:) = repmat(LineDist2(1,:),NTurbs,1);
% LD_mu(3:3:end,:) = repmat(LineDist3(1,:),NTurbs,1);
% LD_sigma(1:3:end,:) = repmat(LineDist1(2,:),NTurbs,1);
% LD_sigma(2:3:end,:) = repmat(LineDist2(2,:),NTurbs,1);
% LD_sigma(3:3:end,:) = repmat(LineDist3(2,:),NTurbs,1);

%generate nomrally random numbers, then repeat so
% they all have the same CDF

rn = randn(NTurbs*3,1);
rn = repmat(rn,1,length(SegNum));
Ltension = exp(rn.*LD_sigma+LD_mu); %LN
% Ltension = lognrnd(LD_mu,LD_sigma,NTurbs*3,length(SegNum));
%% Generate all the anchor tensions in bulk since all fo the distributions are known
rn = randn(NTurbs,9); %generate 9 nomrally random numbers

R = Res(1);
LD1 = R.LP1(SegNum,1)';
% Generate anchor random numbers
a11_mu = R.A11(1);
a11_sigma = R.A11(2);
a12_mu = R.A12(1);
a12_sigma = R.A12(2);
a13_mu = R.A13(1);
a13_sigma = R.A13(2);

a21_mu = R.A21(1);
a21_sigma = R.A21(2);
a22_mu = R.A22(1);
a22_sigma = R.A22(2);
a23_mu = R.A23(1);
a23_sigma = R.A23(2);

a31_mu = R.A31(1);
a31_sigma = R.A31(2);
a32_mu = R.A32(1);
a32_sigma = R.A32(2);
a33_mu = R.A33(1);
a33_sigma = R.A33(2);

ba11 = exp(rn(:,1).*a11_sigma+a11_mu); %LN
ba12 = rn(:,2).*a12_sigma+a12_mu; %N
ba13 = rn(:,3).*a13_sigma+a13_mu; %N
ba21 = rn(:,4).*a21_sigma+a21_mu; %N
ba22 = exp(rn(:,5).*a22_sigma+a22_mu); %LN
ba23 = rn(:,6).*a23_sigma+a23_mu; %N
ba31 = rn(:,7).*a31_sigma+a31_mu; %N
ba32 = rn(:,8).*a32_sigma+a32_mu; %N
ba33 = exp(rn(:,9).*a33_sigma+a33_mu); %LN

A1 = [ba11,ba21,ba31]; %Aggregate anchor loads
A2 = [ba12,ba22,ba32];
A3 = [ba13,ba23,ba33];

A1(A1<0) = 0;
A2(A2<0) = 0;
A3(A3<0) = 0;
