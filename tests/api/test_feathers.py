# tests/test_feathers.py
def test_feathers_crud(client):
    # prérequis: une species id=1
    client.post("/species", json={"species_name": "Sparrow"})

    # Create
    payload = {
        "side": "left",
        "type": "primary",
        "body_zone": "wing",
        "species_idspecies": 1
    }
    r = client.post("/feathers", json=payload)
    assert r.status_code == 201
    created = r.json()
    assert created["idfeathers"] == 1
    assert created["species_idspecies"] == 1

    # Get
    r = client.get("/feathers/1")
    assert r.status_code == 200
    got = r.json()
    assert got["body_zone"] == "wing"

    # Delete
    r = client.delete("/feathers/1")
    assert r.status_code == 204

    # Not found
    r = client.get("/feathers/1")
    assert r.status_code == 404
