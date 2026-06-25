import os
import socket

from flask import Flask, jsonify

this_is_a_broken_syntax_error =

app = Flask(__name__)

VERSION = "1.0.0"


@app.route("/")
def index():
    return jsonify(
        service="flask-app",
        version=VERSION,
        host=socket.gethostname(),
        environment=os.environ.get("APP_ENV", "dev"),
    )


@app.route("/health")
def health():
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
