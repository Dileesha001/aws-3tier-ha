import os

import psycopg
from psycopg.rows import dict_row
from flask import Flask, jsonify, request

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024


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

        return jsonify(record), 201 if request.method == "POST" else 200

    except (KeyError, ValueError, psycopg.Error):
        app.logger.error("Database operation failed")
        return jsonify(error="Database temporarily unavailable"), 503


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)