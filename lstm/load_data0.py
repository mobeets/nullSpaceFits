import numpy as np
import scipy.io
from keras.preprocessing import sequence

def make_design(d, y_name='latentsPca', nydims=None, maxvel=None):
    y = d[y_name][0,0]
    if nydims is not None:
        y = y[:,:nydims]

    x1 = d['trial_index'][0,0]
    # x1 = x1 - x1.min()
    x2 = d['time'][0,0]

    x3 = d['target'][0,0] # [n x 2]
    x3[:,0] = x3[:,0] - np.unique(x3[:,0]).mean()
    x3[:,1] = x3[:,1] - np.unique(x3[:,1]).mean()
    x3 = x3/x3.max()

    x4 = d['vel'][0,0] # n.b. latents[t-1] and vel[t-1] cause vel[t]
    if maxvel is not None:
        x4 = x4/maxvel
    else:
        x4 = x4/x4.max()

    x5 = np.deg2rad(d['thetas'][0,0])
    x5 = np.hstack([np.cos(x5), np.sin(x5)])
    
    # prepare latents[t-1]
    x6 = np.roll(y, 1, axis=0) # latents[t-1]
    tr_change = np.diff(x1[:,0]) > 0
    tr_change = np.hstack([[False], tr_change])
    x6[tr_change,:] = 0.0

    x7 = x2 > 5.0 # freeze period over

    x8 = d['pos'][0,0]
    x8 = x8/x8.max()

    xs = [x4, x2, x5, x6, x7]
    # xs = [x2, x5, x6, x7, x8]
    # xs = [x4, x2, x5, x6, x7, x8]
    return np.hstack(xs), y

def vec2deg(ts):
    tx = ts[:,0] - np.unique(ts[:,0]).mean()
    ty = ts[:,1] - np.unique(ts[:,1]).mean()
    return np.arctan2(ty, tx)*180/np.pi

def cv_split_by_trial_and_targ(X, y, d, tr_prop=0.9, seed=12345):
    """
    cross-validation split by trial;
        ensures the same proportion of trials per target are included
    """
    trs = d['trial_index'][0,0]
    trgs = vec2deg(d['target'][0,0])[:,None] # target is now an angle
    rnd = np.random.RandomState(seed) # reproducible split

    tr_trs = [] # trials in training set
    for trg in np.unique(trgs):
        ix = trgs == trg
        ctrs = np.unique(trs[ix]) # find all trials for this target
        rnd.shuffle(ctrs)
        ntr = int(np.round(len(ctrs)*tr_prop))
        tr_trs.extend(ctrs[:ntr])
    tr_mask = np.in1d(trs, tr_trs) # mask for training trials
    return X[tr_mask], y[tr_mask], trs[tr_mask], X[~tr_mask], y[~tr_mask], trs[~tr_mask]

def make_trial_sequences(X, y, trs, maxlen=None):
    Xs = []
    ys = []
    for tr in np.unique(trs):
        ix = (trs == tr)[:,0]
        Xs.append(X[ix])
        ys.append(y[ix])
    Xs = sequence.pad_sequences(Xs, maxlen=maxlen, padding='post', truncating='post', dtype='float32')
    ys = sequence.pad_sequences(ys, maxlen=maxlen, padding='post', truncating='post', dtype='float32')
    return Xs, ys

def prepare_for_batch_size(X, y, batch_size):
    if batch_size is not None:
        n = batch_size*(len(X)/batch_size)
    else:
        n = len(X)
    return X[:n], y[:n]

def load(infile='data/input/20131205.mat', seq_by_trial=True, maxlen=None,
    do_cv_split=False, batch_size=None):
    """
    infile is a mat containg a struct called 'G'
        e.g., G = F.test in nullSpaceFits
    """
    d = scipy.io.loadmat(infile)['G']
    if 'train' in d.dtype.names:
        # e.g., train is intuitive, test is perturbation
        maxvel1 = d['train'][0,0]['vel'][0,0].max()
        maxvel2 = d['test'][0,0]['vel'][0,0].max()
        maxvel = max([maxvel1, maxvel2])
        Xtr, ytr = make_design(d['train'][0,0], maxvel=maxvel)
        Xte, yte = make_design(d['test'][0,0], maxvel=maxvel)
        if do_cv_split:
            print "WARNING: train and test already in data! Keeping this."
        ttr = d['train'][0,0]['trial_index'][0,0]
        tte = d['test'][0,0]['trial_index'][0,0]
        if maxlen is None:
            maxlen = np.bincount(d['train'][0,0]['time'][0,0]).max()
        Xtr, ytr = make_trial_sequences(Xtr, ytr, ttr, maxlen)
        Xte, yte = make_trial_sequences(Xte, yte, tte, maxlen)
        Xtr, ytr = prepare_for_batch_size(Xtr, ytr, batch_size)
        Xte, yte = prepare_for_batch_size(Xte, yte, batch_size)
        return Xtr, ytr, Xte, yte
    else:
        # just one block present in data, e.g., intuitive
        X, y = make_design(d)
    if do_cv_split:
        Xtr, ytr, ttr, Xte, yte, tte = cv_split_by_trial_and_targ(X, y, d)
        if seq_by_trial:
            if maxlen is None:
                maxlen = np.bincount(d['trial_index'][0,0][:,0]).max()
            Xtr, ytr = make_trial_sequences(Xtr, ytr, ttr, maxlen)
            Xte, yte = make_trial_sequences(Xte, yte, tte, maxlen)
        Xtr, ytr = prepare_for_batch_size(Xtr, ytr, batch_size)
        Xte, yte = prepare_for_batch_size(Xte, yte, batch_size)
        return Xtr, ytr, Xte, yte
    else:
        if seq_by_trial:
            trs = d['trial_index'][0,0]
            X, y = make_trial_sequences(X, y, trs)
        X, y = prepare_for_batch_size(X, y, batch_size)
        return X, y

if __name__ == '__main__':
    Xtr, ytr, Xte, yte = load('data/input/20131205-both.mat')
    1/0
