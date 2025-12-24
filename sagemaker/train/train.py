import os
import argparse
import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--model-dir', type=str, default=os.environ.get('SM_MODEL_DIR'))
    parser.add_argument('--train', type=str, default=os.environ.get('SM_CHANNEL_TRAIN'))
    args = parser.parse_args()

    data_path = os.path.join(args.train, 'citrus.csv')
    data = pd.read_csv(data_path)

    X = data.drop('name', axis=1)
    y = data['name']

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    model = DecisionTreeClassifier()
    model.fit(X_train, y_train)

    y_pred = model.predict(X_test)
    print("Accuracy:", accuracy_score(y_test, y_pred))

    joblib.dump(model, os.path.join(args.model_dir, 'model.joblib'))

if __name__ == "__main__":
    main()
