# Plum’ID — API

API REST pour Plum’ID (reconnaissance d’images de plumes).
Stack : **FastAPI**, **SQLAlchemy**, **MySQL** (ou SQLite en dev), **JWT** (optionnel), **API Key** (service-to-service).

* **Docs interactives** : `http://localhost:8000/docs` (Swagger)
* **Schéma OpenAPI** : `http://localhost:8000/openapi.json`

---

## Sommaire

1. [Prérequis](#prérequis)
2. [Configuration (.env)](#configuration-env)
3. [Installation & Lancement](#installation--lancement)
4. [Authentification](#authentification)
5. [Endpoints](#endpoints)

   * [Health](#health)
   * [Species](#species)
   * [Feathers](#feathers)
   * [Pictures](#pictures)
   * [Auth Utilisateurs (optionnel)](#auth-utilisateurs-optionnel)
6. [Modèles de données](#modèles-de-données)
7. [Conventions & Erreurs](#conventions--erreurs)
8. [Déploiement](#déploiement)

---

## Prérequis

* Python 3.10+
* MySQL 8+ (ou SQLite pour du local rapide)
* `pip` / `uvicorn` / `virtualenv` (ou `poetry` si tu préfères)

---

## Configuration (.env)

Crée un fichier `.env` à la racine (un `.env.example` est fourni) :

```env
# --- API KEY (service-to-service)
PLUM_ID_API_KEY=change_me_for_internal_calls

# --- AUTH JWT (si comptes utilisateurs activés)
AUTH_SECRET=change_this_to_a_long_random_secret
ACCESS_TOKEN_EXPIRE_MINUTES=60

# --- CORS (CSV d'origines autorisées)
CORS_ALLOW_ORIGINS=http://localhost:5173,http://localhost:3000

# --- DB (choisir l’une des 2 approches)
# 1) URL complète
DATABASE_URL=mysql+pymysql://plumid:password@localhost:3306/bird_db?charset=utf8mb4
# 2) Ou champs unitaires (si DATABASE_URL vide)
IP_DB=localhost
DB_PORT=3306
DB_USER=plumid
DB_PASSWORD=password
DB_NAME=bird_db
DB_CHARSET=utf8mb4

# Pool & SSL (optionnels)
DB_POOL_SIZE=5
DB_MAX_OVERFLOW=10
#MYSQL_SSL_CA=/etc/ssl/certs/rds-combined-ca-bundle.pem
```

---

## Installation & Lancement

```bash
# 1) Créer un venv
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# 2) Dépendances
pip install -r requirements.txt

# 3) Lancer l’API
uvicorn api.main:app --reload --port 8000
```

L’API écoute par défaut sur `http://localhost:8000`.

---

## Authentification

### 1) API Key (service-to-service)

Pour les appels internes, ajoute l’en-tête HTTP :

```
Authorization: Bearer <PLUM_ID_API_KEY>
```

Exemple `curl` :

```bash
curl -H "Authorization: Bearer $PLUM_ID_API_KEY" http://localhost:8000/health
```

### 2) JWT (comptes utilisateurs) — optionnel

Si activé, on utilise un **access token** JWT (HS256).

* `POST /auth/register` : créer un compte (email + password)
* `POST /auth/login` : obtenir un `access_token`
* `GET /auth/me` : récupérer le profil courant (via `Authorization: Bearer <access_token>`)

> Les routes métier (species/feathers/pictures) peuvent être protégées soit par API Key, soit par `get_current_user` (JWT), selon ton choix dans le code.

---

## Endpoints

### Health

* `GET /health` → ping, latence et en-tête de traçage

Exemple :

```bash
curl http://localhost:8000/health
# {
#   "status": "ok",
#   "latency_ms": 0.2
# }
# Réponse contient aussi l’en-tête: X-Trace-Id: <id>
```

---

### Species

* `POST /species`
  **Body JSON** (ex) :

  ```json
  {
    "sex": "male",
    "region": "Europe",
    "environment": "forest",
    "information": "Common in coniferous forests",
    "species_name": "Great Tit"
  }
  ```

  **Réponse 201** :

  ```json
  {
    "idspecies": 1,
    "sex": "male",
    "region": "Europe",
    "environment": "forest",
    "information": "Common in coniferous forests",
    "species_name": "Great Tit"
  }
  ```

* `GET /species/{idspecies}`
  **Réponse 200** :

  ```json
  {
    "idspecies": 1,
    "sex": "male",
    "region": "Europe",
    "environment": "forest",
    "information": "Common in coniferous forests",
    "species_name": "Great Tit"
  }
  ```

* `DELETE /species/{idspecies}`
  **Réponse** : `204 No Content`

---

### Feathers

* `POST /feathers`
  **Body JSON** :

  ```json
  {
    "side": "left",
    "type": "primary",
    "body_zone": "wing",
    "species_idspecies": 1
  }
  ```

  **Réponse 201** :

  ```json
  {
    "idfeathers": 1,
    "side": "left",
    "type": "primary",
    "body_zone": "wing",
    "species_idspecies": 1
  }
  ```

* `GET /feathers/{idfeathers}` → **200** : objet, **404** si absent

* `DELETE /feathers/{idfeathers}` → **204**

---

### Pictures

* `POST /pictures`
  **Body JSON** :

  ```json
  {
    "url": "https://cdn.example.com/img/feather_001.jpg",
    "longitude": "1.2345",
    "latitude": "43.5678",
    "date_collected": "2025-10-29",
    "feathers_idfeathers": 1
  }
  ```

  **Réponse 201** :

  ```json
  {
    "idpictures": 1,
    "url": "https://cdn.example.com/img/feather_001.jpg",
    "longitude": "1.2345",
    "latitude": "43.5678",
    "date_collected": "2025-10-29",
    "feathers_idfeathers": 1
  }
  ```

* `GET /pictures/{idpictures}` → **200** : objet, **404** si absent

* `DELETE /pictures/{idpictures}` → **204**

> Remarque : pour l’upload réel d’images, tu peux :
>
> * stocker un **URL** vers un CDN (S3, GCS, etc.),
> * ou ajouter un endpoint d’upload **multipart/form-data**,
> * ou générer des **pre-signed URLs** (recommandé en cloud).

---

### Auth Utilisateurs (optionnel)

* `POST /auth/register`
  **Body JSON** :

  ```json
  { "email": "user@example.com", "password": "StrongPassw0rd!", "username": "birdlover" }
  ```

  **Réponse 201** :

  ```json
  { "id": 1, "email": "user@example.com", "username": "birdlover", "is_active": true }
  ```

* `POST /auth/login`
  **Body JSON** :

  ```json
  { "email": "user@example.com", "password": "StrongPassw0rd!" }
  ```

  **Réponse 200** :

  ```json
  { "access_token": "<jwt>", "token_type": "bearer" }
  ```

* `GET /auth/me` (header `Authorization: Bearer <jwt>`)
  **Réponse 200** :

  ```json
  { "id": 1, "email": "user@example.com", "username": "birdlover", "is_active": true }
  ```

---

## Modèles de données

### Table `species`

* `idspecies` (PK, int, auto)
* `sex` (varchar 45)
* `region` (varchar 45)
* `environment` (varchar 45)
* `information` (varchar 255)
* `species_name` (varchar 100)

### Table `feathers`

* `idfeathers` (PK, int, auto)
* `side` (varchar 45)
* `type` (varchar 45)
* `body_zone` (varchar 45)
* `species_idspecies` (FK → `species.idspecies`, **CASCADE**)

### Table `pictures`

* `idpictures` (PK, int, auto)
* `url` (varchar 255)
* `longitude` (varchar 45)
* `latitude` (varchar 45)
* `date_collected` (date)
* `feathers_idfeathers` (FK → `feathers.idfeathers`, **CASCADE**)

### Table `users` (si auth comptes active)

* `idusers` (PK, int, auto)
* `mail` (unique, varchar 255)
* `username` (varchar 100)
* `password_hash` (varchar 255, **bcrypt/argon2**)
* `role` (varchar 45)
* `created_at` (datetime, default now)
* `pictures_idpictures` (FK → `pictures.idpictures`, **SET NULL**)

---

## Conventions & Erreurs

* **Traçage** : chaque réponse HTTP inclut `X-Trace-Id`. Les logs contiennent méthode, chemin, latence, trace.
* **Formats** : JSON en entrée/sortie, `application/json`.
* **Codes** :

  * `200` : OK
  * `201` : créé
  * `204` : supprimé / sans contenu
  * `400` : entrée invalide
  * `401` : auth manquante/échouée
  * `403` : interdit (API Key invalide, etc.)
  * `404` : ressource introuvable
  * `422` : validation Pydantic
  * `500` : erreur interne

---

## Déploiement

* **Uvicorn/Gunicorn** derrière un reverse proxy (Traefik/Nginx).
* **DB** : MySQL 8+, charset `utf8mb4`.
* **Migrations** : passer à **Alembic** pour les évolutions de schéma.
* **CORS** : restreindre `CORS_ALLOW_ORIGINS` en prod (liste blanche).
* **Secrets** : variables d’environnement (pas en clair dans git).
* **Logs** : niveau via `LOG_LEVEL`; surveiller latences et erreurs.

---

### Exemples `curl` rapides

```bash
# Créer une espèce
curl -X POST http://localhost:8000/species \
  -H "Content-Type: application/json" \
  -d '{"species_name":"Great Tit","region":"Europe"}'

# Récupérer une plume
curl http://localhost:8000/feathers/1

# Créer une photo
curl -X POST http://localhost:8000/pictures \
  -H "Content-Type: application/json" \
  -d '{"url":"https://cdn/img.jpg","feathers_idfeathers":1}'
```