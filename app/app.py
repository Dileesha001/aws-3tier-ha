from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def home():
    return """
    <h1>AWS 3-Tier HA Project</h1>
    <p>Application is healthy.</p>
    """


@app.get("/health")
def health():
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
