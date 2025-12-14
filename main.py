import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score

data = pd.read_csv("citrus.csv")

X = data.drop('name', axis=1)
y = data['name']             

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

model = DecisionTreeClassifier()
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
print("Accuracy:", accuracy_score(y_test, y_pred))

new_fruit = pd.DataFrame([[3.0, 90, 170, 80, 5]], columns=X.columns)
print("Prediction:", model.predict(new_fruit))
