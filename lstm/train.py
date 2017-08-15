from __future__ import print_function
import os.path
import json
import numpy as np
import argparse
from keras.callbacks import Callback, EarlyStopping, ModelCheckpoint
from sklearn.metrics import r2_score
from load_data import load
from model import get_model, load_model
from vis import plot_examples

class GetScores(Callback):
    def __init__(self, Xtr, ytr, Xte, yte, gtr, gte, batch_size):
        super(GetScores, self).__init__()
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
        tun_tr_err = np.square(self.tun_tr - tun_trh).sum()
        tun_te_err = np.square(self.tun_te - tun_teh).sum()
        rsq_tr = get_rsqs(self.ytr, yhat_tr)
        rsq_te = get_rsqs(self.yte, yhat_te)
        print('============')
        print('Tuning err: train={}, test={}'.format(tun_tr_err, tun_te_err))
        print('Rsq: train={}, test={}'.format(rsq_tr, rsq_tr))

def get_callbacks(args):
    json_file = os.path.join(args.model_dir, args.run_name + '.json')
    mdl_file = os.path.join(args.model_dir, args.run_name + '.h5')
    json.dump(vars(args), open(json_file, 'w'))
    early_stopping = EarlyStopping(monitor='val_loss', patience=2)
    checkpt = ModelCheckpoint(mdl_file, monitor='val_loss',
        save_weights_only=True, save_best_only=True)    
    return [early_stopping, checkpt]

def get_rsqs(y, yhat):
    return np.array([r2_score(y[i], yhat[i], multioutput='raw_values') for i in xrange(len(y))]).mean(axis=0)

def get_tuning(y, gs, ignore_group=-1):
    grps = np.unique(gs)
    grps = grps[grps != ignore_group] # ignore dummy group
    vs = np.zeros(len(grps))
    for i in xrange(len(grps)):
        idx = (gs == grps[i])[:,:,0]
        vs[i] = np.mean(y[idx])
    return vs/vs.sum()

def print_scores(mdl, Xtr, ytr, Xte, yte, gtr, gte, args):
    score = mdl.evaluate(Xte, yte, batch_size=args.batch_size)
    yhat_tr = mdl.predict(Xtr, batch_size=args.batch_size)
    yhat_te = mdl.predict(Xte, batch_size=args.batch_size)
    rsq_te = get_rsqs(yte, yhat_te)
    rsq_tr = get_rsqs(ytr, yhat_tr)
    tun_tr = get_tuning(ytr, gtr)
    tun_trh = get_tuning(yhat_tr, gtr)
    tun_tr_err = np.square(tun_tr - tun_trh).sum()
    tun_te = get_tuning(yte, gte)
    tun_teh = get_tuning(yhat_te, gte)
    tun_te_err = np.square(tun_te - tun_teh).sum()
    print('============')
    print('Train tuning pred={}'.format(tun_tr))
    print('Train tuning act={}'.format(tun_trh))
    print('Train tuning err={}'.format(tun_tr_err))
    print('============')
    print('Test tuning pred={}'.format(tun_te))
    print('Test tuning act={}'.format(tun_teh))
    print('Test tuning err={}'.format(tun_te_err))
    print('============')
    print('Train rsq={}'.format(rsq_tr))
    print('Test rsq={}'.format(rsq_te))
    print('Test score={}'.format(score))

def main(args):
    """
    0.841: latents[t-1] only
    0.765: +thetas
    1.938: +thetas+vel (wtf)
    0.817: +thetas+targ (but hit max # epochs)
    0.734: +thetas+time
    0.744: +thetas+time+vel
    """
    Xtr, ytr, Xte, yte, gtr, gte = load(args.train_file,
        kind=args.kind, do_cv_split=True,
        maxlen=args.max_len, batch_size=args.batch_size)
    print(Xtr.shape, ytr.shape, Xte.shape, yte.shape)
    args.input_dim = Xtr.shape[-1]
    args.output_dim = ytr.shape[-1]
    args.seq_length = ytr.shape[-2]
    mdl = get_model(args.batch_size, args.input_dim, args.output_dim,
        args.seq_length, args.optimizer)
    if args.model_file is not None:
        mdl.load_weights(args.model_file)
    
    if args.num_epochs > 0:
        print('Training...')
        callbacks = get_callbacks(args)
        scs = GetScores(Xtr, ytr, Xte, yte, gtr, gte, args.batch_size)
        callbacks.append(scs)
        mdl.fit(Xtr, ytr,
            batch_size=args.batch_size,
            epochs=args.num_epochs,
            callbacks=callbacks,
            validation_data=(Xte, yte))
    print_scores(mdl, Xtr, ytr, Xte, yte, gtr, gte, args)
    if args.do_plot:
        yhat_tr = mdl.predict(Xtr, batch_size=args.batch_size)
        yhat_te = mdl.predict(Xte, batch_size=args.batch_size)
        plot_examples(yte, yhat_te, outdir=args.plot_dir,
            prefix=args.run_name + '_test', n=20)
        plot_examples(ytr, yhat_tr, outdir=args.plot_dir,
            prefix=args.run_name + '_train', n=10)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('run_name', type=str, help='tag for current run')
    parser.add_argument('--model_file', type=str,
                default=None, help='model file to load weights')
    parser.add_argument('--train_file', type=str,
                default='data/input/20131205.mat',
                help='data for training/testing (.mat)')
    parser.add_argument('--optimizer', type=str,
                default='adam', help='optimizer for training')
    parser.add_argument('--kind', type=str, required=True,
                choices=['potent', 'null'], help='predict null or potent')
    parser.add_argument('--num_epochs', type=int,
                default=200, help='number of epochs of training')
    parser.add_argument('--max_len', type=int,
                default=25, help='maximum trial length')
    parser.add_argument('--batch_size', type=int,
                default=10, help='batch size for training')
    parser.add_argument("--do_plot", action="store_true", 
                help="plot examples")
    parser.add_argument('--model_dir', type=str,
                default='data/models',
                help='basedir for saving model weights')
    parser.add_argument('--plot_dir', type=str,
                default='data/plots', help='basedir for saving figures')
    args = parser.parse_args()
    main(args)
