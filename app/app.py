import os
import sqlite3
import json
import urllib.request
import urllib.error
from contextlib import closing

from pathlib import Path

import psycopg
from psycopg.rows import dict_row
from flask import Flask, jsonify, request, send_from_directory

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024
FRONTEND_DIST = Path(__file__).resolve().parent.parent / "frontend" / "dist"


def notify_owner(record):
    """Best-effort notification after commit; secrets never reach the browser."""
    key = os.environ.get("RESEND_API_KEY")
    recipient = os.environ.get("NOTIFICATION_EMAIL")
    if not key or not recipient:
        app.logger.warning("Email notifications disabled: set RESEND_API_KEY and NOTIFICATION_EMAIL in the backend environment")
        return False
    try:
        payload = {
            "from": os.environ.get("NOTIFICATION_FROM", "Cloudbook <onboarding@resend.dev>"),
            "to": [recipient],
            "subject": "New Cloudbook guestbook message",
            "text": (
                f"New guestbook message #{record['id']}\n"
                f"From: {record['name']}\n"
                f"Saved: {record['created_at']}\n\n{record['message']}"
            ),
        }
        email_request = urllib.request.Request(
            "https://api.resend.com/emails",
            data=json.dumps(payload).encode("utf-8"),
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json",
                     "User-Agent": "Cloudbook/1.0"},
            method="POST",
        )
        with urllib.request.urlopen(email_request, timeout=5) as response:
            if not 200 <= response.status < 300:
                raise ValueError("Email service rejected notification")
        app.logger.info("Email provider accepted notification for message %s", record.get("id"))
        return True
    except urllib.error.HTTPError as error:
        guidance = {
            400: "Check recipient and sender address settings.",
            401: "The API key is invalid; create or update RESEND_API_KEY.",
            403: "Check API key permissions. With onboarding@resend.dev, use your Resend account email as recipient; other recipients require a verified sender domain.",
            422: "Check email settings and sender domain verification.",
            429: "Email provider limit reached; check Resend usage.",
        }.get(error.code, "Check the Resend dashboard for service errors.")
        app.logger.warning("Email notification rejected (HTTP %s). %s", error.code, guidance)
        return False
    except Exception:
        # Do not log provider responses: they may contain credentials or message text.
        app.logger.warning("Email notification failed for saved message %s; check network access and Resend availability", record.get("id"))
        return False


def connect_db():
    return psycopg.connect(
        host=os.environ["DB_HOST"],
        port=int(os.environ.get("DB_PORT", "5432")),
        dbname=os.environ.get("DB_NAME", "portfolio_app"),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        sslmode="require",
        connect_timeout=10,
        row_factory=dict_row,
    )


@app.get("/")
def home():
    if (FRONTEND_DIST / "index.html").is_file():
        return send_from_directory(FRONTEND_DIST, "index.html", max_age=0)
    return """
    <h1>AWS 3-Tier HA Project</h1>
    <p>Application is healthy.</p>

    <form action="/messages" method="post">
      <p>
        <label>Name:
          <input name="name" maxlength="100" required>
        </label>
      </p>
      <p>
        <label>Message:
          <textarea name="message" maxlength="500" required></textarea>
        </label>
      </p>
      <button type="submit">Save message</button>
    </form>

    <p><a href="/messages">View saved messages</a></p>
    """


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


@app.route("/messages", methods=["GET", "POST"])
@app.route("/api/messages", methods=["GET", "POST"])
def messages():
    if request.method == "POST":
        data = request.get_json(silent=True) if request.is_json else request.form

        if not data or not hasattr(data, "get"):
            return jsonify(error="Provide a name and message"), 400

        name = data.get("name")
        message = data.get("message")

        if not isinstance(name, str) or not isinstance(message, str):
            return jsonify(error="Name and message must be text"), 400

        name = name.strip()
        message = message.strip()

        if not name or not message or len(name) > 100 or len(message) > 500:
            return jsonify(
                error="Name must be 1–100 characters; message 1–500 characters"
            ), 400

    try:
        if os.environ.get("LOCAL_DB_PATH"):
            with closing(sqlite3.connect(os.environ["LOCAL_DB_PATH"], timeout=10)) as conn:
                conn.row_factory = sqlite3.Row
                conn.execute("""CREATE TABLE IF NOT EXISTS messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL, message TEXT NOT NULL,
                    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
                )""")
                if request.method == "POST":
                    cursor = conn.execute("INSERT INTO messages (name, message) VALUES (?, ?)", (name, message))
                    record = dict(conn.execute("SELECT * FROM messages WHERE id = ?", (cursor.lastrowid,)).fetchone())
                else:
                    record = [dict(row) for row in conn.execute("SELECT * FROM messages ORDER BY id DESC LIMIT 50")]
                conn.commit()
            if request.method == "POST":
                notify_owner(record)
            return jsonify(record), 201 if request.method == "POST" else 200
        with connect_db() as conn:
            if request.method == "POST":
                record = conn.execute(
                    """
                    INSERT INTO messages (name, message)
                    VALUES (%s, %s)
                    RETURNING id, name, message, created_at
                    """,
                    (name, message),
                ).fetchone()
            else:
                record = conn.execute(
                    """
                    SELECT id, name, message, created_at
                    FROM messages
                    ORDER BY id DESC
                    LIMIT 50
                    """
                ).fetchall()

        if request.method == "POST":
            notify_owner(record)
        return jsonify(record), 201 if request.method == "POST" else 200

    except (KeyError, ValueError, psycopg.Error, sqlite3.Error):
        app.logger.error("Database operation failed")
        return jsonify(error="Database temporarily unavailable"), 503


@app.get("/assets/<path:filename>")
def frontend_asset(filename):
    return send_from_directory(FRONTEND_DIST / "assets", filename, max_age=31536000)


if __name__ == "__main__":
    # Only direct local startup selects SQLite automatically; Gunicorn uses RDS.
    if not any(os.environ.get(key) for key in ("DB_HOST", "DB_USER", "DB_PASSWORD")):
        os.environ.setdefault("LOCAL_DB_PATH", str(Path(__file__).resolve().parent / "local-messages.sqlite3"))
        app.logger.warning("Local development: messages are stored in SQLite, not AWS RDS.")
    app.run(host="127.0.0.1", port=8000)
