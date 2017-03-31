function df = spikeDecoderToFactorDecoder(dn, dec)
% dn = spike decoder
% returns df, the factor decoder
% n.b. we just need simpleDataDecoder for the factor analysis params
% 

    [~,beta] = tools.convertRawSpikesToRawLatents(dec, 0, false);
    mu = dec.spikeCountMean;
        
    df.M2 = dn.M2/beta;
    df.M1 = dn.M1;
    df.M0 = dn.M0 + dn.M2*mu';
    
end
