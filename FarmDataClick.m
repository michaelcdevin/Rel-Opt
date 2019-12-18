function txt = FarmDataClick(empty,event_obj,AnchorX,AnchorY,TurbX,TurbY,LineConnect)
% Customizes text of data tips
pos = get(event_obj, 'Position');
I = get(event_obj, 'DataIndex');
txt = {['Anchor #: ',num2str(I)],...
    ['AnchorX: ',num2str(AnchorX(I))],...
    ['AnchorY: ',num2str(AnchorY(I))]};
end

