FROM python:3.12-slim
WORKDIR /app
COPY pyproject.toml /app/
RUN pip install --no-cache-dir -e .
COPY app /app/app
ENV PORT=8000
CMD ["gunicorn","app.main:app","-k","uvicorn.workers.UvicornWorker","-w","4","-b","0.0.0.0:8000","--timeout","60"]
