import os.path
import numpy as np
import matplotlib.pyplot as plt

def plot_tunings(gs, yte, yhats, ytr, outdir='', prefix=''):
    fig = plt.figure(facecolor='white')
    one_dim = len(yte.shape) == 1
    if one_dim:
        yte = yte[:,None]
        ytr = ytr[:,None]
        yhats = [yhat[:,None] for yhat in yhats]
    vmn = min([yte.min(), ytr.min(), np.vstack(yhats).min()])
    vmx = max([yte.max(), ytr.max(), np.vstack(yhats).max()])
    n = yte.shape[-1]
    nrs = int(np.ceil(np.sqrt(n)))
    ncs = int(np.ceil(n*1.0 / nrs))
    if nrs > ncs:
        nrs, ncs = ncs, nrs
    styles = ['b-', 'b--', 'r-']
    for i in xrange(n):
        plt.subplot(nrs,ncs,i+1)
        plt.plot(gs, yte[:,i], 'k-', linewidth=2.0)
        plt.plot(gs, ytr[:,i], 'k--', linewidth=2.0)
        for j, yhat in enumerate(yhats):
            plt.plot(gs, yhat[:,i], styles[j])
        plt.xlabel('$\\theta$')
        plt.ylabel('avg activity, dim {}'.format(i))
        plt.xticks(rotation=45)
        plt.ylim([vmn, vmx])
    fig.savefig(os.path.join(outdir, '{}_tuning.pdf').format(prefix))
    plt.close(fig)

def plot_2d_examples(yte, yhat, outdir='', prefix=''):
    i = 1
    fig = plt.figure(facecolor='white')
    n = len(yte)
    nrs = int(np.ceil(np.sqrt(n)))
    ncs = int(np.ceil(n*1.0 / nrs))
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

def plot_example_predictions(yte, yhats, styles, times, min_tm, max_tm, outdir='', prefix='', nrows=5, n=None):
    if n is None:
        nts = len(yte)
    else:
        nts = min(n, len(yte))
    nsts = np.arange(0, nts, nrows)
    ncols = yte.shape[-1] # number of columns

    fnm = os.path.join(outdir, '{}_yhats-{}.pdf')
    for j, nst in enumerate(nsts):
        fig = plt.figure(facecolor='white')
        i = 1
        for r in xrange(j, min(j+nrows, nts)):
            tms = times[r].flatten()
            ixt = (min_tm <= tms) & (tms <= max_tm)
            ymn = yte[r].min()
            ymx = yte[r].max()
            for c in xrange(ncols):
                plt.subplot(nrows,ncols,i)
                plt.plot(tms, yte[r,:,c], 'k-', alpha=0.5, linewidth=2.0)
                plt.plot(tms[ixt], yte[r,ixt,c], 'k-', linewidth=2.0)
                for k, yhat in enumerate(yhats):
                    plt.plot(tms, yhat[r,:,c], styles[k], alpha=0.5)
                    plt.plot(tms[ixt], yhat[r,ixt,c], styles[k])
                plt.plot([min_tm, min_tm], [ymn, ymx], 'k-', alpha=0.5)
                plt.plot([max_tm, max_tm], [ymn, ymx], 'k-', alpha=0.5)
                plt.ylim([ymn, ymx])
                plt.axis('off')
                i += 1
        fig.savefig(fnm.format(prefix, j))
        plt.close(fig)
