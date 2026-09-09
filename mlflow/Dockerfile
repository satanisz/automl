FROM python:3.12-slim-trixie

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN pip install --no-cache-dir \
        "mlflow==3.14.0" \
        "psycopg2-binary==2.9.11" \
        "boto3"

EXPOSE 5000

ENTRYPOINT ["mlflow"]
