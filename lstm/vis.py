import os.path
import numpy as np
import matplotlib.pyplot as plt

def plot_tunings(gs, yte, yhats, outdir='', prefix=''):
    fig = plt.figure(facecolor='white')
    one_dim = len(yte.shape) == 1
    if one_dim:
        yte = yte[:,None]
        yhats = [yhat[:,None] for yhat in yhats]
    nrs = 1
    ncs = yte.shape[-1]
    clrs = ['r', 'g', 'b']
    for i in xrange(ncs):
        plt.subplot(nrs,ncs,i+1)
        plt.plot(gs, yte[:,i], 'k-')
        for j, yhat in enumerate(yhats):
            plt.plot(gs, yhat[:,i], clrs[j] + '-')
    fig.savefig(os.path.join(outdir, '{}_yhat-tuning.pdf').format(prefix))
    plt.close(fig)

def plot_2d_examples(yte, yhat, outdir='', prefix=''):
    i = 1
    fig = plt.figure(facecolor='white')
    n = len(yte)
    nrs = int(np.ceil(np.sqrt(n)))
    ncs = int(n*1.0 / nrs)
    for r in xrange(nrs):
        for c in xrange(ncs):
            plt.subplot(nrs,ncs,i)
            ys0 = yte[i-1]
            ysh = yhat[i-1]
            plt.plot(ys0[:,0], ys0[:,1], 'k-')
            plt.plot(ysh[:,0], ysh[:,1], 'r-')
            plt.axis('off')
            i += 1
    fig.savefig(os.path.join(outdir, '{}_yhat-2d.pdf').format(prefix))
    plt.close(fig)

def plot_examples(yte, yhat, outdir='', prefix='', nrows=5, n=None):
    if n is None:
        nts = len(yte)
    else:
        nts = min(n, len(yte))
    nsts = np.arange(0, nts, nrows)
    ncols = yte.shape[-1] # number of columns

    fnm = os.path.join(outdir, '{}_yhat-{}.pdf')
    for j, nst in enumerate(nsts):
        fig = plt.figure(facecolor='white')
        i = 1
        for r in xrange(j, min(j+nrows, nts)): #xrange(nrows):
            ymn = yte[r].min()
            ymx = yte[r].max()
            for c in xrange(ncols):
                plt.subplot(nrows,ncols,i)
                ys0 = yte[r,:,c]
                ysh = yhat[r,:,c]
                plt.plot(ys0, 'k-')
                plt.plot(ysh, 'r-')
                plt.ylim([ymn, ymx])
                plt.axis('off')
                i += 1
        fig.savefig(fnm.format(prefix, j))
        plt.close(fig)
