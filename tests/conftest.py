# tests/api/conftest.py
from __future__ import annotations
import os
import itertools
import types
import pytest
from fastapi.testclient import TestClient

# IMPORTANT : forcer une clé d'API simple si tu l'utilises
os.environ.setdefault("PLUM_ID_API_KEY", "test-api-key")

# ---- Fake "ORM session" très simple (stockage en mémoire) -----------------

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

    # helpers CRUD (façon très naïve, calée sur les noms de champs SQL)
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


class FakeSession:
    """
    Fake très simple : on n'instancie pas de vrais modèles SQLAlchemy,
    on attend des dicts côté routes (les schémas Pydantic nous donnent déjà des dicts).
    Si tes routes manipulent explicitement des classes ORM (Species(...)),
    on offrira quelques 'adapters' minimalistes.
    """
    def __init__(self, store: _Store):
        self.store = store

    # Adapters ultra-lights pour coller aux usages .add/.commit/.refresh/.get
    def add(self, obj):  # obj sera un "ModelAdapter"
        # on n'écrit rien ici; l'écriture se fait dans create_* des routes adaptées
        self._last_added = obj

    def commit(self): pass
    def refresh(self, obj): pass

    # Simule db.get(Model, id)
    def get(self, model_cls, obj_id: int):
        name = getattr(model_cls, "__tablename__", None)
        if name == "species":
            return self._wrap_model("species", "idspecies", obj_id)
        if name == "feathers":
            return self._wrap_model("feathers", "idfeathers", obj_id)
        if name == "pictures":
            return self._wrap_model("pictures", "idpictures", obj_id)
        return None

    def delete(self, obj):
        # obj est un ModelAdapter qui contient (name, id_field, data)
        name = obj.__name__
        id_field = obj.__id_field__
        obj_id = obj.data[id_field]
        self.store.delete(name, obj_id)

    # Helpers
    def _wrap_model(self, name: str, id_field: str, obj_id: int):
        row = self.store.get(name, id_field, obj_id)
        if not row:
            return None
        return ModelAdapter(name, id_field, row)


class ModelAdapter:
    """
    Enveloppe un 'row' (dict) pour mimer un objet ORM minimal :
    - accès par attributs
    - __tablename__, __name__, __id_field__ utiles dans FakeSession
    """
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


# ---- Fixtures pytest -------------------------------------------------------

@pytest.fixture()
def store():
    return _Store()

@pytest.fixture()
def client(monkeypatch, store):
    # 1) Import tardif pour pouvoir monkeypatcher get_db avant usage
    from api import main as main_module
    from api.db import get_db as real_get_db

    # 2) Override la dépendance FastAPI get_db -> yield FakeSession
    def fake_get_db():
        yield FakeSession(store)

    main_module.app.dependency_overrides[real_get_db] = fake_get_db

    # 3) Si des routers ont appelé Base.metadata.create_all(bind=engine) à l'import,
    #    on s'en fiche : on n'utilisera pas l'engine; tout passe par FakeSession.
    return TestClient(main_module.app)
