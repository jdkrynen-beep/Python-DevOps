# ============================================
# STAGE 1 : Builder
# ============================================
FROM python:3.11-slim AS builder

# Métadonnées
LABEL stage=builder
LABEL description="Build stage for Python dependencies"

# Définir le répertoire de travail
WORKDIR /build

# Copier uniquement requirements.txt pour profiter du cache Docker
COPY requirements.txt .

# Installer les dépendances dans un répertoire isolé
# --no-cache-dir : ne garde pas le cache pip (économie d'espace)
# --prefix=/install : installe dans un dossier dédié pour copie facile
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt

# ============================================
# STAGE 2 : Runtime
# ============================================
FROM python:3.11-alpine AS runtime

# Métadonnées
LABEL maintainer="techcorp-devops@example.com"
LABEL description="Inventory API - Optimized Production Image"
LABEL version="1.0.0"

# Variables d'environnement Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/install/bin:$PATH" \
    PYTHONPATH="/install/lib/python3.11/site-packages" \
    FLASK_APP=app.main \
    FLASK_ENV=production

# Créer un groupe et un utilisateur non-root pour la sécurité
RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser && \
    mkdir -p /app && \
    chown -R appuser:appgroup /app

# Définir le répertoire de travail
WORKDIR /app

# Copier les dépendances Python depuis le stage builder
COPY --from=builder /install /install

# Copier le code de l'application avec les bonnes permissions
COPY --chown=appuser:appgroup app/ ./app/

# Passer à l'utilisateur non-root
USER appuser

# Exposer le port 5000
EXPOSE 5000

# Healthcheck pour Docker Swarm/Kubernetes
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5000/api/v1/health || exit 1

# Point d'entrée de l'application
CMD ["python", "-m", "app.main"]
