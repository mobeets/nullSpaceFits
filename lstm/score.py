import numpy as np
from sklearn.metrics import r2_score
from keras.callbacks import Callback

def get_rsqs(y, yhat):
    if np.isnan(yhat).any():
        return np.nan
    # might compute this after combining over trials??
    # or ignoring zero-filled timesteps?
    return np.nanmean(np.array([r2_score(y[i], yhat[i], multioutput='raw_values') if ~np.isnan(yhat[i]).any() else np.nan for i in xrange(len(y))]), axis=0)

get_tuning_error = lambda x,y: np.square(x-y).sum(axis=0)

def get_tuning(y, gs, ignore_group=-1):
    grps = np.unique(gs)
    grps = grps[grps != ignore_group] # ignore dummy group
    vs = np.zeros((len(grps), y.shape[-1]))
    for i in xrange(len(grps)):
        idx = (gs == grps[i])[:,:,0]
        vs[i] = np.nanmean(y[idx], axis=0)
    return vs#/vs.sum()

class ScoreCallback(Callback):
    def __init__(self, Xtr, ytr, Xte, yte, gtr, gte, batch_size):
        super(ScoreCallback, self).__init__()
        self.Xtr = Xtr
        self.ytr = ytr
        self.Xte = Xte
        self.yte = yte
        self.gtr = gtr
        self.gte = gte
        self.batch_size = batch_size
        self.tun_tr = get_tuning(ytr, gtr)
        self.tun_te = get_tuning(yte, gte)

    def on_epoch_end(self, epoch, logs={}):
        yhat_tr = self.model.predict(self.Xtr, self.batch_size)
        yhat_te = self.model.predict(self.Xte, self.batch_size)
        tun_trh = get_tuning(yhat_tr, self.gtr)
        tun_teh = get_tuning(yhat_te, self.gte)
        tun_tr_err = get_tuning_error(self.tun_tr, tun_trh)
        tun_te_err = get_tuning_error(self.tun_te, tun_teh)
        rsq_tr = get_rsqs(self.ytr, yhat_tr)
        rsq_te = get_rsqs(self.yte, yhat_te)
        print('============')
        print('Tuning err: train={}, test={}'.format(tun_tr_err, tun_te_err))
        print('Rsq: train={}, test={}'.format(rsq_tr, rsq_tr))

class DummyModel:
    """
    just returns y[t-1] as prediction for y[t]
    """
    def __init__(self, inds):
        self.inds = inds

    def predict(self, X, batch_size=None):
        return X[:,:,self.inds]

    def evaluate(self, X, y, batch_size=None):
        yhat = self.predict(X)
        return np.mean(np.square(yhat - y), axis=-1).mean()

class FairModel:
    """
    returns sequential prediction
    """
    def __init__(self, model, inds, times, last_freeze=5, nsteps=4):
        self.model = model
        self.y_hist_inds = inds
        self.times = times
        self.last_freeze = last_freeze
        self.nsteps = nsteps

    def predict(self, X, batch_size=None):
        return predict_sequential(self.model, X, self.y_hist_inds,
            self.times, last_freeze=self.last_freeze, nsteps=self.nsteps)

    def evaluate(self, X, y, batch_size=None):
        yhat = self.predict(X)
        idx = ~np.isnan(yhat).any(axis=-1)
        return np.mean(np.square(yhat[idx] - y[idx]), axis=-1).mean()

def predict_sequential(model, X, y_hist_inds, times, last_freeze=5, nsteps=5):
    """
    want to predict y for each trial sequentially,
        so that we can use the activity up until the freeze period,
        and then we continue predicting using each prediction

    assumes X.shape == [len(trials), len(times), nd]

    n.b. model should be stateful, and have batch_size=1, seq_length=1
    """
    yhat = np.nan*np.zeros((X.shape[0], X.shape[1], len(y_hist_inds)))
    trials = np.arange(X.shape[0])
    for tr in trials:
        tr_idx = (trials == tr)
        tms = times[tr_idx].flatten()
        # ignore 0 time step (filler)
        atms = tms[(tms > 0) & (tms <= last_freeze+nsteps)]
        # times should be sorted and sequential, and include t=1
        assert atms.min() < last_freeze
        assert (np.unique(np.diff(atms)) == 1).all()
        yprev = None
        model.reset_states()
        for tm in atms:
            tm_idx = tms == tm
            Xc = X[tr_idx, tm_idx]
            if tm > last_freeze:
                Xc[:,y_hist_inds] = yprev # y predicted last time step
            yc = model.predict(Xc[None,:], batch_size=1)
            yhat[tr_idx, tm_idx] = yc
            yprev = yc
    return yhat

def get_scores(mdl, X, y, g, batch_size):
    score = mdl.evaluate(X, y, batch_size=batch_size)
    yhat = mdl.predict(X, batch_size=batch_size)    
    rsq = get_rsqs(y, yhat)
    tun = get_tuning(y, g)
    tunh = get_tuning(yhat, g)
    tun_err = get_tuning_error(tun, tunh)
    return score, rsq, tun_err, tun, tunh

def print_scores(mdl, Xtr, ytr, Xte, yte, gtr, gte, tmtr, tmte, batch_size, bmdl=None):    

    score_tr, rsq_tr, tun_tr_err, tun_tr, tun_trh = get_scores(mdl, Xtr, ytr, gtr, batch_size)
    score_te, rsq_te, tun_te_err, tun_te, tun_teh = get_scores(mdl, Xte, yte, gte, batch_size)

    dmdl = DummyModel(np.arange(yte.shape[-1])) # returns yte[t-1]
    score_dm, rsq_dm, tun_err1, tun1, tun1h = get_scores(dmdl, Xte, yte, gte, batch_size)

    print('============')
    print('Train tuning act={}'.format(tun_tr))
    print('Train tuning pred={}'.format(tun_trh))
    print('Train tuning err={}'.format(tun_tr_err))
    print('============')
    print('Test tuning act={}'.format(tun_te))
    print('Test tuning pred={}'.format(tun_teh))
    print('Test tuning err={}'.format(tun_te_err))

    print('Dummy tuning pred={}'.format(tun1h))
    print('Dummy tuning err={}'.format(tun_err1))
    if bmdl is not None:
        fmdl = FairModel(bmdl, range(yte.shape[-1]), tmte) # returns yte[t-1]
        score_fm,rsq_fm, tun_err2, tun2, tun2h = get_scores(fmdl, Xte, yte, gte, batch_size)
        print('Fair tuning pred={}'.format(tun2h))
        print('Fair tuning err={}'.format(tun_err2))
    else:
        tun2h = 0*tun1h

    print('============')
    print('Train rsq={}'.format(rsq_tr))
    print('Test rsq={}'.format(rsq_te))
    print('Dummy rsq={}'.format(rsq_dm))
    print('Test score={}'.format(score_te))
    print('Dummy score={}'.format(score_dm))

    return tun_te, tun_teh, tun1h, tun2h
