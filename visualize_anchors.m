function[] = visualize_anchors(NRows, NCols, DefaultTurbSpacing, TADistance,...
    NTurbs, strengthened_anchs, osfs, osf_increments, pdf_filename)

    close all
    F = figure;
    hold all

    [TurbX,TurbY,AnchorX,AnchorY,~,LineConnect,~,~,num_anchs,~,~,~,~,~,~,~,~,~,~] =...
        Geo_Setup_original(NRows,NCols,DefaultTurbSpacing,TADistance,NTurbs);
    all_anchs = [1:num_anchs]';
    unstrengthened_anchs = all_anchs(~ismember(all_anchs, strengthened_anchs));

    % Rotate joint coordinates to match anchors
    theta = 0;
    R = [cosd(-theta-90) -sind(-theta-90);sind(-theta-90),cosd(-theta-90)]; %45 should be 90
    AA = [AnchorX,AnchorY];
    AA = AA*R;
    AnchorX = AA(:,1);
    AnchorY = AA(:,2);
    BB = [TurbX,TurbY];
    BB = BB*R;
    TurbX = BB(:,1);
    TurbY = BB(:,2);

    LineX = TurbX(LineConnect(:,1));
    LineX(:,2) = AnchorX(LineConnect(:,2));
    LineY = TurbY(LineConnect(:,1));
    LineY(:,2) = AnchorY(LineConnect(:,2));
    patch(LineX', LineY','k')
    P = zeros(1,length(LineX));
    
    % Draw mooring lines
    for i = 1:length(LineX)
        P(i) = plot([LineX(i,1), LineX(i,2)], [LineY(i,1), LineY(i,2)],'k','Tag',['Line',num2str(i)]);
    end

    % Draw turbines
    scatter(TurbX,TurbY,144,[0 0 0],'filled','MarkerEdgeColor','k','Marker','v');

    % Draw unstrengthened anchors
    scatter(AnchorX(unstrengthened_anchs),AnchorY(unstrengthened_anchs),144,[1 1 1],'filled','MarkerEdgeColor','k');
    
    % If ignoring OSFs, fill all strengthened anchors red
    if osf_increments == 0
        scatter(AnchorX(strengthened_anchs), AnchorY(strengthened_anchs), 144, [1 0 0], 'filled', 'MarkerEdgeColor', 'k')
        
    % If considering OSFs, fill all strengthened anchors shades of blue to
    % match with how high the OSF is.
    else
        dot_sizes = linspace(64, 512, length(osf_increments));
        cmap = colormap(hot);
        cmap = flipud(cmap(1:round(length(cmap)/length(osf_increments)):length(cmap),:));
        for j = 1:length(osf_increments) % 1:length(osf_increments)
            if ismember(single(osf_increments(j)), osfs)
                current_osf_idxs = find(osfs==single(osf_increments(j)));
                scatter(AnchorX(strengthened_anchs(current_osf_idxs)), AnchorY(strengthened_anchs(current_osf_idxs)),dot_sizes(j),cmap(j,:), 'filled', 'MarkerEdgeColor', 'k')
            end
        end
        % this loop is to get the legend to work correctly even if osfs
        % does not include all osf_increments
        for k = 1:length(osf_increments)
            H(k) = scatter(nan, nan, dot_sizes(k), cmap(k,:), 'filled', 'MarkerEdgeColor', 'k');
        end
        legend(H, split(num2str(osf_increments)), 'Location', 'southoutside', 'Orientation', 'horizontal')
    end
    
    axis equal
    axis off
    dcm_obj = datacursormode(F);
    set(dcm_obj,'UpdateFcn',{@FarmDataClick,AnchorX,AnchorY,TurbX,TurbY,LineConnect})

   print(pdf_filename, '-dpdf','-bestfit')
    
   clf
   close all;
    
end