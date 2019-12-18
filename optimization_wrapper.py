import matlab.engine

# Start MATLAB Engine
eng = matlab.engine.start_matlab()

# Problem parameters
nOverstrengthenedAnchors = 10
OverstrengthFactor = 1.5
nPop = 10
nRows = 5
nCols = 5
TurbSpacing = 1451 #837.6 meters is the default, as this is the standard length of a mooring line (fairlead to anchor distance is 797 meters)
DesignType = 'Real multi' # Design philosophy used for lines and anchors (real means more safety factor, multi is multiline concept)
theta = 0

###########################################################

# Convert problem parameters into MATLAB data types
nOverstrengthenedAnchors = float(nOverstrengthenedAnchors)
OverstrengthFactor = float(OverstrengthFactor)
nRows = float(nRows)
nCols = float(nCols)
TurbSpacing = float(TurbSpacing)
DesignType = str(DesignType)
theta = float(theta)

BestRel, BestTurbs = eng.Anchor_Optimization_2019_07_03(nOverstrengthenedAnchors, OverstrengthFactor, 'nRows', nRows, 'nCols', nCols,
                                   'TurbSpacing', TurbSpacing, 'DesignType',DesignType,'theta',theta, nargout=2)
print(BestRel)
print(BestTurbs)