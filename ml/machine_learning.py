from keras.optimizers import SGD
import numpy
import pandas
from keras.models import Sequential
from keras.layers import Dense, Flatten
from keras.wrappers.scikit_learn import KerasClassifier
from keras.utils import np_utils
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold
from sklearn.preprocessing import LabelEncoder
from sklearn.pipeline import Pipeline


dataset_file = "../dataset/ML_dataset1.csv"
numpy.random.seed(0)

dataframe   = pandas.read_csv(dataset_file, header=None)
dataset     = dataframe.values
X = dataset[:,0:dataset.shape[1]-2].astype(int)
Y = dataset[:,dataset.shape[1]-1]

# Preprocess the labels

# LabelEncoder from scikit-learn turns each text label
# (e.g "Iris-setosa", "Iris-versicolor") into a vector
# In this case, each of the three labels are just assigned
# a number from 0-2.
encoder = LabelEncoder()
encoder.fit(Y)
encoded_Y = encoder.transform(Y)

# to_categorical converts the numbered labels into a one-hot vector
dummy_y = np_utils.to_categorical(encoded_Y)

def baseline_model():
    model = Sequential()
    model.add(Dense(24, input_dim=dataset.shape[1]-2, activation='tanh'))
    model.add(Dense(64, activation='tanh'))
    model.add(Dense(2, activation='softmax'))
    model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

    return model

estimator = KerasClassifier(build_fn=baseline_model, nb_epoch=200, batch_size=5, verbose=0)

kfold = KFold(n_splits=20, shuffle=True, random_state=0)
results = cross_val_score(estimator, X, dummy_y, cv=kfold)
print("%0.6f,%0.6f" % (results.mean(), results.std()))


