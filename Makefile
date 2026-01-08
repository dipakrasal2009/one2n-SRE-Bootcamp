install:
	pip install -r requirements.txt

run:
	python3 run.py

# migration helpers (FLASK_APP=run.py used inline)
migrate-init:
	FLASK_APP=run.py flask db init

migrate:
	FLASK_APP=run.py flask db migrate -m "auto migration"
	FLASK_APP=run.py flask db upgrade

test:
	pytest -q
