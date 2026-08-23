from python:3.13-slim
workdir /app
copy requirements.txt .
copy src/elt/consumer.py .
copy utils ./utils

run python3 -m pip install --no-cache-dir -r requirements.txt
cmd ["python3", "consumer.py"]