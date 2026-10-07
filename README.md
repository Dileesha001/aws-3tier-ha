## Run locally on Windows

Requires Python 3.

From the project root:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r .\app\requirements.txt
.\.venv\Scripts\python.exe .\app\app.py
```

Open http://127.0.0.1:8000 and http://127.0.0.1:8000/health.
The health endpoint returns HTTP 200.

## PostgreSQL configuration

Database routes use these environment variables:

- DB_HOST
- DB_PORT (default: 5432)
- DB_NAME (default: portfolio_app)
- DB_USER
- DB_PASSWORD

GET /messages returns the latest 50 messages.
POST /messages accepts name and message as JSON or form fields.

RDS is private. Test RDS connectivity from application EC2 instances
using sg-app. Supply credentials at runtime from Secrets Manager.
Never commit passwords, .env files, or AWS access keys.

The ALB-to-application-to-RDS test remains pending until deployment.