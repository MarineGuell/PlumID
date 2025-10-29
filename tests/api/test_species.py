# tests/test_species.py
def test_species_crud(client):
    # Create
    payload = {
        "sex": "male",
        "region": "Europe",
        "environment": "forest",
        "information": "Common bird",
        "species_name": "Great Tit"
    }
    r = client.post("/species", json=payload)
    assert r.status_code == 201
    created = r.json()
    assert created["idspecies"] == 1
    assert created["species_name"] == "Great Tit"

    # Get
    r = client.get("/species/1")
    assert r.status_code == 200
    got = r.json()
    assert got["idspecies"] == 1
    assert got["region"] == "Europe"

    # Delete
    r = client.delete("/species/1")
    assert r.status_code == 204

    # Not found after delete
    r = client.get("/species/1")
    assert r.status_code == 404
