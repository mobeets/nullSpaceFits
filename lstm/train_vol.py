from __future__ import print_function
import os.path
import json
import argparse
import numpy as np
from keras.callbacks import EarlyStopping, ModelCheckpoint
from load_data import load_vol
from model_vol import get_model, load_model
from score import get_rsqs

def get_callbacks(args):
    json_file = os.path.join(args.model_dir, args.run_name + '.json')
    mdl_file = os.path.join(args.model_dir, args.run_name + '.h5')
    json.dump(vars(args), open(json_file, 'w'))
    early_stopping = EarlyStopping(monitor='val_loss', patience=args.patience)
    checkpt = ModelCheckpoint(mdl_file, monitor='val_loss',
        save_weights_only=True, save_best_only=True)    
    return [early_stopping, checkpt]

def eval_fits(y, yhat, nm):
    rsq = get_rsqs(y, yhat)
    print('---------')
    print(nm)
    print(rsq)

def main(args):
    Xtr, ytr, Xte, yte, Xva, yva = load_vol(args.train_file,
        kind='volitional', do_cv_split=True,
        maxlen=args.max_len, batch_size=args.batch_size)
    print(Xtr.shape, ytr.shape, Xte.shape, yte.shape)

    # pull out X into X (Yprev) and W (thetas)
    nd = ytr.shape[-1]
    Wtr = Xtr[:,:,nd:]
    Wte = Xte[:,:,nd:]
    Wva = Xva[:,:,nd:]
    Xtr = Xtr[:,:,:nd]
    Xte = Xte[:,:,:nd]
    Xva = Xva[:,:,:nd]

    args.input_dim_1 = Xtr.shape[-1]
    args.input_dim_2 = Wtr.shape[-1]
    args.output_dim = ytr.shape[-1]
    args.seq_length = ytr.shape[-2]
    mdl = get_model(args.batch_size, args.input_dim_1,
        args.input_dim_2, 
        args.output_dim, args.latent_dim_2,
        args.seq_length, args.optimizer)
    if args.model_file is not None:
        mdl.load_weights(args.model_file)
    
    if args.num_epochs > 0:
        print('Training LSTMs...')
        callbacks = get_callbacks(args)
        mdl.fit([Xtr, Wtr], ytr,
            batch_size=args.batch_size,
            epochs=args.num_epochs,
            callbacks=callbacks,
            validation_data=([Xte, Wte], yte))

    if args.do_score:
        print('LSTM Scores:')
        yhat_tr = mdl.predict([Xtr, Wtr],
            batch_size=args.batch_size)
        eval_fits(ytr, yhat_tr, 'Training')
        yhat_te = mdl.predict([Xte, Wte],
            batch_size=args.batch_size)
        eval_fits(yte, yhat_te, 'Testing')
        yhat_va = mdl.predict([Xva, Wva],
            batch_size=args.batch_size)
        eval_fits(yva, yhat_va, 'Validation')

if __name__ == '__main__':
    """
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('run_name', type=str, help='tag for current run')
    parser.add_argument('--model_file', type=str,
                default=None, help='model file to load weights')
    parser.add_argument('--train_file', type=str,
                default='data/input/20160722.mat',
                help='data for training/testing (.mat)')
    parser.add_argument('--optimizer', type=str,
                default='adam', help='optimizer for training')
    # parser.add_argument('--kind', type=str, required=True,
    #             choices=['volitional'], default='volitional',
    #             help='predict volitional')
    parser.add_argument('--num_epochs', type=int,
                default=200, help='number of epochs of training')
    parser.add_argument('--max_len', type=int,
                default=25, help='maximum trial length')
    parser.add_argument('--patience', type=int,
                default=5, help='epochs to wait for val_loss to decrease')
    parser.add_argument('--latent_dim_2', type=int,
                default=4, help='# of volitional dimensions')
    parser.add_argument('--batch_size', type=int,
                default=100, help='batch size for training')
    parser.add_argument("--do_plot", action="store_true", 
                help="plot examples")
    parser.add_argument("--monitor_score", action="store_true", 
                help="monitor score during training")
    parser.add_argument("--do_score", action="store_true", 
                help="score only")
    parser.add_argument('--model_dir', type=str,
                default='data/models',
                help='basedir for saving model weights')
    parser.add_argument('--plot_dir', type=str,
                default='data/plots', help='basedir for saving figures')
    args = parser.parse_args()
    main(args)
