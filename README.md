# Plum'ID — Identification d’espèces d’oiseaux à partir d’une plume

## 🌍 Présentation du projet

**Plum'ID** est une application de reconnaissance d’image permettant d’identifier une **espèce d’oiseau à partir d’une photo de plume**.

Le projet combine **vision par ordinateur** et **analyse contextuelle** (géographique et temporelle) pour améliorer la précision des prédictions.  
Grâce à l’intelligence artificielle, Plum’ID aide les utilisateurs — promeneurs, naturalistes, enseignants, écologues — à découvrir les oiseaux qui les entourent et à mieux comprendre la biodiversité.

---

## 🎯 Objectifs

- 🧠 Créer un **modèle d’intelligence artificielle** capable de reconnaître une espèce d’oiseau à partir d’une photo de plume.  
- 🗺️ Utiliser les **données GPS et temporelles** pour pondérer les prédictions selon la zone géographique et la saison.  
- 💡 Développer une **interface intuitive** adaptée à un large public (web ou mobile).  
- 🌱 Sensibiliser à la **préservation de la biodiversité** et faciliter les travaux des **chercheurs en ornithologie**.

---

## 👥 Équipe projet

| Nom | Rôle / spécialité |
|------|-------------------|
| **Marine Guell** | Coordination & design |
| **Paul Berdier** | Data Science & IA |
| **Louis** | Backend / API |
| **Théo** | Frontend |
| **Yann** | Infrastructure & DevOps |
| **Fabien** | IA / Entraînement du modèle |
| **Anass** | Collecte & annotation des données |
| **Marc Ezechiel** | UX / UI |
| **Amdjad** | Géolocalisation & intégration |
| **Laura** | Communication & documentation |
| **Loïc** | Base de données & structure |
| **Mathis** | Tests & qualité |

---

## 🧩 Fonctionnalités principales (prévisionnelles)

| Fonctionnalité | Description |
|----------------|-------------|
| 📷 **Reconnaissance d’image** | Identification d’espèces à partir d’une photo de plume |
| 🧭 **Localisation GPS** | Pondération selon la région et la saison |
| 🕓 **Filtrage temporel** | Prédictions ajustées selon la période d’observation |
| 📊 **Probabilités d’espèces** | Classement des résultats avec taux de confiance |
| 📚 **Fiches informatives** | Nom latin, habitat, statut, images comparatives |
| 💾 **Historique utilisateur** | Enregistrement des observations |
| 🌐 **Mode hors-ligne (optionnel)** | Reconnaissance sans connexion Internet |

---

## 🗂️ Architecture générale

À terme, le projet Plum’ID sera composé de plusieurs briques :

- **API Plum’ID** (FastAPI, Python)  
- **Modèle IA de reconnaissance** (service dédié, HTTP/gRPC)  
- **Front Web / Application** (SPA ou mobile)  
- **Base de données** (MySQL)  
- (Optionnel) **Storage objet** pour les images (S3 / MinIO)

Dans ce dépôt, la première brique mise en place est l’**API Plum’ID** (dossier `api/`), déjà prête pour :

- la gestion des **utilisateurs** (auth, JWT, vérification d’email, reset mot de passe),
- la gestion des **espèces**, **plumes** et **photos**,
- une exposition en **Docker** et en **Kubernetes**.

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
````

---

## ⚙️ Configuration (Backend API)

L’API lit sa configuration via des **variables d’environnement** (gérées par `api/settings.py`).

Principaux paramètres :

* **Base de données**

  * `DATABASE_URL` (recommandé)
    Exemple :
    `mysql+pymysql://plumid:password@localhost:3306/plumid?charset=utf8mb4`

* **Auth & JWT**

  * `AUTH_SECRET` : secret pour signer les JWT
  * `ACCESS_TOKEN_EXPIRE_MINUTES` : durée de vie des tokens

* **API Key service-to-service**

  * `PLUMID_API_KEY`

* **CORS**

  * `CORS_ALLOW_ORIGINS` : CSV d’origines autorisées
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

# 4) Lancer l’API
uvicorn api.main:app --reload --port 8000
```

L’API est alors disponible sur :
👉 `http://localhost:8000`
Docs interactives :
👉 `http://localhost:8000/docs`

---

## 🐳 Utilisation avec Docker

### 1. Image Docker de l’API

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

Build de l’image depuis la racine du projet :

```bash
docker build -t plumid-api ./api
```

Lancer l’API en container :

```bash
docker run --rm -p 8000:8000 \
  -e DATABASE_URL="mysql+pymysql://plumid:password@host.docker.internal:3306/plumid?charset=utf8mb4" \
  -e AUTH_SECRET="change_me_in_prod" \
  -e PLUMID_API_KEY="super_token" \
  plumid-api
```

### 2. Stack locale avec Docker Compose (API + MySQL)

Exemple de `docker-compose.yml` minimal (à la racine du projet) :

```yaml
version: "3.9"

services:
  db:
    image: mysql:8.0
    container_name: plumid-db
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
* MySQL : `localhost:3306` (user `plumid`, password `plumid_password`)

Plus tard, d’autres services (front web, modèle IA) pourront être ajoutés au `docker-compose.yml`.

---

## ☸️ Déploiement sur Kubernetes (API)

Pour une infra plus “prod” (multi-services, HA, scaling), Plum’ID est pensé pour tourner sur Kubernetes.

### 1. Pré-requis

* Cluster Kubernetes (K3s, k8s managé, Minikube…)
* Ingress Controller (ex : Nginx Ingress)
* Un registry Docker accessible par le cluster (GitHub Container Registry, Harbor, etc.)

### 2. Build & push de l’image

```bash
# Exemple avec un registry custom
docker build -t registry.example.com/plumid-api:latest ./api
docker push registry.example.com/plumid-api:latest
```

Mettre à jour l’image dans `k8s/api-deployment.yaml` :

```yaml
image: registry.example.com/plumid-api:latest
```

### 3. Manifests Kubernetes

Les manifests se trouvent dans `k8s/` :

* `namespace.yaml` : namespace dédié `plumid`
* `api-configmap.yaml` : config non sensible (CORS, FRONTEND_BASE_URL, log…)
* `api-secret.yaml` : secrets (DATABASE_URL, AUTH_SECRET, SMTP_USER/PASSWORD…)
* `api-deployment.yaml` : déploiement de l’API (2 replicas, probes)
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

Une fois l’Ingress résolu (DNS ou /etc/hosts), l’API est accessible sur :

```text
https://api.plumid.example.com
```

---

## 🔭 Roadmap technique

* [ ] Intégration du **service modèle IA** (service `plumid-ml` dédié, HTTP/gRPC)
* [ ] Ajout du **frontend web** (`plumid-web`) dans Docker & Kubernetes
* [ ] Mise en place d’un **worker async** (pré-traitement images, batch IA)
* [ ] Migrations DB avec **Alembic**
* [ ] Monitoring & observabilité (Prometheus, Grafana, logs centralisés)
