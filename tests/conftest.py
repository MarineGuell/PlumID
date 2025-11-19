# tests/conftest.py
from __future__ import annotations
import os
import sys
import itertools
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

# 0) Forcer une clé d'API simple pour les tests
os.environ.setdefault("PLUM_ID_API_KEY", "test-api-key")

# 1) S'assurer que la racine du repo est sur le PYTHONPATH (dossier parent de "tests")
REPO_ROOT = Path(__file__).resolve().parents[1]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

# 2) Importer l'app FastAPI
from api import main as main_module  # noqa: E402


# ----------------- Fake "ORM session" très simple (stockage en mémoire) -----------------

class _Store:
    def __init__(self):
        # dict[ModelName] -> {id -> dict(data)}
        self.data = {
            "species": {},
            "feathers": {},
            "pictures": {},
        }
        # compteurs d'auto-incrément
        self.counters = {
            "species": itertools.count(start=1),
            "feathers": itertools.count(start=1),
            "pictures": itertools.count(start=1),
        }

    def _ns(self, name: str):
        return self.data[name], self.counters[name]

    def create(self, name: str, payload: dict, id_field: str):
        ns, counter = self._ns(name)
        new_id = next(counter)
        row = dict(payload)
        row[id_field] = new_id
        ns[new_id] = row
        return row

    def get(self, name: str, id_field: str, obj_id: int) -> dict | None:
        ns, _ = self._ns(name)
        return ns.get(obj_id)

    def delete(self, name: str, obj_id: int) -> bool:
        ns, _ = self._ns(name)
        return ns.pop(obj_id, None) is not None


class ModelAdapter:
    """Enveloppe un 'row' (dict) pour mimer un objet ORM minimal."""
    __tablename__ = None
    __name__ = None
    __id_field__ = None

    def __init__(self, name: str, id_field: str, data: dict):
        self.__tablename__ = name
        self.__name__ = name
        self.__id_field__ = id_field
        self.data = data

    def __getattr__(self, item):
        if item in self.data:
            return self.data[item]
        raise AttributeError(item)


class FakeSession:
    """Session factice : simule .add/.commit/.refresh/.get/.delete et auto-incrémente les IDs."""
    def __init__(self, store: _Store):
        self.store = store

    # ----------- helpers internes -----------
    def _model_to_namespace(self, obj_or_cls):
        name = getattr(obj_or_cls, "__tablename__", None)
        if name in ("species", "feathers", "pictures"):
            return name
        # fallback : certains modèles n'ont pas __tablename__ en test
        # on mappe par nom de classe si besoin
        cls_name = getattr(obj_or_cls, "__name__", "")
        return {"Species": "species", "Feathers": "feathers", "Pictures": "pictures"}.get(cls_name, None)

    def _id_field_for(self, namespace: str) -> str:
        return {
            "species": "idspecies",
            "feathers": "idfeathers",
            "pictures": "idpictures",
        }[namespace]

    def _extract_payload(self, obj) -> dict:
        # extrait les attributs utiles depuis un éventuel objet ORM
        data = {}
        for k, v in vars(obj).items():
            if k.startswith("_"):        # ignore _sa_instance_state etc.
                continue
            data[k] = v
        return data

    # ----------- API simulée -----------
    def add(self, obj):
        """
        Simule un INSERT :
        - détecte la table cible
        - crée la ligne en mémoire (store)
        - affecte l'ID auto-généré à l'objet (obj.id*)
        """
        namespace = self._model_to_namespace(obj)
        if not namespace:
            # objet inconnu → no-op (mais on garde l'API silencieuse)
            self._last_added = obj
            return

        id_field = self._id_field_for(namespace)
        payload = self._extract_payload(obj)
        row = self.store.create(namespace, payload, id_field)

        # hydrate l'objet (comme ferait .refresh)
        for k, v in row.items():
            setattr(obj, k, v)

        self._last_added = obj

    def commit(self):
        # rien à faire : tout est fait dans add()/delete()
        pass

    def refresh(self, obj):
        # déjà hydraté dans add(); ici no-op
        pass

    def get(self, model_cls, obj_id: int):
        namespace = self._model_to_namespace(model_cls)
        if not namespace:
            return None
        id_field = self._id_field_for(namespace)
        row = self.store.get(namespace, id_field, obj_id)
        if not row:
            return None
        return ModelAdapter(namespace, id_field, row)

    def delete(self, obj):
        """
        Accepte soit un ModelAdapter (renvoyé par get),
        soit un objet ORM (ayant l'attribut id*).
        """
        if isinstance(obj, ModelAdapter):
            namespace = obj.__name__
            id_field = obj.__id_field__
            obj_id = obj.data[id_field]
            self.store.delete(namespace, obj_id)
            return

        # si c'est un ORM-like
        namespace = self._model_to_namespace(obj)
        if not namespace:
            return
        id_field = self._id_field_for(namespace)
        obj_id = getattr(obj, id_field, None)
        if obj_id is not None:
            self.store.delete(namespace, obj_id)

# ----------------- Fixtures pytest -----------------

@pytest.fixture()
def store():
    return _Store()

@pytest.fixture()
def client(store):
    # Override de la dépendance FastAPI get_db -> FakeSession
    from api.db import get_db as real_get_db  # import tardif

    def fake_get_db():
        yield FakeSession(store)

    main_module.app.dependency_overrides[real_get_db] = fake_get_db
    return TestClient(main_module.app)

# Option: client qui ajoute automatiquement l'API key
@pytest.fixture()
def client_auth(client):
    class _C:
        def __init__(self, c):
            self._c = c
        def request(self, method, url, **kw):
            headers = kw.pop("headers", {}) or {}
            headers.setdefault("Authorization", "Bearer test-api-key")
            return self._c.request(method, url, headers=headers, **kw)
        def get(self, url, **kw):    return self.request("GET", url, **kw)
        def post(self, url, **kw):   return self.request("POST", url, **kw)
        def delete(self, url, **kw): return self.request("DELETE", url, **kw)
        def put(self, url, **kw):    return self.request("PUT", url, **kw)
        def patch(self, url, **kw):  return self.request("PATCH", url, **kw)
    return _C(client)
