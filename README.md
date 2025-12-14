# Grange

A simple machine learning project that classifies citrus fruits (oranges and grapefruits) based on their physical measurements using a Decision Tree classifier.

## Features

- Loads citrus fruit data from a CSV file
- Trains a Decision Tree model to predict fruit type
- Evaluates model accuracy on test data
- Makes predictions on new fruit samples

## Dataset

The dataset (`citrus.csv`) contains the following columns:
- `name`: Fruit type (orange or grapefruit)
- `diameter`: Fruit diameter
- `weight`: Fruit weight
- `red`: Red color component (0-255)
- `green`: Green color component (0-255)
- `blue`: Blue color component (0-255)

This dataset was downloaded from [Kaggle: Oranges vs Grapefruit](https://www.kaggle.com/datasets/joshmcadams/oranges-vs-grapefruit).

## Installation

1. Clone or download this repository
2. Navigate to the project directory
3. Create a virtual environment:
   ```
   python3 -m venv venv
   ```
4. Activate the virtual environment:
   - On Linux/Mac: `source venv/bin/activate`
   - On Windows: `venv\Scripts\activate`
5. Install required packages:
   ```
   pip install -r requirements.txt
   ```

## Usage

Run the main script:
```
python3 main.py
```

This will:
- Train the model and show accuracy (around 94%)
- Predict the type for an example fruit (diameter=3.0, weight=90, RGB=(170,80,5))

## Requirements

- Python 3.x
- pandas
- scikit-learn

## Output Example

```
Accuracy: 0.945
Prediction: ['orange']
```
