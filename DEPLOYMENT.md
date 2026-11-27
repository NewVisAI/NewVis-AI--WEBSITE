# NewVis AI — Deployment Guide

Production-ready deployment guide for both **website** (port 8000) and **dashboard** (port 8002) services.

---


> **Update:** `docker-compose.yml` now runs just the website plus Caddy (automatic HTTPS for newvis.gensolve.in,
> HSTS). Leads are stored on the `website-leads` volume at `/data/leads.db`, and
> `ADMIN_KEY` has no default: set it in `.env` (copy `.env.example`). The dashboard is no longer part of this
> compose file; it belongs on the customer's own network, not on the public site.

## Quick Start: Docker Compose (Recommended)

### Prerequisites
- **Docker** 20.10+
- **Docker Compose** 1.29+
- **Git**

### Deploy Both Services
```bash
# Clone the combined repository
git clone https://github.com/NewVisAI/newvis-ai-complete.git
cd newvis-ai-complete

# Start both services
docker-compose up -d

# View logs
docker-compose logs -f

# Check health
curl http://localhost:8000/healthz  # Website
curl http://localhost:8002          # Dashboard
```

**Services will be available at:**
- 🌐 Website: http://localhost:8000
- 📊 Dashboard: http://localhost:8002

---

## Environment Configuration

Create a `.env` file in the project root:

```env
# Website admin access
ADMIN_KEY=your-secret-admin-key

# Database
LEADS_DB_PATH=/app/leads.db

# Dashboard (optional)
DEBUG=false
LOG_LEVEL=INFO
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

---

## Manual Deployment (Without Docker)

### Website Setup
```bash
cd "website sentinel"

# 1. Virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run
uvicorn app:app --host 0.0.0.0 --port 8000
```

### Dashboard Setup
```bash
cd SENTINEL-UI

# 1. Virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run
uvicorn web_server:app --host 0.0.0.0 --port 8002
```

---

## Production Deployment

### Gunicorn + Nginx (Linux/macOS)

**1. Install production ASGI server:**
```bash
pip install gunicorn
```

**2. Website systemd service** (`/etc/systemd/system/newvis-website.service`):
```ini
[Unit]
Description=NewVis AI Website
After=network.target

[Service]
Type=notify
User=www-data
WorkingDirectory=/opt/newvis-ai/website-sentinel
ExecStart=/opt/newvis-ai/website-sentinel/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker --bind 127.0.0.1:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

**3. Dashboard systemd service** (`/etc/systemd/system/newvis-dashboard.service`):
```ini
[Unit]
Description=NewVis AI Dashboard
After=network.target

[Service]
Type=notify
User=www-data
WorkingDirectory=/opt/newvis-ai/SENTINEL-UI
ExecStart=/opt/newvis-ai/SENTINEL-UI/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker --bind 127.0.0.1:8002 web_server:app
Restart=always

[Install]
WantedBy=multi-user.target
```

**4. Enable and start:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable newvis-website newvis-dashboard
sudo systemctl start newvis-website newvis-dashboard
sudo systemctl status newvis-website newvis-dashboard
```

**5. Nginx reverse proxy** (`/etc/nginx/sites-available/newvis`):
```nginx
upstream website {
    server 127.0.0.1:8000;
}

upstream dashboard {
    server 127.0.0.1:8002;
}

server {
    listen 80;
    server_name newvis.gensolve.in;

    # Website
    location / {
        proxy_pass http://website;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Dashboard
    location /dashboard {
        proxy_pass http://dashboard;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**6. Enable and reload:**
```bash
sudo ln -s /etc/nginx/sites-available/newvis /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Cloud Deployment

### AWS (EC2 + ECS/Docker)

**1. Build and push images:**
```bash
# Website
docker build -t newvis-website:1.0 ./website\ sentinel
docker tag newvis-website:1.0 YOUR_AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/newvis-website:1.0
docker push YOUR_AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/newvis-website:1.0

# Dashboard
docker build -t newvis-dashboard:1.0 ./SENTINEL-UI
docker tag newvis-dashboard:1.0 YOUR_AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/newvis-dashboard:1.0
docker push YOUR_AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/newvis-dashboard:1.0
```

**2. Deploy via ECS Compose or Fargate task definitions** (see AWS docs for task definition JSON)

### Heroku
```bash
# Website
cd "website sentinel"
git init
heroku create newvis-website
git add .
git commit -m "Deploy website"
git push heroku main

# Dashboard
cd ../SENTINEL-UI
git init
heroku create newvis-dashboard
git add .
git commit -m "Deploy dashboard"
git push heroku main
```

---

## Health Checks & Monitoring

### Endpoint Status
```bash
# Website health
curl -s http://localhost:8000/healthz | jq .

# Dashboard (should return 200 on index.html)
curl -s -I http://localhost:8002 | grep HTTP
```

### Log Monitoring
```bash
# Docker
docker-compose logs -f website
docker-compose logs -f dashboard

# Systemd
journalctl -u newvis-website -f
journalctl -u newvis-dashboard -f

# Manual (if running in foreground)
# Logs print to console
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Port already in use | Change port in `docker-compose.yml` or kill process: `lsof -i :8000` |
| "Connection refused" | Ensure both services started: `docker-compose ps` |
| Leads database not persisting | Check volume mount in compose file: `docker volume ls` |
| Dashboard login fails | Verify mock backend is responding: `curl http://localhost:8002/api/login` |

---

## Scaling & Performance

### Load Testing
```bash
# Website
ab -n 1000 -c 10 http://localhost:8000/

# Dashboard
ab -n 500 -c 5 http://localhost:8002/
```

### Horizontal Scaling (with load balancer)
- Run multiple instances of each service on different ports
- Route traffic via Nginx upstream blocks or cloud load balancer (ALB/NLB)

---

## Backup & Recovery

### Leads Database
```bash
# Backup
docker cp newvis-website:/app/leads.db ./leads.db.backup

# Restore
docker cp ./leads.db.backup newvis-website:/app/leads.db
```

### Scheduled Backups (Linux cron)
```bash
0 2 * * * docker exec newvis-website sqlite3 /app/leads.db ".backup '/backups/leads-$(date +\%Y\%m\%d).db'"
```

---

## Support

- **Issues:** https://github.com/GenSolve/newvis-website/issues
- **Docs:** See `README.md` in each service directory
- **Email:** gensolve.team@gmail.com
