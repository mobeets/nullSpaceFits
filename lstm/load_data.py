import numpy as np
import scipy.io
import pandas as pd
from keras.preprocessing import sequence

def get_column(d, keys):
    if isinstance(keys, basestring): # is str
        keys = [keys]
    e = d
    for k in keys:
        e = e[k][0,0]
    return e

def get_column_lag1(d, key, ixSetToZero):
    x = get_column(d, [key])
    x = np.roll(x, 1, axis=0) # x[t-1]
    x[ixSetToZero,:] = 0.0
    return x

def make_design(d, kind='joint', skip_freeze_period=False):
    """
    LSTM-potent: Y^r(t) = f( Y^n(<t), Y^r(<t), X(<=t), H(t) )
    LSTM-null: Y^n(t) = f( Y^n(<t), Y^r(<=t), X(<=t) )
    """
    if kind == 'both':
        yr = get_column(d, 'Yr')
        yn = get_column(d, 'Yn')
        y = np.hstack([yr, yn])
    elif kind == 'potent':
        y = get_column(d, 'Yr')
    elif kind == 'null':
        y = get_column(d, 'Yn')[:,:2]
    else:
        assert False
    X1 = get_column(d, 'trial_index')
    X2 = get_column(d, 'time')
    gs = get_column(d, 'gs')
    
    tr_change = np.diff(X1[:,0]) > 0
    tr_change = np.hstack([[False], tr_change])

    X3 = get_column_lag1(d, 'Yn', tr_change)
    X4 = get_column_lag1(d, 'Yr', tr_change)
    X5 = get_column(d, 'Yr_goal')
    X6 = get_column(d, 'Yn_goal')
    thsx = np.cos(np.deg2rad(get_column(d, 'thetas')))
    thsy = np.sin(np.deg2rad(get_column(d, 'thetas')))

    ixFreeze = (X2 > 5.0)[:,0] # non-freeze period
    X5[ixFreeze] = 0.0
    X6[ixFreeze] = 0.0

    if kind == 'null':
        X4c = get_column(d, 'Yr')
        xss = [X3, X4, X4c, X5, thsx, thsy] # null goes first
    else:
        xss = [X4, X3, X5, thsx, thsy]
    # X = np.hstack([X3, X4, X5])
    X = np.hstack(xss)

    ix = ~(np.isnan(y).any(axis=1) | np.isnan(X).any(axis=1))
    if skip_freeze_period:
        ix = ix & ixFreeze
    X = X[ix]
    y = y[ix]
    X1 = X1[ix]
    X2 = X2[ix]
    gs = gs[ix]
    return X, y, X1, gs, X2

def make_trial_sequences(vals, trs, maxlen=None):
    vs = []
    for i in xrange(len(vals)):
        vs.append([])
    for tr in np.unique(trs):
        ix = (trs == tr)[:,0]
        for i in xrange(len(vs)):
            vs[i].append(vals[i][ix])
    for i in xrange(len(vs)):
        vs[i] = sequence.pad_sequences(vs[i], maxlen=maxlen,
            padding='post', truncating='post', dtype='float32')
    return vs

def prepare_for_batch_size(vals, batch_size):
    if batch_size is not None:
        n = batch_size*(len(vals[0])/batch_size)
    else:
        n = len(vals[0])
    return [v[:n] for v in vals]

def load(infile='data/input/20131205-goals.mat', kind='null', 
        seq_by_trial=True, maxlen=None, do_cv_split=False, batch_size=None):
    d = scipy.io.loadmat(infile)['G']
    assert 'train' in d.dtype.names

    Xtr, ytr, ttr, gtr, tmstr = make_design(get_column(d, 'train'), kind)
    Xte, yte, tte, gte, tmste = make_design(get_column(d, 'test'), kind)

    if maxlen is None:
        maxlen = np.bincount(get_column(d, ['train', 'time'])).max()
    Xtr, ytr, gtr, tmstr = make_trial_sequences([Xtr, ytr, gtr, tmstr], ttr, maxlen)
    ttr = np.unique(ttr)
    Xte, yte, gte, tmste = make_trial_sequences([Xte, yte, gte, tmste], tte, maxlen)
    tte = np.unique(tte)
    Xtr, ytr, gtr, ttr, tmstr = prepare_for_batch_size([Xtr, ytr, gtr, ttr, tmstr], batch_size)
    Xte, yte, gte, tte, tmste = prepare_for_batch_size([Xte, yte, gte, tte, tmste], batch_size)
    return Xtr, ytr, Xte, yte, gtr, gte, ttr, tte, tmstr, tmste

def make_df(d, main_key='time', ignores=['spikes', 'latents']):
    x = {}
    for k in d.dtype.names:
        v = d[k][0,0]
        if k in ignores:
            continue
        if v.shape[0] != d[main_key][0,0].shape[0]:
            continue
        if len(v.shape) == 1:
            x[k] = v
            continue
        for i in xrange(v.shape[-1]):
            ck = k + '_{}'.format(i) if v.shape[-1] > 1 else k
            x[ck] = v[:,i]
    return pd.DataFrame(x)

def load_dfs(fnm):
    d = scipy.io.loadmat(fnm)['G']
    dfs = dict((k, make_df(d[k][0,0])) for k in d.dtype.names)
    return dfs

if __name__ == '__main__':
    fnm = 'data/input/20131205-goals.mat'
    dfs = load_dfs(fnm)
    1/0
    Xtr, ytr, Xte, yte = load(fnm)
