# Plum'ID — Identification d'espèces d'oiseaux à partir d'une plume

## 🌍 Présentation du projet

**Plum'ID** est une application de reconnaissance d'image permettant d'identifier une **espèce d'oiseau à partir d'une photo de plume**.

Le projet combine **vision par ordinateur** et **analyse contextuelle** (géographique et temporelle) pour améliorer la précision des prédictions.  
Grâce à l'intelligence artificielle, Plum'ID aide les utilisateurs — promeneurs, naturalistes, enseignants, écologues — à découvrir les oiseaux qui les entourent et à mieux comprendre la biodiversité.

---

## 🎯 Objectifs

- 🧠 Créer un **modèle d'intelligence artificielle** capable de reconnaître une espèce d'oiseau à partir d'une photo de plume. 
- 💡 Développer une **interface mobile intuitive** adaptée à un large public.  
- 🌱 Sensibiliser à la **préservation de la biodiversité** et faciliter les travaux des **chercheurs en ornithologie**.

---

## 👥 Équipe projet

| Nom | Rôle / spécialité |
|------|-------------------|
| **Marine Guell** | Coordination & expertise métier |
| **Paul Berdier** | Backend / API - Infrastructure & DevOps |
| **Louis** | Base de données & structure - Collecte & annotation des données |
| **Théo** | IA / Entraînement du modèle - Collecte & annotation des données |
| **Yann** | Data science / IA / Entraînement du modèle |
| **Fabien** | Communication |
| **Anass** | Base de données & structure - Collecte & annotation des données |
| **Marc Ezechiel** | IA / Entraînement du modèle |
| **Amdjad** | Frontend |
| **Laura** | Frontend |
| **Loïc** | Frontend |
| **Mathis** | Frontend |

---

## 🧩 Fonctionnalités principales (prévisionnelles)

| Fonctionnalité | Description |
|----------------|-------------|
| 📷 **Reconnaissance d'image** | Identification d'espèces à partir d'une photo de plume |
| 📊 **Probabilités d'espèces** | Classement des résultats avec taux de confiance |
| 📚 **Fiches informatives** | Nom latin, habitat, statut, images comparatives |
| 💾 **Historique utilisateur** | Enregistrement des observations |

---

## 🗂️ Architecture générale

À terme, le projet Plum'ID sera composé de plusieurs briques :

- **API Plum'ID** (FastAPI, Python)  
- **Modèle IA de reconnaissance** (service dédié, HTTP/gRPC)  
- **Front Web / Application** (SPA ou mobile)  
- **Base de données** (MariaDB – compatible MySQL)  
- (Optionnel) **Storage objet** pour les images (S3 / MinIO)

Dans ce dépôt, la première brique mise en place est l'**API Plum'ID** (dossier `api/`), déjà prête pour :

- la gestion des **utilisateurs** (auth, JWT, vérification d'email, reset mot de passe),
- la gestion des **espèces**, **plumes** et **photos**,
- une exposition en **Docker** et en **Kubernetes**.

---

## 🗄️ Base de données

La base de données Plum'ID repose sur un modèle relationnel implémenté avec **MariaDB**, choisi pour sa simplicité, sa fiabilité et sa compatibilité avec MySQL.

### 📊 Modélisation

La structure de la base repose sur un **Modèle Conceptuel de Données (MCD)** comprenant les principales entités suivantes :

- `species` : informations sur les espèces d'oiseaux
- `feathers` : caractéristiques des plumes
- `pictures` : photos associées aux plumes (avec contexte géographique et temporel)
- `users` : gestion des utilisateurs et des accès

Ces entités sont reliées entre elles afin de garantir la cohérence des données et faciliter leur exploitation par l'application et les futurs modèles IA.

![MCD Plum'ID](docs/image_MCD.png)

> 💡 **Remarque :** placer le fichier image de votre MCD dans le dossier `docs/` à la racine du dépôt, sous le nom `mcd.png` (ou adapter le chemin ci-dessus en conséquence).

### 🔐 Gestion des accès

Plusieurs rôles utilisateurs ont été définis afin de sécuriser l'accès à la base de données :

| Rôle | Droits |
|------|--------|
| `db_admin` | Administration complète de la base |
| `plumid_app` | Accès pour l'application (lecture / écriture) |
| `plumid_editor` | Gestion des données sur certaines tables |
| `plumid_viewer` | Accès en lecture seule |
| `plumid_ia` | Accès aux données nécessaires à l'entraînement et à l'inférence |

Ce découpage permet de respecter le **principe du moindre privilège** et de sécuriser les interactions avec la base.

### 🌐 Accès distant et collaboration

La base de données est accessible à distance via un environnement réseau partagé (ex : Tailscale), permettant à plusieurs membres du projet de travailler simultanément sur une même instance.

Un mode opératoire de connexion ainsi que des scripts SQL (création, dump, initialisation) ont été mis en place pour faciliter la collaboration.

### 🧪 Qualité et tests

Des tests unitaires ont été définis afin de vérifier :

- les actions **autorisées** pour chaque rôle
- les actions **interdites** (sécurité)

Cela permet de garantir la fiabilité et la cohérence des accès à la base.

### 🤖 Données pour l'IA

La base de données est conçue pour supporter les futurs besoins liés à l'intelligence artificielle, notamment :

- stockage des images et métadonnées (date, localisation)
- exploitation des données pour l'entraînement du modèle
- intégration future des résultats de prédiction

---

## 🧱 Structure du dépôt (backend API)

```text
projet/
  api/
    Dockerfile
    .dockerignore
    requirements.txt
    __init__.py
    main.py
    db.py
    settings.py
    core/
      security.py
    models/
      base.py
      users.py
      species.py
      feathers.py
      pictures.py
    routes/
      auth.py
      health.py
      species.py
      feathers.py
      pictures.py
    services/
      email.py
    schemas/
      users.py
      ...
  k8s/
    namespace.yaml
    api-configmap.yaml
    api-secret.yaml
    api-deployment.yaml
    api-service.yaml
    api-ingress.yaml
  docs/
    mcd.png
```

---

## ⚙️ Configuration (Backend API)

L'API lit sa configuration via des **variables d'environnement** (gérées par `api/settings.py`).

Principaux paramètres :

* **Base de données**

  * `DATABASE_URL` (recommandé)
    Exemple (compatible MariaDB) :
    `mysql+pymysql://plumid:password@localhost:3306/plumid?charset=utf8mb4`

* **Auth & JWT**

  * `AUTH_SECRET` : secret pour signer les JWT
  * `ACCESS_TOKEN_EXPIRE_MINUTES` : durée de vie des tokens

* **API Key service-to-service**

  * `PLUMID_API_KEY`

* **CORS**

  * `CORS_ALLOW_ORIGINS` : CSV d'origines autorisées
    ex : `http://localhost:3000,https://plumid.example.com`

* **SMTP (vérification email + reset password)**

  * `SMTP_HOST`, `SMTP_PORT`
  * `SMTP_USER`, `SMTP_PASSWORD`
  * `SMTP_FROM`

---

## 🚀 Lancement local (sans Docker)

Depuis le dossier `api/` :

```bash
# 1) Créer un env Python
python -m venv .venv
# Linux / macOS
source .venv/bin/activate
# Windows
# .venv\Scripts\activate

# 2) Installer les dépendances
pip install -r requirements.txt

# 3) Exporter les variables d'environnement (ou .env)
export DATABASE_URL="mysql+pymysql://plumid:password@localhost:3306/plumid?charset=utf8mb4"
export AUTH_SECRET="change_me"
export PLUMID_API_KEY="super_token"

# 4) Lancer l'API
uvicorn api.main:app --reload --port 8000
```

L'API est alors disponible sur :
👉 `http://localhost:8000`
Docs interactives :
👉 `http://localhost:8000/docs`

---

## 🐳 Utilisation avec Docker

### 1. Image Docker de l'API

Le dossier `api/` contient un `Dockerfile` optimisé pour la prod :

```dockerfile
# api/Dockerfile
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . /app/api

RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build de l'image depuis la racine du projet :

```bash
docker build -t plumid-api ./api
```

Lancer l'API en container :

```bash
docker run --rm -p 8000:8000 \
  -e DATABASE_URL="mysql+pymysql://plumid:password@host.docker.internal:3306/plumid?charset=utf8mb4" \
  -e AUTH_SECRET="change_me_in_prod" \
  -e PLUMID_API_KEY="super_token" \
  plumid-api
```

### 2. Stack locale avec Docker Compose (API + MariaDB)

Exemple de `docker-compose.yml` minimal (à la racine du projet) :

```yaml
version: "3.9"

services:
  db:
    image: mariadb:10.6
    container_name: plumid-mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: plumid
      MYSQL_USER: plumid
      MYSQL_PASSWORD: plumid_password
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

  api:
    build:
      context: ./api
    container_name: plumid-api
    restart: unless-stopped
    depends_on:
      - db
    environment:
      DATABASE_URL: "mysql+pymysql://plumid:plumid_password@db:3306/plumid?charset=utf8mb4"
      AUTH_SECRET: "change_me_in_prod"
      PLUMID_API_KEY: "super_token"
      CORS_ALLOW_ORIGINS: "http://localhost:3000"
    ports:
      - "8000:8000"

volumes:
  db_data:
```

Lancement :

```bash
docker compose up --build
```

* API : `http://localhost:8000`
* MariaDB : `localhost:3306` (user `plumid`, password `plumid_password`)

Plus tard, d'autres services (front web, modèle IA) pourront être ajoutés au `docker-compose.yml`.

---

## ☸️ Déploiement sur Kubernetes (API)

Pour une infra plus "prod" (multi-services, HA, scaling), Plum'ID est pensé pour tourner sur Kubernetes.

### 1. Pré-requis

* Cluster Kubernetes (K3s, k8s managé, Minikube…)
* Ingress Controller (ex : Nginx Ingress)
* Un registry Docker accessible par le cluster (GitHub Container Registry, Harbor, etc.)

### 2. Build & push de l'image

```bash
# Exemple avec un registry custom
docker build -t registry.example.com/plumid-api:latest ./api
docker push registry.example.com/plumid-api:latest
```

Mettre à jour l'image dans `k8s/api-deployment.yaml` :

```yaml
image: registry.example.com/plumid-api:latest
```

### 3. Manifests Kubernetes

Les manifests se trouvent dans `k8s/` :

* `namespace.yaml` : namespace dédié `plumid`
* `api-configmap.yaml` : config non sensible (CORS, FRONTEND_BASE_URL, log…)
* `api-secret.yaml` : secrets (DATABASE_URL, AUTH_SECRET, SMTP_USER/PASSWORD…)
* `api-deployment.yaml` : déploiement de l'API (2 replicas, probes)
* `api-service.yaml` : Service de type ClusterIP (`plumid-api`)
* `api-ingress.yaml` : Ingress (ex : `api.plumid.example.com`)

Application des manifests :

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/api-configmap.yaml
kubectl apply -f k8s/api-secret.yaml
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/api-service.yaml
kubectl apply -f k8s/api-ingress.yaml
```

Vérification :

```bash
kubectl -n plumid get pods
kubectl -n plumid get svc
kubectl -n plumid get ingress
```

Une fois l'Ingress résolu (DNS ou /etc/hosts), l'API est accessible sur :

```text
https://api.plumid.example.com
```

---

## 🔭 Roadmap technique

* [ ] Intégration du **service modèle IA** (service `plumid-ml` dédié, HTTP/gRPC)
* [ ] Ajout du **frontend web** (`plumid-web`) dans Docker & Kubernetes
* [ ] Mise en place d'un **worker async** (pré-traitement images, batch IA)
* [ ] Migrations DB avec **Alembic**
* [ ] Monitoring & observabilité (Prometheus, Grafana, logs centralisés)
