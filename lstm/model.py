import json
from keras.layers import Input, Dense, LSTM, TimeDistributed
from keras.models import Model
import keras.backend as K

def get_model(batch_size, input_dim, output_dim, seq_length, optimizer,
    add_dense=True, stateful=False):

    X = Input(batch_shape=(batch_size, seq_length, input_dim),
        name='X')

    if add_dense:
        z = LSTM(2*output_dim, return_sequences=True,
            activation='relu', stateful=stateful, name='z')(X)
        z_dense = Dense(output_dim, name='z_dense')
        decoder_mean = TimeDistributed(z_dense, name='y_hat')
        y_hat = decoder_mean(z)
    else:
        y_hat = LSTM(output_dim, return_sequences=True,
            stateful=stateful, name='y_hat')(X)

    model = Model(X, y_hat)
    model.compile(optimizer=optimizer, loss='mse')
    return model

def load_model(model_file):
    margs = json.load(open(model_file.replace('.h5', '.json')))
    mdl = get_model(margs['batch_size'], margs['input_dim'], margs['output_dim'], margs['seq_length'], margs['optimizer'], margs['add_dense'])
    model.load_weights(model_file)
    return mdl
