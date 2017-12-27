import tensorflow as tf
import numpy
import pandas as pd
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.optimizers import SGD
import time
from sklearn.model_selection import train_test_split

import tensorflow as tf
from keras import backend as K

dataset_file = "../dataset/ML_dataset4.csv"
num_lines_data = sum(1 for line in open(dataset_file)) - 1
features = numpy.int32(pd.read_csv(dataset_file, usecols=[0, 1, 3, 4, 5, 6, 7], skiprows=[0], header=None).values)
labels = numpy.int32(pd.read_csv(dataset_file, usecols=[2], skiprows=[0], header=None).values)


x_train, x_test, y_train, y_test = train_test_split(features, labels, test_size=0.33, random_state=int(time.time()))

model = Sequential()
model.add(Dense(24, activation='tanh', input_shape=x_train.shape[1:]))
model.add(Dense(64, activation='tanh', input_shape=x_train.shape[1:]))
model.add(Dense(1, activation='relu'))

sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
model.compile(loss='binary_crossentropy',
              optimizer=sgd,
              metrics=['accuracy'])

model.fit(x_train, y_train,
          epochs=100,
          batch_size=128)
score = model.evaluate(x_test, y_test, batch_size=128)