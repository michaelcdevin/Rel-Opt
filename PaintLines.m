function[] = PaintLines(TurbX,TurbY,AnchorX,AnchorY,LineFail,LineConnect,AnchorFail,TurbFail,TurbAnchConnect)

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
% coords = [JointInfo(:,2),JointInfo(:,3)];
% CoordsR = coords*R;
% JointInfo(:,2:3) = CoordsR;

LF = sum(LineFail,2);
LF(LF>1) = 1;
LineX = TurbX(LineConnect(:,1));
LineX(:,2) = AnchorX(LineConnect(:,2));
LineY = TurbY(LineConnect(:,1));
LineY(:,2) = AnchorY(LineConnect(:,2));
x1 = LineX(LF==1,:);
y1 = LineY(LF==1,:);
x2 = LineX(LF==0,:);
y2 = LineY(LF==0,:);
patch(x1',y1','r:','EdgeColor','r','LineStyle',':') %comment out to have base
patch(x2',y2','k') %comment out to have base
P = zeros(1,length(x2));
for i = 1:length(x2)
    P(i) = plot([x2(i,1),x2(i,2)],[y2(i,1),y2(i,2)],'k','Tag',['Line',num2str(i)]);
end

x1 = TurbX(TurbFail==0);
y1 = TurbY(TurbFail==0);
x2 = TurbX(TurbFail==1);
y2 = TurbY(TurbFail==1);
scatter(x1,y1,36,0.5*[1 1 1],'filled','MarkerEdgeColor','k','Marker','v');
scatter(x2,y2,36,[1 0 0],'filled','MarkerEdgeColor','k','Marker','v'); %comment out to have base

x1 = AnchorX(AnchorFail==0);
y1 = AnchorY(AnchorFail==0);
x2 = AnchorX(AnchorFail==1);
y2 = AnchorY(AnchorFail==1);
scatter(x1,y1,36,0.5*[1 1 1],'filled','MarkerEdgeColor','k');
scatter(x2,y2,36,[1 0 0],'filled','MarkerEdgeColor','k'); %comment out to have base

axis equal
axis off
dcm_obj = datacursormode(F);
set(dcm_obj,'UpdateFcn',{@FarmDataClick,AnchorX,AnchorY,TurbX,TurbY,LineConnect})


6;