"""AutoML entry points for AutoML projects."""


def run_demo(*args, **kwargs):
    """Lazily import the demonstration so it also works with ``python -m``."""
    from automl_project.automl.demo import run_demo as implementation

    return implementation(*args, **kwargs)


__all__ = ["run_demo"]
