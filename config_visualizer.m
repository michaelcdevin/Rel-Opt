function [] = config_visualizer(config_file)

    % Generates and saves a graphic named 'config.pdf' showing the selected
    % overstrengthened anchors and corresponding overstrength factors.
    % Input argument 'config_file' should be a MAT file containing an
    % n-by-2 array of the configuration information, as generated the
    % output tracker files from the optimization algorithm.
    
    config_data = importdata(config_file);
    if ~isempty(find(config_data==0))
        config_data(config_data==0) == [];
        config_data = reshape(config_data, [], 2);
    end

    anchs = config_data(:,1);
    osfs = config_data(:,2);
    visualize_anchors(10, 10, 1451, 1451*sqrt(3)/3, 100, anchs, osfs, osf_increments, 'config.pdf');

end