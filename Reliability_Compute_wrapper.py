import matlab.engine


# Start MATLAB Engine
eng = matlab.engine.start_matlab()

# Problem parameters
OverstrengthenedAnchors = [2, 10, 11, 12, 20, 25, 30, 35, 50, 55, 100]
OverstrengthFactor = 1.5
NRows = 10
NCols = 10
TurbSpacing = 1451 #837.6 meters is the default, as this is the standard length of a mooring line (fairlead to anchor distance is 797 meters)
DesignType = 'Real multi' # Design philosophy used for lines and anchors (real means more safety factor, multi is multiline concept)
NSims = 5000 # Number of Monte-Carlo simulations to run
theta = 0 # Incoming wind and wave direction


###########################################################

# Convert problem parameters into MATLAB data types
OverstrengthenedAnchors = matlab.double(OverstrengthenedAnchors)
OverstrengthFactor = float(OverstrengthFactor)
NRows = float(NRows)
NCols = float(NCols)
TurbSpacing = float(TurbSpacing)
DesignType = str(DesignType)
NSims = float(NSims)
theta = float(theta)

Reliability = eng.Reliability_Compute2(OverstrengthenedAnchors, OverstrengthFactor, NRows, NCols, TurbSpacing,
                                       DesignType, NSims, theta)

print(Reliability)