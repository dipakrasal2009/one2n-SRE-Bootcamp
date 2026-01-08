import os
import logging
from dotenv import load_dotenv
from flask import Flask, jsonify
from flask_migrate import Migrate
from .database import db
from .routes import student_bp

load_dotenv()  # read .env

def create_app():
    app = Flask(__name__, instance_relative_config=False)

    # Config from environment
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", "sqlite:///students.db")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # Logging setup: basic config that uses Flask's logger
    logging.basicConfig(level=logging.INFO,
                        format="%(asctime)s %(levelname)s %(name)s %(message)s")
    app.logger.setLevel(logging.INFO)

    # Initialize extensions
    db.init_app(app)
    migrate = Migrate(app, db)

    # Register blueprints (versioned)
    app.register_blueprint(student_bp, url_prefix="/api/v1/students")

    # Healthcheck
    @app.route("/healthcheck", methods=["GET"])
    def healthcheck():
        return jsonify({"status": "ok"}), 200

    # Generic error handlers
    @app.errorhandler(404)
    def not_found(e):
        return jsonify({"error": "not found"}), 404

    @app.errorhandler(500)
    def internal_error(e):
        app.logger.exception("Server error")
        return jsonify({"error": "internal server error"}), 500

    return app
