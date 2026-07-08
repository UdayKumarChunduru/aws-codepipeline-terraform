import pytest
from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as c:
        yield c


def test_health_returns_200(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"


def test_index_returns_service_name(client):
    resp = client.get("/")
    data = resp.get_json()
    assert data["service"] == "flask-app"
    assert "version" in data
