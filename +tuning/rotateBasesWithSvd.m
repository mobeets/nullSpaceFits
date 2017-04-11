function NB = rotateBasesWithSvd(NB, Y)
    [~,~,v] = svd(Y(~any(isnan(Y),2),:)*NB, 'econ');
    NB = NB*v;
end
