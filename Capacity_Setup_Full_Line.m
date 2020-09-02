function[ChainStrengths,AnchorStrengths, MfgAnchorStrengths, NormalMfgStrength] =...
    Capacity_Setup_Full_Line(NTurbs,NAnchs,NumSamples,...
    SegNum,Res,dtype,Asingle,Amulti)


if strcmp(dtype , 'Exact single')
    LineStrength = 4016*1000;
    LineSafetyFactor = 1.05;
    LineMeanOffset = 1.25;
elseif strcmp(dtype , 'Exact multi')
    LineStrength = 4016*1000;
    LineSafetyFactor = 1.05;
    LineMeanOffset = 1.25;
elseif strcmp(dtype , 'Real single')
    LineStrength = 5111*1000;
    LineSafetyFactor = 1.0;
    LineMeanOffset = 1.25;
elseif strcmp(dtype , 'Real multi')
    LineStrength = 5111*1000;
    LineSafetyFactor = 1.0;
    LineMeanOffset = 1.25;
end

% LineStrength = 2*LineStrength;
%% Variables for line strength
MeanLine = LineStrength*LineMeanOffset*LineSafetyFactor; %1.25 is nominal to mean, and 1.05 is safey factor
COV_Line = 0.1;
v_line = (COV_Line*MeanLine)^2;

Single_mu = log(MeanLine/sqrt(1+v_line/MeanLine^2));
Single_sigma = sqrt(log(1+v_line/MeanLine^2));

ChainStrengths = lognrndFAST(Single_mu,Single_sigma,NTurbs*3,length(SegNum)); %rows are line number, columns are segment number there are a total of 6 segments approximately 140m apart for a 835 chain, to satisfy that there be a test for every 152 meters of chain

%% Variables for anchor strength.
% Design anchors appropriately. For the multiline case, make sure that the
% anchors around the edge (Asingle) are designed for single line forces

if strcmp(dtype , 'Exact single')
    SingleAnchorStrength = 3848*1000;
    MultiAnchorStrength = 3848*1000;
    SingleAnchorFS = 1.5;
    MultiAnchorFS = 1.5;
    Misalignment = 1.0;
elseif strcmp(dtype , 'Exact multi')
    SingleAnchorStrength = 3848*1000;
    MultiAnchorStrength = 3438*1000;
    SingleAnchorFS = 1.5;
    MultiAnchorFS = 1.5;
    Misalignment = 1.0;
elseif strcmp(dtype , 'Real single')
    SingleAnchorStrength = 3866*1000;
    MultiAnchorStrength = 3866*1000;
    SingleAnchorFS = 1.5;
    MultiAnchorFS = 1.5;
    Misalignment = 1.05;
elseif strcmp(dtype , 'Real multi')
    SingleAnchorStrength = 3460*1000;
    MultiAnchorStrength = 3460*1000;
    SingleAnchorFS = 1.5;
    MultiAnchorFS = 1.5;
    Misalignment = 1.05;
end

SingleMeanAnchor = SingleAnchorStrength*SingleAnchorFS*Misalignment; %Mean anchor strength
COV_Anchor = 0.20;
Single_v_anchor = (COV_Anchor*SingleMeanAnchor)^2;
Single_mu = log(SingleMeanAnchor/sqrt(1+Single_v_anchor/SingleMeanAnchor^2));
Single_sigma = sqrt(log(1+Single_v_anchor/SingleMeanAnchor^2));
Single_AnchorStrengths = lognrndFAST(Single_mu,Single_sigma,length(Asingle),NumSamples);

MultiMeanAnchor = MultiAnchorStrength*MultiAnchorFS*Misalignment; %Mean anchor strength
COV_Anchor = 0.20;
Multi_v_anchor = (COV_Anchor*MultiMeanAnchor)^2;
Multi_mu = log(MultiMeanAnchor/sqrt(1+Multi_v_anchor/MultiMeanAnchor^2));
Multi_sigma = sqrt(log(1+Multi_v_anchor/MultiMeanAnchor^2));
Multi_AnchorStrengths = lognrndFAST(Multi_mu,Multi_sigma,length(Amulti),NumSamples);

AnchorStrengths = zeros(NAnchs,1);
AnchorStrengths(Asingle) = Single_AnchorStrengths;
AnchorStrengths(Amulti) = Multi_AnchorStrengths;

% @mcd: THIS SECTION IS NOT CURRENTLY VALID FOR EXACT MULTI DESIGNTYPE!!!
% To make the math easier later on, MfgAnchorStrengths is in kN, while
% AnchorStrengths is in N
MfgAnchorStrengths = ones(NAnchs,1) * MultiMeanAnchor / 1000;
NormalMfgStrength = MultiMeanAnchor / 1000;
