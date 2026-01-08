from flask import Blueprint, request, jsonify, current_app
from sqlalchemy.exc import IntegrityError
from .database import db
from .models import Student

student_bp = Blueprint("students", __name__)

def _validate_student_payload(data):
    if not isinstance(data, dict):
        return False, "JSON body required"
    for field in ("name", "age", "email"):
        if field not in data:
            return False, f"missing field: {field}"
    try:
        age = int(data["age"])
    except Exception:
        return False, "age must be an integer"
    return True, ""

# Create
@student_bp.route("/", methods=["POST"])
def add_student():
    data = request.get_json()
    ok, msg = _validate_student_payload(data)
    if not ok:
        return jsonify({"error": msg}), 400

    student = Student(name=data["name"], age=int(data["age"]), email=data["email"])
    db.session.add(student)
    try:
        db.session.commit()
    except IntegrityError as e:
        db.session.rollback()
        current_app.logger.warning("Integrity error while creating student: %s", e)
        return jsonify({"error": "email already exists"}), 400

    current_app.logger.info("Created student id=%s", student.id)
    return jsonify(student.to_dict()), 201

# Read all
@student_bp.route("/", methods=["GET"])
def get_students():
    students = Student.query.all()
    return jsonify([s.to_dict() for s in students]), 200

# Read by id
@student_bp.route("/<int:id>", methods=["GET"])
def get_student(id):
    student = Student.query.get_or_404(id)
    return jsonify(student.to_dict()), 200

# Update
@student_bp.route("/<int:id>", methods=["PUT"])
def update_student(id):
    student = Student.query.get_or_404(id)
    data = request.get_json() or {}
    # partial updates allowed
    if "name" in data:
        student.name = data["name"]
    if "age" in data:
        try:
            student.age = int(data["age"])
        except Exception:
            return jsonify({"error": "age must be an integer"}), 400
    if "email" in data:
        student.email = data["email"]

    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify({"error": "email already exists"}), 400

    current_app.logger.info("Updated student id=%s", student.id)
    return jsonify(student.to_dict()), 200

# Delete
@student_bp.route("/<int:id>", methods=["DELETE"])
def delete_student(id):
    student = Student.query.get_or_404(id)
    db.session.delete(student)
    db.session.commit()
    current_app.logger.info("Deleted student id=%s", id)
    return jsonify({"message": "Student deleted"}), 200
