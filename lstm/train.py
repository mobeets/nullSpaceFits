from __future__ import print_function
import os.path
import json
import argparse
from keras.callbacks import EarlyStopping, ModelCheckpoint
from load_data import load
from model import get_model, load_model
from vis import plot_examples
from score import print_scores, ScoreCallback, predict_sequential, FairModel

def get_callbacks(args):
    json_file = os.path.join(args.model_dir, args.run_name + '.json')
    mdl_file = os.path.join(args.model_dir, args.run_name + '.h5')
    json.dump(vars(args), open(json_file, 'w'))
    early_stopping = EarlyStopping(monitor='val_loss', patience=2)
    checkpt = ModelCheckpoint(mdl_file, monitor='val_loss',
        save_weights_only=True, save_best_only=True)    
    return [early_stopping, checkpt]

def main(args):
    Xtr, ytr, Xte, yte, gtr, gte, ttr, tte, tmtr, tmte = load(args.train_file,
        kind=args.kind, do_cv_split=True,
        maxlen=args.max_len, batch_size=args.batch_size)
    print(Xtr.shape, ytr.shape, Xte.shape, yte.shape)
    args.input_dim = Xtr.shape[-1]
    args.output_dim = ytr.shape[-1]
    args.seq_length = ytr.shape[-2]
    mdl = get_model(args.batch_size, args.input_dim, args.output_dim,
        args.seq_length, args.optimizer, stateful=args.do_score)
    if args.model_file is not None:
        mdl.load_weights(args.model_file)
    if args.do_score and args.model_file is not None:
        bmdl = get_model(1, args.input_dim, args.output_dim, 1,
            args.optimizer, stateful=True)
        bmdl.load_weights(args.model_file)
    else:
        bmdl = None
    
    if args.num_epochs > 0:
        print('Training...')
        callbacks = get_callbacks(args)
        # scs = ScoreCallback(Xtr, ytr, Xte, yte, gtr, gte, args.batch_size)
        # callbacks.append(scs)
        mdl.fit(Xtr, ytr,
            batch_size=args.batch_size,
            epochs=args.num_epochs,
            callbacks=callbacks,
            validation_data=(Xte, yte))

    print_scores(mdl, Xtr, ytr, Xte, yte, gtr, gte, tmtr, tmte, args.batch_size, bmdl)
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
    parser.add_argument("--do_score", action="store_true", 
                help="score only")
    parser.add_argument('--model_dir', type=str,
                default='data/models',
                help='basedir for saving model weights')
    parser.add_argument('--plot_dir', type=str,
                default='data/plots', help='basedir for saving figures')
    args = parser.parse_args()
    main(args)
