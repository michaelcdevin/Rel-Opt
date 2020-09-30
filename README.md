# Rel-Opt
[![DOI](https://zenodo.org/badge/228912373.svg)](https://zenodo.org/badge/latestdoi/228912373)

This repository is focused on comparing the system reliability and costs associated with an anchor sharing system.

See "Optimizing Strength of Shared Anchors in an Array of Floating Offshore Wind Turbines" for information related to the details of the functionality of this code.

## Installation
Download this repository directly to the local machine. Running this code requires [MATLAB 2020a](https://www.mathworks.com/downloads) or higher.

## Running the Program
Change the operating folder in MATLAB to the download location on the local machine.

### Main Functionality
To run the overall optimization algorithm, change the operating folder in MATLAB to the location on the local machine, and run Failure_Cost_Compute.m

Running **optimize_strength.m** runs the optimization algorithm as discussed in the bulk of the paper.

Every 50 generations, the algorithm exports a MAT file containing the configuration and cost information for each generation.

After the algorithm finishes running, these MAT files are combined into a single file named "optimize_strength_tracking_[timestamp].mat".

The algorithm also outputs 'min_cost_[timestamp].txt', showing the final converged minimum cost, and 'best_config_[timestamp].csv', showing the final overstrengthened anchor selections and the corresponding overstrength factors.

#### Cost Profile Selection
optimize_strength.m runs Profile A as the default. At present, the cost profile is changed by manually modifying the code in failure_cost.m, though the lines to change are clearly marked.
- To run Profile B, uncomment line 94 in failure_cost.m, or multiply `total_substructure_repair_cost` by 3 anytime after line 52.
- To run Profile C, multiply `turb_reconnect_time` (line 24), `turb_quayside_time` (line 26), `quayside_material_cost` (line 27), and `quayside_repair_cost` (line 28) by 5.

### Other Functionality
Running **cost_vs_rels_test.m** performs the test detailed in Section 5.2 of the paper.

Running **sims_vs_cost_test.m** generates a graphic similar to Figure 4 of the paper.

Running **create_seeded_config_images.m** generates the graphics in Table 3 of the paper.

Running **config_visualizer.m** generates graphics similar to those in Table 8 of the paper.

## Other Notes
PDFs of all figures and graphics in the paper are available at [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4059094.svg)](https://doi.org/10.5281/zenodo.4059094) under a CC-BY license.
