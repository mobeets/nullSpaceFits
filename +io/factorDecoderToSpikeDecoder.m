function dn = factorDecoderToSpikeDecoder(df, dec)

    [~,beta] = tools.convertRawSpikesToRawLatents(dec, 0, false);
    mu = dec.spikeCountMean;
    dn.M2 = df.M2*beta;
    dn.M1 = df.M1;
    dn.M0 = df.M0 - df.M2*beta*mu';

end
