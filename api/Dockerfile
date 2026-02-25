# api/Dockerfile
# Image Python légère pour la prod
FROM python:3.11-slim

# Empêche Python de générer des .pyc et force le flush stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Dossier de travail dans le container
WORKDIR /app

# Dépendances système minimales (pour certains paquets Python)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# 1) Installation des dépendances Python
# -----------------------------
# On copie uniquement requirements.txt d'abord pour profiter du cache Docker
COPY requirements.txt ./requirements.txt

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# -----------------------------
# 2) Copie du code dans /app/api
# -----------------------------
# IMPORTANT : on place ton package dans /app/api
# pour que les imports "from api.xxx import ..." fonctionnent.
COPY . /app/api

# -----------------------------
# 3) Création d'un user non-root
# -----------------------------
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Port exposé (FastAPI / Uvicorn)
EXPOSE 8000

# -----------------------------
# 4) Commande de démarrage
# -----------------------------
# Ton entrypoint est le module `api.main:app`
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
