from keras.layers import Input, Dense, Lambda, concatenate
from keras.models import Model
from keras import backend as K
from keras import losses

def make_decoder(model, original_dim, latent_dim, intermediate_dim, batch_size=1, use_x_prev=False):
    # build a decoder that can sample from the learned distribution
    z = Input(batch_shape=(batch_size, latent_dim,))
    if use_x_prev:
        xp = Input(batch_shape=(batch_size, original_dim), name='history')
    if use_x_prev:
        xpz = concatenate([xp, z], axis=-1)
    else:
        xpz = z
    decoder_mean = model.get_layer('x_decoded_mean')
    if intermediate_dim > 0:
        decoder_h = model.get_layer('decoder_h')
        _h_decoded = decoder_h(xpz)
        _x_decoded_mean = decoder_mean(_h_decoded)
    else:
        _x_decoded_mean = decoder_mean(xpz)
    if use_x_prev:
        decoder = Model([z, xp], _x_decoded_mean)
    else:
        decoder = Model(z, _x_decoded_mean)
    return decoder

def make_encoder(model, original_dim, intermediate_dim, batch_size=1):
    # build a model to project inputs on the latent space
    # x = model.get_layer('x')
    x = Input(batch_shape=(batch_size, original_dim), name='x')
    if intermediate_dim > 0:
        h = model.get_layer('h')(x)
        z_mean = model.get_layer('z_mean')(h)
        z_log_var = model.get_layer('z_log_var')(h)
    else:
        z_mean = model.get_layer('z_mean')(x)
        z_log_var = model.get_layer('z_log_var')(x)
    encoder = Model(x, [z_mean, z_log_var])
    # encoder = Model(x, z_mean)
    return encoder

def get_model(batch_size, original_dim, latent_dim, intermediate_dim, optimizer, kl_weight=1.0, use_x_prev=False):

    x = Input(batch_shape=(batch_size, original_dim), name='x')
    if use_x_prev:
        xp = Input(batch_shape=(batch_size, original_dim), name='history')

    # build encoder
    if intermediate_dim > 0:
        h = Dense(intermediate_dim, activation='relu', name='h')(x)
        z_mean = Dense(latent_dim, name='z_mean')(h)
        z_log_var = Dense(latent_dim, name='z_log_var')(h)
    else:
        z_mean = Dense(latent_dim, name='z_mean')(x)
        z_log_var = Dense(latent_dim, name='z_log_var')(x)

    # sample latents
    def sampling(args):
        z_mean, z_log_var = args
        eps = K.random_normal(shape=(batch_size, latent_dim), mean=0., stddev=1.0)
        return z_mean + K.exp(z_log_var/2) * eps
    z = Lambda(sampling)([z_mean, z_log_var])

    # build decoder
    if use_x_prev:
        xpz = concatenate([xp, z], axis=-1)
    else:
        xpz = z
    decoder_mean = Dense(original_dim, activation=None, name='x_decoded_mean')
    if intermediate_dim > 0:
        decoder_h = Dense(intermediate_dim, activation='relu', name='decoder_h')
        h_decoded = decoder_h(xpz)
        x_decoded_mean = decoder_mean(h_decoded)
    else:
        x_decoded_mean = decoder_mean(xpz)

    def kl_loss(z_true, z_args):
        Z_mean = z_args[:,:latent_dim]
        Z_log_var = z_args[:,latent_dim:]
        return -0.5*K.sum(1 + Z_log_var - K.square(Z_mean) - K.exp(Z_log_var), axis=-1)

    z_args = concatenate([z_mean, z_log_var], axis=-1, name='z_args')
    if use_x_prev:
        vae = Model([x, xp], [x_decoded_mean, z_args])
    else:
        vae = Model(x, [x_decoded_mean, z_args])
    vae.compile(optimizer=optimizer,
        loss={'x_decoded_mean': 'mse', 'z_args': kl_loss},
        loss_weights={'x_decoded_mean': 1.0, 'z_args': kl_weight})
    return vae
