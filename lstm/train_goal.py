from __future__ import print_function
import os.path
import json
import argparse
import scipy.io
import numpy as np
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras.layers import Input, Dense, concatenate
from keras.models import Model
import keras.backend as K
from vae_model import get_model, make_encoder, make_decoder

def prepare_for_batch_size(vals, batch_size):
    if batch_size is not None:
        n = batch_size*(len(vals[0])/batch_size)
    else:
        n = len(vals[0])
    return [v[:n] for v in vals]

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

def get_vel_fcn(d):
    # M0 = get_column(get_column(d, 'dec'), 'M0')
    # M1 = get_column(get_column(d, 'dec'), 'M1')
    # M2 = get_column(get_column(d, 'dec'), 'M2')
    M0 = get_column(get_column(d, 'dec'), 'M0new')
    M2 = get_column(get_column(d, 'dec'), 'M2new')
    return lambda Z: (M2.dot(Z) + M0).T

def make_design(d):
    trials = get_column(d, 'index') # == (maxTime+1)*trial_index + time
    is_trial_change = np.diff(trials[:,0]) > 1
    is_trial_change = np.hstack([[False], is_trial_change])

    # yn = get_column(d, 'Yn')
    # yr = get_column(d, 'Yr')
    # y = np.hstack([yn, yr])
    # Xr = get_column_lag1(d, 'Yn', is_trial_change)
    # Xn = get_column_lag1(d, 'Yr', is_trial_change)
    # X = np.hstack([Xn, Xr])
    y = get_column(d, 'latents')
    X = get_column_lag1(d, 'latents', is_trial_change)

    vel = get_column_lag1(d, 'vel', is_trial_change)
    ths = np.deg2rad(get_column(d, 'thetas'))
    ths = np.hstack([np.cos(ths), np.sin(ths)])
    # G = np.hstack([vel, ths])
    G = ths
    # Trgs = get_column(d, 'target')
    Trgs = get_column(d, 'thetaGrps')

    ix = ~(np.isnan(y).any(axis=1) | np.isnan(G).any(axis=1) | np.isnan(X).any(axis=1))
    return X[ix], G[ix], y[ix], Trgs[ix]

def load(train_file, batch_size=None, use_x_prev=False):
    d = scipy.io.loadmat(train_file)['G']
    assert 'train' in d.dtype.names

    Xtr, Gtr, ytr, Trgtr = make_design(get_column(d, 'train'))
    Xte, Gte, yte, Trgte = make_design(get_column(d, 'test'))
    Xtr, Gtr, ytr, Trgtr = prepare_for_batch_size([Xtr, Gtr, ytr, Trgtr], batch_size)
    Xte, Gte, yte, Trgte = prepare_for_batch_size([Xte, Gte, yte, Trgte], batch_size)
    # return [Xtr, Gtr], ytr, [Xte, Gte], yte
    if use_x_prev:
        # return [ytr, Xtr], ytr, [yte, Xte], yte, Trgtr, Trgte, get_vel_fcn(d)
        return [ytr, Gtr], ytr, [yte, Gte], yte, Trgtr, Trgte, get_vel_fcn(d)
    else:
        return ytr, ytr, yte, yte, Trgtr, Trgte, get_vel_fcn(d)

def get_model0(batch_size, input_dim_z, input_dim_g, intermediate_dim_x, intermediate_dim_g, intermediate_dim_z, optimizer):
    """
    P(z_t | z_{t-1}) = N(mu_z, sigma_z)
    P(z_t | g_t) = N(mu_g, sigma_g)
    """
    Z_prev = Input(batch_shape=(batch_size, input_dim_z), name='Z_prev')
    G = Input(batch_shape=(batch_size, input_dim_g), name='G')

    # P(z_t | z_{t-1}) = N(mu_z, sigma_z)
    zp = Dense(intermediate_dim_x, activation='relu', name='zp')(Z_prev)
    zp_mean = Dense(input_dim_z, name='zp_mean')(zp)
    # zp_log_var = Dense(input_dim_z, name='zp_log_var')(zp)
    # now sample zp ~ N(zp_mean, exp(zp_log_var))

    # P(z_t | g_t) = N(mu_g, sigma_g)
    g = Dense(intermediate_dim_g, activation='relu', name='g')(G)
    zg_mean = Dense(input_dim_z, name='zg_mean')(g)
    # zg_log_var = Dense(input_dim_z, name='zg_log_var')(g)
    # now sample zg ~ N(zg_mean, exp(zg_log_var))

    zpzg = concatenate([zp_mean, zg_mean], axis=-1)
    z_inter = Dense(intermediate_dim_z, activation='relu', name='z_inter')(zpzg)
    z_hat = Dense(input_dim_z, activation='relu', name='z_hat')(z_inter)

    model = Model([Z_prev, G], z_hat)
    model.compile(optimizer=optimizer, loss='mse')
    return model

def get_callbacks(args):
    json_file = os.path.join(args.model_dir, args.run_name + '.json')
    mdl_file = os.path.join(args.model_dir, args.run_name + '.h5')
    json.dump(vars(args), open(json_file, 'w'))
    early_stopping = EarlyStopping(monitor='val_loss', patience=args.patience)
    checkpt = ModelCheckpoint(mdl_file, monitor='val_loss',
        save_weights_only=True, save_best_only=True)    
    return [early_stopping, checkpt]

from matplotlib import cm
import matplotlib.pyplot as plt
from scipy.spatial import ConvexHull
def vis_encoding(Pts, enc_model, fnm=None, args=None, markersize=6, tickfontsize=20, fontsize=40, vmn=-10, vmx=10):

    fig = plt.figure(figsize=(5, 5), facecolor='white')
    ax = fig.add_subplot(111)
    cmap = cm.get_cmap('RdYlGn')

    mkrs = ['o', 's']
    lns = ['-', '--']
    lnclrs = ['b', 'r']
    for j, (X, Trgs) in enumerate(Pts):
        if len(X) == 2:
            z_mean, z_log_var = enc_model.predict(X[0], batch_size=1)
        else:
            z_mean, z_log_var = enc_model.predict(X, batch_size=1)

        trgs = np.unique(Trgs)
        pts = np.zeros((len(trgs), z_mean.shape[-1]))
        for i,trg in enumerate(trgs):
            ix = (Trgs.flatten() == trg)
            clr = cmap(i*1.0/len(trgs))
            plt.plot(np.mean(z_mean[ix, 0]), np.mean(z_mean[ix, 1]), mkrs[j],
                color=clr, markeredgewidth=0.0, markersize=markersize)
            pts[i,:] = np.mean(z_mean[ix,:], axis=0) 
            # points = z_mean[ix,:]
            # if len(points) <= 2:
            #     continue
            # hull = ConvexHull(points)
            # for simplex in hull.simplices:
            #     plt.plot(points[simplex, 0], points[simplex, 1], lns[j], color=clr)
        pts = np.vstack([pts, pts[0,:]])
        plt.plot(pts[:,0], pts[:,1], '-', color=lnclrs[j])
        if j == 0:
            plt.plot(z_mean[:,0], z_mean[:,1], 'k.', markersize=1)
    # plt.xlim([vmn, vmx])
    # plt.ylim([vmn, vmx])
    # ax.set_xticks([vmn/2., 0, vmx/2.], minor=False)
    # ax.set_yticks([vmn/2., 0, vmx/2.], minor=False)
    plt.xticks(fontsize=tickfontsize)
    plt.yticks(fontsize=tickfontsize)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.set_xlabel('$z_1$', fontsize=fontsize)
    ax.set_ylabel('$z_2$', fontsize=fontsize)
    if args is None:
        plt.show()
    else:
        fig.set_size_inches(9, 9)
        fig.savefig(os.path.join(args.sample_dir, args.run_name + '_' + fnm))

def vis_decoding(Pts, enc_model, dec_model, vfcn, fnm=None, args=None, markersize=6, tickfontsize=20, fontsize=40, vmn=-500, vmx=500):

    fig = plt.figure(figsize=(5, 5), facecolor='white')
    ax = fig.add_subplot(111)
    cmap = cm.get_cmap('RdYlGn')

    mkrs = ['o', 's']
    lnclrs = ['b', 'r']
    # lns = ['-', '--']
    for j, (X, Trgs) in enumerate(Pts):
        if len(X) == 2:
            z_mean, z_log_var = enc_model.predict(X[0], batch_size=1)
            x_mean = dec_model.predict([z_mean, X[1]], batch_size=1)
            vs = vfcn(X[0].T)
        else:
            z_mean, z_log_var = enc_model.predict(X, batch_size=1)
            x_mean = dec_model.predict(z_mean, batch_size=1)
            vs = vfcn(X.T)
        vs_hat = vfcn(x_mean.T)
        
        trgs = np.unique(Trgs)
        ptsA = np.zeros((len(trgs), 2))
        ptsB = np.zeros((len(trgs), 2))
        for i,trg in enumerate(trgs):
            ix = (Trgs.flatten() == trg)
            clr = cmap(i*1.0/len(trgs))
            plt.plot(np.mean(vs[ix, 0]), np.mean(vs[ix, 1]), mkrs[j],
                color=clr, markeredgewidth=0.0, markersize=markersize)
            plt.plot(np.mean(vs_hat[ix, 0]), np.mean(vs_hat[ix, 1]), '.',
                color=clr, markeredgewidth=0.0, markersize=markersize)
            ptsA[i,:] = np.mean(vs[ix,:], axis=0)
            ptsB[i,:] = np.mean(vs_hat[ix,:], axis=0)
            # points = z_mean[ix,:]
            # hull = ConvexHull(points)
            # for simplex in hull.simplices:
            #     plt.plot(points[simplex, 0], points[simplex, 1], '-', color=clr)
        ptsA = np.vstack([ptsA, ptsA[0,:]])
        ptsB = np.vstack([ptsB, ptsB[0,:]])
        plt.plot(ptsA[:,0], ptsA[:,1], '-', color=lnclrs[j])
        plt.plot(ptsB[:,0], ptsB[:,1], '--', color=lnclrs[j])
        if j > 0:
            plt.plot(vs[:,0], vs[:,1], 'k.', markersize=1)
    # plt.xlim([vmn, vmx])
    # plt.ylim([vmn, vmx])
    # ax.set_xticks([vmn/2., 0, vmx/2.], minor=False)
    # ax.set_yticks([vmn/2., 0, vmx/2.], minor=False)
    plt.xticks(fontsize=tickfontsize)
    plt.yticks(fontsize=tickfontsize)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.set_xlabel('$z_1$', fontsize=fontsize)
    ax.set_ylabel('$z_2$', fontsize=fontsize)
    if args is None:
        plt.show()
    else:
        fig.set_size_inches(9, 9)
        fig.savefig(os.path.join(args.sample_dir, args.run_name + '_' + fnm))

def main(args):
    Xtr, ytr, Xte, yte, Trgtr, Trgte, vfcn = load(args.train_file, batch_size=args.batch_size, use_x_prev=args.use_x_prev)
    # args.input_dim_z = Xtr[0].shape[-1]
    # args.input_dim_g = Xtr[1].shape[-1]
    # mdl = get_model(args.batch_size, args.input_dim_z, args.input_dim_g, args.intermediate_dim_x, args.intermediate_dim_g, args.intermediate_dim_z, args.optimizer)

    if args.use_x_prev:
        args.original_dim = Xtr[0].shape[-1]
    else:
        args.original_dim = Xtr.shape[-1]
    args.intermediate_dim = args.intermediate_dim_x
    args.latent_dim = args.intermediate_dim_z
    mdl = get_model(args.batch_size, args.original_dim, args.latent_dim, args.intermediate_dim, args.optimizer, kl_weight=args.kl_weight, use_x_prev=args.use_x_prev)
    
    print('Training...')
    callbacks = get_callbacks(args)
    mdl.fit(Xtr, [ytr, ytr],
        shuffle=True,
        batch_size=args.batch_size,
        epochs=args.num_epochs,
        callbacks=callbacks,
        validation_data=(Xte, [yte, yte]))

    enc_model = make_encoder(mdl, args.original_dim,
        args.intermediate_dim, batch_size=1)
    dec_model = make_decoder(mdl, args.original_dim, args.latent_dim, args.intermediate_dim, use_x_prev=args.use_x_prev)

    # plot
    vis_encoding([(Xtr, Trgtr), (Xte, Trgte)], enc_model, 'latents', args)
    # vis_encoding(Xte, Trgte, enc_model, 'test', args)
    vis_decoding([(Xtr, Trgtr), (Xte, Trgte)], enc_model, dec_model, vfcn, 'vels', args)
    # vis_decoding(Xte, Trgte, enc_model, dec_model, vfcn, 'v_test', args)

if __name__ == '__main__':
    """
    python train_goal.py tmp2 --intermediate_dim_z 2

    I have the KL weight turned down low so that a 2d latent dim can reconstruct very well, including the theta-conditioned velocities

    The idea is that, instead of reassociation searching through the aiming directions (thetas), maybe it searches through putative volitional axes, i.e., the 2d latent space found by a VAE

    A few things to do:
    - Plot vels decoded from a grid of the 2d latent space, where the grid spans the domain of the training data's projection
        - Are the values on the edges always higher vels?

    Note: train = Int. block; test = WMP block
        - filtered as Matt does for reassociation (i.e., balanced per theta)
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('run_name', type=str, help='tag for current run')
    parser.add_argument('--train_file', type=str,
        default='/Users/mobeets/code/bciDynamics/data/fits/lstm_structs/20120628.mat',
        help='data for training/testing (.mat)')
    parser.add_argument('--optimizer', type=str,
        default='adam', help='optimizer for training')
    parser.add_argument('--num_epochs', type=int,
        default=400, help='number of epochs of training')
    parser.add_argument('--intermediate_dim_x', type=int, default=200)
    parser.add_argument('--intermediate_dim_z', type=int, default=2)
    parser.add_argument('--kl_weight', type=float, default=0.05)
    # parser.add_argument('--intermediate_dim_g', type=int, default=20)
    parser.add_argument('--use_x_prev', action='store_true', default=False)
    parser.add_argument('--patience', type=int,
        default=5, help='epochs to wait for val_loss to decrease')
    parser.add_argument('--batch_size', type=int,
        default=100, help='batch size for training')
    parser.add_argument('--model_dir', type=str,
        default='data/models', help='basedir for saving model weights')
    parser.add_argument('--sample_dir', type=str,
        default='data/plots/vae', help='basedir for saving images')
    args = parser.parse_args()
    main(args)
