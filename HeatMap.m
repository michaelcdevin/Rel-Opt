function[] = HeatMap(TurbX,TurbY,AnchorX,AnchorY,LineConnect,timesStrengthened)
close all
F = figure;
hold all


% Rotate joint coordinates to match anchors
theta = 0;
R = [cosd(-theta-90) -sind(-theta-90);sind(-theta-90),cosd(-theta-90)];
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
for i = 1:length(LineX)
    plot([LineX(i,1),LineX(i,2)],[LineY(i,1),LineY(i,2)],'k','Tag',['Line',num2str(i)]);
end

scatter(TurbX,TurbY,36,'filled','MarkerEdgeColor','k','Marker','v');
scatter(AnchorX,AnchorY,100,timesStrengthened,'filled');

colormap(jet);
colorbar;

axis equal
axis off
dcm_obj = datacursormode(F);
set(dcm_obj,'UpdateFcn',{@FarmDataClick,AnchorX,AnchorY,TurbX,TurbY,LineConnect})


6;