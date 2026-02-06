import pytest
from app.main import app

@pytest.fixture
def client():
    """Configures the app for testing and returns a test client."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client):
    """Test that /health returns 200 and the correct status."""
    response = client.get('/api/v1/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "OK"
    assert data["version"] == "1.0"

def test_get_all_servers(client):
    """Test that /servers returns the list of servers and the correct count."""
    response = client.get('/api/v1/servers')
    assert response.status_code == 200
    data = response.get_json()
    assert "servers" in data
    assert data["count"] == 2
    assert len(data["servers"]) == 2

def test_get_server_by_id_success(client):
    """Test that /servers/1 returns the specific server."""
    response = client.get('/api/v1/servers/1')
    assert response.status_code == 200
    data = response.get_json()
    assert data["id"] == 1
    assert data["hostname"] == "web-prod-01"

def test_get_server_by_id_not_found(client):
    """Test that /servers/999 returns a 404 error."""
    response = client.get('/api/v1/servers/999')
    assert response.status_code == 404
    data = response.get_json()
    assert data["error"] == "Server not found"