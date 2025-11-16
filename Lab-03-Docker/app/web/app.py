#!/usr/bin/env python3
"""
Simple Flask Web Application for Docker Labs
"""
from flask import Flask, jsonify, render_template_string
import os
import socket

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Docker Lab Web App</title>
    <style>
        body { font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px; }
        .info { background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 10px 0; }
        h1 { color: #2196F3; }
    </style>
</head>
<body>
    <h1>🐳 Docker Lab Web Application</h1>
    <div class="info">
        <p><strong>Hostname:</strong> {{ hostname }}</p>
        <p><strong>Container IP:</strong> {{ ip }}</p>
        <p><strong>Environment:</strong> {{ env }}</p>
    </div>
    <p>✅ Application is running successfully!</p>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(
        HTML_TEMPLATE,
        hostname=socket.gethostname(),
        ip=socket.gethostbyname(socket.gethostname()),
        env=os.environ.get('APP_ENV', 'development')
    )

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "web"}), 200

@app.route('/api/info')
def info():
    return jsonify({
        "hostname": socket.gethostname(),
        "ip": socket.gethostbyname(socket.gethostname()),
        "environment": os.environ.get('APP_ENV', 'development'),
        "version": "1.0.0"
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
