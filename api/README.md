# Plum’ID — API

API REST pour Plum’ID (reconnaissance d’images de plumes).  
Stack : **FastAPI**, **SQLAlchemy**, **MySQL** (ou SQLite en dev), **JWT** (comptes utilisateurs), **API Key** (service-to-service).

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
   * [Auth Utilisateurs](#auth-utilisateurs)  
6. [Modèles de données](#modèles-de-données)  
7. [Conventions & Erreurs](#conventions--erreurs)  
8. [Déploiement](#déploiement)  

---

## Prérequis

* Python **3.10+**
* MySQL **8+** (ou SQLite pour du local rapide)
* `pip` / `uvicorn` / `virtualenv` (ou `poetry`)

---

## Configuration (.env)

Créer un fichier `.env` à la racine du projet.

### Logs & API

```env
# --- LOGGING
LOG_LEVEL=INFO          # DEBUG / INFO / WARNING / ERROR
LOG_SENSITIVE=0         # 1 pour loguer plus de détails (à éviter en prod)
````

### API Key (service-to-service)

```env
# --- API KEY (service-to-service)
# Utilisée par le middleware d’auth interne (Bearer <token>)
PLUMID_API_KEY=change_me_for_internal_calls
```

### Auth JWT (comptes utilisateurs)

```env
# --- AUTH JWT (comptes utilisateurs)
AUTH_SECRET=change_this_to_a_long_random_secret
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

### CORS

```env
# --- CORS (CSV d'origines autorisées)
# Exemple pour front en localhost
CORS_ALLOW_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Base de données

Deux modes sont possibles :

#### 1) URL complète (recommandé)

```env
DATABASE_URL=mysql+pymysql://plumid:password@localhost:3306/bird_db?charset=utf8mb4
```

#### 2) Champs unitaires (si `DATABASE_URL` est vide)

```env
# Hôte & port
IP_DB=localhost          # alias supportés : DB_HOST
PORT_DB=3306             # alias supportés : DB_PORT

# Credentials
USER_DB=plumid           # alias : DB_USER
MDP_DB=password          # alias : DB_PASSWORD
NAME_DB=bird_db          # alias : DB_NAME
DB_CHARSET=utf8mb4

# Pool & SSL (optionnels)
DB_POOL_SIZE=5
DB_MAX_OVERFLOW=10
#MYSQL_SSL_CA=/etc/ssl/certs/rds-combined-ca-bundle.pem
```

Le code reconstruit un DSN MySQL si `DATABASE_URL` est vide.

---

## Installation & Lancement

```bash
# 1) Créer un venv
python -m venv .venv
# Linux / macOS
source .venv/bin/activate
# Windows
# .venv\Scripts\activate

# 2) Installer les dépendances
pip install -r requirements.txt

# 3) Lancer l’API
uvicorn api.main:app --reload --port 8000
```

L’API écoute par défaut sur `http://localhost:8000`.

---

## Authentification

L’API supporte **deux mécanismes distincts** :

1. **API Key** (service-to-service)
2. **JWT** (comptes utilisateurs / front)

Les routes métiers (`/species`, `/feathers`, `/pictures`) peuvent être protégées soit par l’API Key, soit par `get_current_user` (JWT) selon la config choisie dans le code.

---

### 1) API Key (service-to-service)

Pour les appels internes (jobs, micro-services, etc.) :

```http
Authorization: Bearer <PLUMID_API_KEY>
```

Exemple `curl` :

```bash
curl -H "Authorization: Bearer $PLUMID_API_KEY" http://localhost:8000/health
```

---

### 2) JWT (comptes utilisateurs)

Les comptes utilisateurs sont stockés dans la table `users`.

Endpoints :

* `POST /auth/register` — créer un compte
* `POST /auth/login` — obtenir un `access_token` JWT
* `GET /auth/me` — récupérer le profil courant

#### `POST /auth/register`

**Body JSON :**

```json
{
  "mail": "user@example.com",
  "username": "birdlover",
  "password": "StrongPassw0rd!"
}
```

**Réponse 201 :**

```json
{
  "idusers": 1,
  "mail": "user@example.com",
  "username": "birdlover",
  "role": "user"
}
```

#### `POST /auth/login`

**Body JSON :**

```json
{
  "mail": "user@example.com",
  "password": "StrongPassw0rd!"
}
```

**Réponse 200 :**

```json
{
  "access_token": "<jwt>",
  "token_type": "bearer"
}
```

#### `GET /auth/me`

**Headers :**

```http
Authorization: Bearer <jwt>
```

**Réponse 200 :**

```json
{
  "idusers": 1,
  "mail": "user@example.com",
  "username": "birdlover",
  "role": "user"
}
```

Le token est signé en **HS256** avec `AUTH_SECRET`.
La durée de vie est définie par `ACCESS_TOKEN_EXPIRE_MINUTES`.

---

## Endpoints

### Health

* `GET /health` — ping + latence + trace id

Exemple :

```bash
curl http://localhost:8000/health
```

**Réponse 200 :**

```json
{
  "status": "ok",
  "latency_ms": 0.23,
  "trace_id": "a1b2c3d4e5f6a7b8"
}
```

L’en-tête HTTP contient également :

```http
X-Trace-Id: a1b2c3d4e5f6a7b8
```

---

### Species

* `POST /species` — créer une espèce
* `GET /species/{idspecies}` — lire une espèce
* `DELETE /species/{idspecies}` — supprimer une espèce

#### `POST /species`

**Body JSON (ex) :**

```json
{
  "sex": "male",
  "region": "Europe",
  "environment": "forest",
  "information": "Common in coniferous forests",
  "species_name": "Great Tit"
}
```

**Réponse 201 :**

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

#### `GET /species/{idspecies}`

**Réponse 200 :**

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

**Réponse 404 :**

```json
{
  "error": {
    "code": "HTTP_404",
    "message": "Species not found",
    "trace_id": "..."
  }
}
```

#### `DELETE /species/{idspecies}`

**Réponse :** `204 No Content`

---

### Feathers

* `POST /feathers` — créer une plume
* `GET /feathers/{idfeathers}` — lire une plume
* `DELETE /feathers/{idfeathers}` — supprimer une plume

#### `POST /feathers`

**Body JSON :**

```json
{
  "side": "left",
  "type": "primary",
  "body_zone": "wing",
  "species_idspecies": 1
}
```

**Réponse 201 :**

```json
{
  "idfeathers": 1,
  "side": "left",
  "type": "primary",
  "body_zone": "wing",
  "species_idspecies": 1
}
```

#### `GET /feathers/{idfeathers}`

**Réponse 200 :**

```json
{
  "idfeathers": 1,
  "side": "left",
  "type": "primary",
  "body_zone": "wing",
  "species_idspecies": 1
}
```

#### `DELETE /feathers/{idfeathers}`

**Réponse :** `204 No Content`

---

### Pictures

* `POST /pictures` — déclarer une photo (URL + métadonnées)
* `GET /pictures/{idpictures}` — lire une photo
* `DELETE /pictures/{idpictures}` — supprimer une photo

#### `POST /pictures`

**Body JSON :**

```json
{
  "url": "https://cdn.example.com/img/feather_001.jpg",
  "longitude": "1.2345",
  "latitude": "43.5678",
  "date_collected": "2025-10-29",
  "feathers_idfeathers": 1
}
```

**Réponse 201 :**

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

#### `GET /pictures/{idpictures}`

**Réponse 200 :**

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

#### `DELETE /pictures/{idpictures}`

**Réponse :** `204 No Content`

> Pour l’upload réel d’images, il est recommandé d’utiliser :
>
> * un stockage externe (S3, GCS, MinIO, …) + champ `url`,
> * éventuellement des pre-signed URLs côté backend.

---

### Auth Utilisateurs

Voir la section [JWT (comptes utilisateurs)](#2-jwt-comptes-utilisateurs).

Résumé :

* `POST /auth/register`
* `POST /auth/login`
* `GET /auth/me`

Les réponses utilisent les champs de la table `users` :

```json
{
  "idusers": 1,
  "mail": "user@example.com",
  "username": "birdlover",
  "role": "user"
}
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
* `species_idspecies` (FK → `species.idspecies`, `ON DELETE CASCADE`)

### Table `pictures`

* `idpictures` (PK, int, auto)
* `url` (varchar 255)
* `longitude` (varchar 45)
* `latitude` (varchar 45)
* `date_collected` (date)
* `feathers_idfeathers` (FK → `feathers.idfeathers`, `ON DELETE CASCADE`)

### Table `users`

* `idusers` (PK, int, auto)
* `mail` (unique, varchar 255)
* `username` (varchar 100)
* `password_hash` (varchar 255, hashé via bcrypt)
* `role` (varchar 45, ex. `"user"`, `"admin"`)
* `created_at` (datetime, default `CURRENT_TIMESTAMP`)
* `pictures_idpictures` (FK → `pictures.idpictures`, `ON DELETE SET NULL`)

---

## Conventions & Erreurs

### Format d’erreur

Toutes les erreurs standardisées utilisent ce format :

```json
{
  "error": {
    "code": "HTTP_404",
    "message": "Resource not found",
    "trace_id": "a1b2c3d4e5f6a7b8",
    "hint": "Optionnel, message d'aide",
    "details": {
      "errors": [
        {
          "loc": ["body", "field"],
          "msg": "field required",
          "type": "value_error.missing"
        }
      ]
    }
  }
}
```

* `code` : code technique (ex. `HTTP_404`, `VALIDATION_ERROR`, `INTERNAL_ERROR`)
* `message` : message fonctionnel
* `trace_id` : ID de traçage (également renvoyé dans l’en-tête `X-Trace-Id`)
* `hint` : optionnel, conseils
* `details` : optionnel, détails Pydantic pour les erreurs 422

### Codes HTTP

* `200` : OK
* `201` : créé
* `204` : sans contenu (delete)
* `400` : entrée invalide
* `401` : authentification manquante ou invalide
* `403` : interdit (API Key invalide, rôle insuffisant…)
* `404` : ressource introuvable
* `422` : erreur de validation (Pydantic)
* `500` : erreur interne (non gérée)

---

## Déploiement

* **Serveur** : `uvicorn` ou `gunicorn` + worker `uvicorn.workers.UvicornWorker`
* **Reverse proxy** : Traefik / Nginx (TLS, compression, rate limiting…)
* **DB** : MySQL 8+, charset `utf8mb4`, pool configuré via env
* **Migrations** : utiliser **Alembic** pour les évolutions de schéma
* **CORS** : restreindre `CORS_ALLOW_ORIGINS` à une liste blanche en production
* **Secrets** : variables d’environnement (`AUTH_SECRET`, `PLUMID_API_KEY`, password DB…)
* **Monitoring** : logs niveaux `INFO`/`WARNING`, suivi des `trace_id`, métriques (latence, taux d’erreur…)

---

## Exemples `curl`

```bash
# Health check
curl http://localhost:8000/health

# Créer une espèce
curl -X POST http://localhost:8000/species \
  -H "Content-Type: application/json" \
  -d '{
        "species_name": "Great Tit",
        "region": "Europe",
        "sex": "male",
        "environment": "forest",
        "information": "Common in coniferous forests"
      }'

# Créer une plume
curl -X POST http://localhost:8000/feathers \
  -H "Content-Type: application/json" \
  -d '{
        "side": "left",
        "type": "primary",
        "body_zone": "wing",
        "species_idspecies": 1
      }'

# Créer une photo
curl -X POST http://localhost:8000/pictures \
  -H "Content-Type: application/json" \
  -d '{
        "url": "https://cdn.example.com/img/feather_001.jpg",
        "longitude": "1.2345",
        "latitude": "43.5678",
        "date_collected": "2025-10-29",
        "feathers_idfeathers": 1
      }'

# Inscription utilisateur
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
        "mail": "user@example.com",
        "username": "birdlover",
        "password": "StrongPassw0rd!"
      }'

# Login utilisateur
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
        "mail": "user@example.com",
        "password": "StrongPassw0rd!"
      }'

# Profil utilisateur courant (remplace <jwt> par le token reçu)
curl http://localhost:8000/auth/me \
  -H "Authorization: Bearer <jwt>"
```
