# tests/test_pictures.py
def test_pictures_crud(client):
    # Pré-requis : species + feathers
    client.post("/species", json={"species_name": "Swan"})
    client.post("/feathers", json={"species_idspecies": 1})

    # Create
    payload = {
        "url": "https://cdn.example.com/pic.jpg",
        "longitude": "1.23",
        "latitude": "45.67",
        "date_collected": "2025-10-29",
        "feathers_idfeathers": 1
    }
    r = client.post("/pictures", json=payload)
    assert r.status_code == 201
    created = r.json()
    assert created["idpictures"] == 1
    assert created["url"].endswith(".jpg")

    # Get
    r = client.get("/pictures/1")
    assert r.status_code == 200
    got = r.json()
    assert got["feathers_idfeathers"] == 1

    # Delete
    r = client.delete("/pictures/1")
    assert r.status_code == 204

    # Not found
    r = client.get("/pictures/1")
    assert r.status_code == 404
