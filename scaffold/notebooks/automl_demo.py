# %%
# Run this file in VS Code's Python Interactive window or copy the cells into a
# Jupyter notebook. The model and all experiment metadata are written to MLflow,
# not to the notebook process.
from automl_project.automl import run_demo

# %%
result = run_demo(time_limit=120, preset="medium_quality")
result

# %%
# This works in a new notebook or workspace as long as MLFLOW_TRACKING_URI is set.
import mlflow.pyfunc
import pandas as pd

model = mlflow.pyfunc.load_model(
    "models:/automl-breast-cancer-classifier@candidate"
)
raw_data = pd.read_csv("data/raw/breast_cancer.csv")
model.predict(raw_data.drop(columns=["malignant"]).head(3))
