function[Res] = LineStdev(Res,SegNum)


for i = 1:length(Res)
    if ~isempty(Res(i).LP1)
        Res(i).L1stdev = mean(Res(i).LP1(SegNum,2));
        Res(i).L2stdev = mean(Res(i).LP2(SegNum,2));
        Res(i).L3stdev = mean(Res(i).LP3(SegNum,2));
    end
end
