function[A] = AnchorDemandFail(TurbFailState,Res,ANum,...
    R1,R2,R3,R4,R6,R7,R10,A)

% A = zeros(1,3);
if TurbFailState(1) == 0 && TurbFailState(2) == 0 && TurbFailState(3) == 0
    rn = randn(3,1); %generate 3 nomrally random numbers    
    if ANum == 1
        A(1) = exp(rn(1).*R1.A11(2) + R1.A11(1));
        A(2) = rn(2)*R1.A12(2) + R1.A12(1);
        A(3) = rn(3)*R1.A13(2) + R1.A13(1);
    elseif ANum == 2
        A(1) = rn(1)*R1.A21(2) + R1.A21(1);
        A(2) = exp(rn(2).*R1.A22(2) + R1.A22(1));
        A(3) = rn(3)*R1.A23(2) + R1.A23(1);
    elseif ANum == 3
        A(1) = rn(1)*R1.A31(2) + R1.A31(1);
        A(2) = rn(2)*R1.A32(2) + R1.A32(1);
        A(3) = exp(rn(3).*R1.A33(2) + R1.A33(1));
    end
elseif TurbFailState(1) == 1 && TurbFailState(2) == 0 && TurbFailState(3) == 0
    
    if ANum == 1
        A(1) = 0;
        A(2) = 0;
        A(3) = 0;
    elseif ANum == 2
        rn = randn(2,1);
        A(1) = 0;
        A(2) = exp(rn(1)*R2.A22(2)+R2.A22(1));
        A(3) = rn(2)*R2.A23(2)+R2.A23(1);
    elseif ANum == 3
        rn = randn(2,1);
        A(1) = 0;
        A(2) = rn(1)*R2.A32(2)+R2.A32(1);
        A(3) = exp(rn(2)*R2.A33(2)+R2.A33(1));
    end
elseif TurbFailState(1) == 0 && TurbFailState(2) == 1 && TurbFailState(3) == 0
    
    
    if ANum == 1
        rn = randn(2,1);
        A(1) = exp(rn(1)*R3.A11(2)+R3.A11(1));
        A(2) = 0;
        A(3) = rn(2)*R3.A13(2)+R3.A13(1);
    elseif ANum == 2
        rn = randn(2,1);
        A(1) = rn(1)*R3.A21(2)+R3.A21(1);
        A(2) = 0;
        A(3) = rn(2)*R3.A23(2)+R3.A23(1);
    elseif ANum == 3
        rn = randn(2,1);
        A(1) = rn(1)*R3.A31(2)+R3.A31(1);
        A(2) = 0;
        A(3) = rn(2)*R3.A33(2)+R3.A33(1);
    end
elseif TurbFailState(1) == 0 && TurbFailState(2) == 0 && TurbFailState(3) == 1
    
    if ANum == 1
        rn = randn(2,1);
        A(1) = exp(rn(1)*R4.A11(2)+R4.A11(1));
        A(2) = rn(2)*R4.A12(2)+R4.A12(1);
        A(3) = 0;
    elseif ANum == 2
        rn = randn(2,1);
        A(1) = rn(1)*R4.A21(2)+R4.A21(1);
        A(2) = exp(rn(2)*R4.A22(2)+R4.A22(1));
        A(3) = 0;
    elseif ANum == 3
        rn = randn(2,1);
        A(1) = rn(1)*R4.A31(2)+R4.A31(1);
        A(2) = rn(2)*R4.A32(2)+R4.A32(1);
        A(3) = 0;
    end
elseif TurbFailState(1) == 1 && TurbFailState(2) == 1 && TurbFailState(3) == 0
    if ANum == 1
        rn = randn(1,1);
        A(1) = 0;
        A(2) = 0;
        A(3) = rn*R6.A13(2)+R6.A13(1);
    elseif ANum == 2
        rn = randn(1,1);
        A(1) = 0;
        A(2) = 0;
        A(3) = rn*R6.A23(2)+R6.A23(1);
    elseif ANum == 3
        rn = randn(1,1);
        A(1) = 0;
        A(2) = 0;
        A(3) = exp(rn*R6.A33(2)+R6.A33(1));
    end
elseif TurbFailState(1) == 1 && TurbFailState(2)==0 && TurbFailState(3) == 1    
    if ANum == 1
        rn = randn(1,1);
        A(1) = 0;
        A(2) = rn*R7.A12(2)+R7.A12(1);
        A(3) = 0;
    elseif ANum == 2
        rn = randn(1,1);
        A(1) = 0;
        A(2) = exp(rn*R7.A22(2)+R7.A22(1));
        A(3) = 0;
    elseif ANum == 3
        rn = randn(1,1);
        A(1) = 0;
        A(2) = rn*R7.A32(2)+R7.A32(1);
        A(3) = 0;
    end
    
elseif TurbFailState(1) == 0 && TurbFailState(2) == 1 && TurbFailState(3) == 1
    if ANum == 1
        rn = randn(1,1);
        A(1) = exp(rn*R10.A11(2)+R10.A11(1));
        A(2) = 0;
        A(3) = 0;
    elseif ANum == 2
        rn = randn(1,1);
        A(1) = rn*R10.A21(2)+R10.A21(1);
        A(2) = 0;
        A(3) = 0;
    elseif ANum == 3
        rn = randn(1,1);
        A(1) = rn*R10.A31(2)+R10.A31(1);
        A(2) = 0;
        A(3) = 0;
    end
elseif TurbFailState(1) == 1 && TurbFailState(2) == 1 && TurbFailState(3) == 1
    A(1) = 0;
    A(2) = 0;
    A(3) = 0;
end