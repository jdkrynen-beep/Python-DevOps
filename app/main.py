from flask import Flask, jsonify

app = Flask(__name__)

# "Base de données" en mémoire
SERVERS = [
    {"id": 1, "hostname": "web-prod-01", "ip": "10.0.0.1", "status": "up"},
    {"id": 2, "hostname": "db-prod-01", "ip": "10.0.0.2", "status": "down"},
]


@app.route("/api/v1/health", methods=["GET"])
def health():
    return jsonify({"status": "OK", "version": "1.0"}), 200


@app.route("/api/v1/servers", methods=["GET"])
def get_servers():
    return jsonify({
        "servers": SERVERS,
        "count": len(SERVERS)
    }), 200


@app.route("/api/v1/servers/<int:server_id>", methods=["GET"])
def get_server_by_id(server_id):
    server = next((s for s in SERVERS if s["id"] == server_id), None)

    if server is None:
        return jsonify({"error": "Server not found"}), 404

    return jsonify(server), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
