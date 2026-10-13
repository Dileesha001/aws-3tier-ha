"""Run from the same terminal/environment as the backend. Never prints secrets."""
import argparse
import os
from datetime import datetime, timezone
from app import notify_owner

parser = argparse.ArgumentParser(description="Check email settings; optionally send a test notification.")
parser.add_argument("--send", action="store_true", help="Send one test email to NOTIFICATION_EMAIL")
args = parser.parse_args()
missing = [key for key in ("RESEND_API_KEY", "NOTIFICATION_EMAIL") if not os.environ.get(key)]
if missing:
    print("Email is not configured. Missing: " + ", ".join(missing))
    print("Set these variables in this terminal or the hosting service's Environment settings.")
    raise SystemExit(1)
print("Required email settings are present (values hidden).")
if args.send:
    sent = notify_owner({"id": "test", "name": "Cloudbook email check", "message": "Your guestbook email integration is connected.", "created_at": datetime.now(timezone.utc).isoformat()})
    print("Resend accepted the email. Check its dashboard and your inbox/spam folder." if sent else "Email failed. See the diagnostic above.")
    raise SystemExit(0 if sent else 1)
