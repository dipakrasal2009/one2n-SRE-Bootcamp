# Student CRUD REST API (Flask)

## Overview
A simple REST API to create, read, update, delete students. Uses Flask, SQLAlchemy and Flask-Migrate.

## Setup
1. python3 -m venv venv
2. source venv/bin/activate
3. pip install -r requirements.txt
4. cp .env.example .env (edit DATABASE_URL if desired)
5. FLASK_APP=run.py flask db init
6. FLASK_APP=run.py flask db migrate -m "create students table"
7. FLASK_APP=run.py flask db upgrade
8. python run.py

## API Endpoints
- POST /api/v1/students/  (create)
- GET /api/v1/students/   (list)
- GET /api/v1/students/<id> (get)
- PUT /api/v1/students/<id> (update)
- DELETE /api/v1/students/<id> (delete)
- GET /healthcheck

## Testing
Run `pytest -q`
