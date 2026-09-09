# %%
# End-to-end MVP. Run this cell and inspect the returned links/identifiers in
# MLflow, MinIO and DataHub. Reusable logic lives in src, not in the notebook.
from automl_project.automl.mvp import run_mvp

# %%
result = run_mvp(time_limit=120, preset="medium_quality")
result  # noqa: B018 - displayed by Jupyter/VS Code Interactive

# %%
# The registered model can be loaded in another process by its stable alias.
import mlflow.pyfunc

model = mlflow.pyfunc.load_model(
    "models:/automl-breast-cancer-classifier@candidate"
)
model  # noqa: B018 - displayed by Jupyter/VS Code Interactive
