# Cloudbook — AWS three-tier guestbook

A React and TypeScript guestbook backed by Flask and PostgreSQL. The application
tier uses an internet-facing ALB and private EC2 instances in an Auto Scaling
Group across two Availability Zones. Terraform manages the imported environment.

## Frontend

The interface includes a validated message form, recent visitor messages, loading
and empty states, retryable errors, responsive layout, and an API availability
indicator. It uses React, TypeScript, Vite, Tailwind CSS and Lucide icons. No AWS
credentials or database passwords are sent to the browser. `/health` checks the
application process, not database availability. Messages are public.

### Local development

Requires Node.js 22.12+ or supported Node.js 24, and Python 3.

In one terminal, run Flask using the instructions below. In a second terminal:

```powershell
cd E:\aws-3tier-ha\frontend
npm ci
npm run dev
```

Open http://127.0.0.1:5173. Vite proxies `/api` and `/health` to Flask on port 8000.
If no database is configured, the UI shows an honest unavailable state; it does
not substitute sample records. Private RDS requires an authorized network path.

### Production build and local preview

```powershell
cd E:\aws-3tier-ha\frontend
npm run build
```

Start Flask, then open http://127.0.0.1:8000. Flask serves the built frontend for
local verification. On EC2, Nginx serves static files directly and proxies the API.

### Verification

```powershell
cd E:\aws-3tier-ha\frontend
npx playwright install chromium
npm test
cd ..
.\.venv\Scripts\python.exe -m unittest discover -s tests -p "test_*.py"
```

Browser tests use intercepted API responses to verify submission, refresh,
failure/retry, text escaping and mobile layout. They do not prove live RDS access.
Use the ALB to save and retrieve a message for the live end-to-end test.

The GitHub Actions workflow builds the frontend, runs browser tests, and uploads
the build artifact. It does not automatically deploy to AWS.

### Deployment to the existing ASG

Commit and push the frontend, package lock, Flask changes, and updated
`infrastructure/terraform/user-data.sh` before applying the template update.
The user data installs Node.js 22 and builds the frontend from `npm ci` on launch.
Existing instances do not rerun user data.

```powershell
cd E:\aws-3tier-ha\infrastructure\terraform
terraform validate
terraform plan "-out=frontend-deploy.tfplan"
# Review: expected launch-template and ASG updates, no deletions.
terraform apply "frontend-deploy.tfplan"
```

Replace one ASG instance, wait for the replacement to become healthy, verify the
new UI and database operations, and only then replace the remaining original.
Keep the previous launch-template version available for rollback. Node is only
needed during the build; no Vite development server runs in production.

## Run the backend locally on Windows

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
The frontend uses `/api/messages`, an alias with identical validation and behavior.

RDS is private. Test RDS connectivity from application EC2 instances
using sg-app. Supply credentials at runtime from Secrets Manager.
Never commit passwords, .env files, or AWS access keys.

The manual build demonstrated ALB-to-application-to-RDS reads/writes, ASG
replacement and centralized Nginx logging. The new frontend must be deployed and
verified separately through the ALB before claiming that its live test passed.

## Current limitations

- RDS is Single-AZ; database failover has not been demonstrated.
- Authentication and moderation are not implemented. This is a public portfolio
  guestbook, not a production system for confidential messages.
- Build-on-launch is the learning deployment path. A versioned artifact pipeline
  is a future improvement.
- Never commit Terraform state, saved plans, `.env` files, or AWS access keys.

The application is accessible through the ALB DNS name over HTTP. Custom-domain HTTPS using Route 53 and ACM is documented as an optional extension and was not implemented because no domain was available.
