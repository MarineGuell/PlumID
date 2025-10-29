# tests/test_health.py
def test_health_ok(client):
    r = client.get("/health")
    assert r.status_code == 200
    body = r.json()
    assert body["status"] == "ok"
    assert "latency_ms" in body
    # header de tracing
    assert "x-trace-id" in r.headers or "X-Trace-Id" in {k.title(): v for k, v in r.headers.items()}
