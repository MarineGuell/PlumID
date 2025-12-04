# tests/api/test_antispam.py
import base64, hashlib, hmac, time
from fastapi.testclient import TestClient
from api.settings import settings
from api import main as main_module

def _sign(method, path, body: bytes, secret: str, nonce: str):
    ts = str(int(time.time()))
    body_hash = hashlib.sha256(body or b"").hexdigest()
    msg = f"{method}|{path}|{ts}|{nonce}|{body_hash}".encode()
    mac = hmac.new(secret.encode(), msg, hashlib.sha256).digest()
    sig = base64.b64encode(mac).decode()
    return {"X-Timestamp": ts, "X-Nonce": nonce, "X-Signature": sig}

def test_rate_limit_basic(monkeypatch):
    # Baisse la limite par défaut à 3 req/min pour le test
    monkeypatch.setenv("RL_DEFAULT_PER_MIN", "3")
    client = TestClient(main_module.app)

    ok = 0
    for i in range(5):
        r = client.get("/health")
        # /health est whiteliste → jamais ratelimité dans notre impl
        assert r.status_code == 200
        ok += 1
    assert ok == 5

def test_rate_limit_custom_path(monkeypatch):
    # Force limite très basse et cible un chemin non-whitelisté
    monkeypatch.setenv("RL_DEFAULT_PER_MIN", "2")
    # Recrée un client (les settings sont lus au démarrage généralement)
    client = TestClient(main_module.app)

    r1 = client.get("/health")
    r2 = client.get("/species/1")
    r3 = client.get("/species/1")
    # le troisième doit éventuellement passer en 429 selon fenêtre; pour garantir:
    # on spamme plus
    r4 = client.get("/species/1")
    assert r4.status_code in (200, 404, 429)  # selon cache actuel
    # Pour un test stable, on fait 10 req d'un coup :
    hits = [client.get("/species/1").status_code for _ in range(10)]
    assert 429 in hits  # on observe bien du throttling

def test_signed_upload(monkeypatch):
    client = TestClient(main_module.app)
    body = b"hello"
    hdrs = _sign("POST", "/upload/feather", body, settings.app_hmac_secret, nonce="n-123")
    r = client.post("/upload/feather", files={"file": ("f.txt", body)}, headers=hdrs)
    assert r.status_code == 200

def test_signed_upload_replay(monkeypatch):
    client = TestClient(main_module.app)
    body = b"hello"
    hdrs = _sign("POST", "/upload/feather", body, settings.app_hmac_secret, nonce="n-dup")
    r1 = client.post("/upload/feather", files={"file": ("f.txt", body)}, headers=hdrs)
    r2 = client.post("/upload/feather", files={"file": ("f.txt", body)}, headers=hdrs)
    # Le second doit échouer pour cause de replay
    assert r1.status_code == 200
    assert r2.status_code in (409, 401)
