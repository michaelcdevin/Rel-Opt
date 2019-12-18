function r = lognrndFAST(mu,sigma,height,width)


r = exp(randn(height,width) .* sigma + mu);

6;
