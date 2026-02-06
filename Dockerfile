# ============================================
# STAGE 1 : Builder
# ============================================
FROM python:3.11-slim AS builder

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement les fichiers de dépendances d'abord (pour le cache Docker)
COPY requirements.txt .

# Installer les dépendances dans un répertoire spécifique
# --no-cache-dir : évite de garder le cache pip
# --prefix : installe dans un répertoire personnalisé
RUN pip install --no-cache-dir --prefix=/install --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt

# ============================================
# STAGE 2 : Runtime
# ============================================
FROM python:3.11-alpine AS runtime

# Métadonnées
LABEL maintainer="votre-email@example.com"
LABEL description="Application Flask optimisée < 100 MB"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/install/bin:$PATH" \
    PYTHONPATH="/install/lib/python3.11/site-packages"

# Créer un utilisateur non-root
RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser

# Définir le répertoire de travail
WORKDIR /app

# Copier les dépendances depuis le stage builder
COPY --from=builder /install /install

# Copier le code de l'application
COPY --chown=appuser:appgroup . .

# Passer à l'utilisateur non-root
USER appuser

# Exposer le port 5000
EXPOSE 5000

# Healthcheck (optionnel mais recommandé)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5000/ || exit 1

# Commande de démarrage
CMD ["python", "app.py"]