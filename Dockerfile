FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py landing.html privacy.html 404.html ./
COPY static/ static/
# Leads live on a volume at /data, never inside /app, so code updates aren't masked.
RUN useradd --system --uid 10001 site && mkdir -p /data && chown site /data
USER site
ENV LEADS_DB_PATH=/data/leads.db TRUST_PROXY=1
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s CMD python -c "import urllib.request;urllib.request.urlopen('http://127.0.0.1:8000/healthz')"
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--forwarded-allow-ips", "*"]
