import json

def test_healthcheck(client):
    resp = client.get("/healthcheck")
    assert resp.status_code == 200
    assert resp.json["status"] == "ok"

def test_crud_student(client):
    # Create
    payload = {"name": "Alice", "age": 21, "email": "alice@example.com"}
    resp = client.post("/api/v1/students/", json=payload)
    assert resp.status_code == 201
    data = resp.json
    assert data["name"] == "Alice"
    sid = data["id"]

    # Read all
    resp = client.get("/api/v1/students/")
    assert resp.status_code == 200
    assert isinstance(resp.json, list) and len(resp.json) == 1

    # Read by id
    resp = client.get(f"/api/v1/students/{sid}")
    assert resp.status_code == 200
    assert resp.json["email"] == "alice@example.com"

    # Update
    resp = client.put(f"/api/v1/students/{sid}", json={"age": 22})
    assert resp.status_code == 200
    assert resp.json["age"] == 22

    # Delete
    resp = client.delete(f"/api/v1/students/{sid}")
    assert resp.status_code == 200

    # Ensure gone
    resp = client.get(f"/api/v1/students/{sid}")
    assert resp.status_code == 404
