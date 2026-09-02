FROM python:3.12-slim

WORKDIR /app

RUN groupadd --system app && useradd --system --gid app --uid 10001 app

COPY requirements.txt .
RUN pip install --no-cache-dir --requirement requirements.txt

COPY main.py .

USER 10001

CMD ["python", "main.py"]