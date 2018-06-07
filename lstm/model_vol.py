import json
from keras.layers import Input, Dense, LSTM, TimeDistributed, Add
from keras.models import Model
import keras.backend as K

def get_model(batch_size, input_dim_1, input_dim_2, output_dim, latent_dim_2, seq_length, optimizer, stateful=False):

    Yprev = Input(batch_shape=(batch_size, seq_length, input_dim_1), name='Yprev')
    X = Input(batch_shape=(batch_size, seq_length, input_dim_2), name='X')

    z = LSTM(3*output_dim,
        return_sequences=True,
        stateful=stateful, name='z')(Yprev)
    z_dense = Dense(output_dim, name='z_dense')
    z_decoder_mean = TimeDistributed(z_dense, name='z_hat')
    z_out = z_decoder_mean(z)

    w = LSTM(latent_dim_2,
        return_sequences=True,
        stateful=stateful, name='w')(X)
    w_dense = Dense(output_dim, name='w_dense')
    w_decoder_mean = TimeDistributed(w_dense, name='w_hat')
    w_out = w_decoder_mean(w)

    y_hat = z_out
    # y_hat = Add()([z_out, w_out])

    model = Model([Yprev, X], y_hat)
    model.compile(optimizer=optimizer, loss='mse')
    return model

def load_model(model_file):
    margs = json.load(open(model_file.replace('.h5', '.json')))
    mdl = get_model(margs['batch_size'], margs['input_dim_1'], margs['input_dim_2'], margs['output_dim'], margs['latent_dim_2'], margs['seq_length'], margs['optimizer'], margs['add_dense'])
    model.load_weights(model_file)
    return mdl
