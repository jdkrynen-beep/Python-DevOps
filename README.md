# API Inventory Python

Projet DevOps - API REST pour la gestion d'inventaire de serveurs avec pipeline CI/CD automatisé.

## Table des matières

- [Description](#description)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Tests](#tests)
- [Docker](#docker)
- [Pipeline CI/CD](#pipeline-cicd)
- [Équipe](#équipe)

## Description

API REST développée avec Flask permettant de gérer un inventaire de serveurs. Le projet implémente les bonnes pratiques DevOps incluant des tests automatisés, une conteneurisation optimisée et un pipeline CI/CD complet.

### Fonctionnalités

- Health check endpoint pour monitoring
- Liste complète des serveurs avec compteur
- Récupération d'un serveur spécifique par ID
- Gestion des erreurs 404 pour les ressources inexistantes

## Architecture
```
Python-DevOps/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── app/
│   └── main.py
├── tests/
│   └── test_api.py
├── Dockerfile
├── requirements.txt
└── README.md
```

## Prérequis

- Python 3.11 ou supérieur
- Docker (optionnel, pour la conteneurisation)
- Git

## Installation

### Installation locale
```bash
# Cloner le repository
git clone <repository-url>
cd Python-DevOps

# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate  # Sur Windows: venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt
```

### Dépendances

- Flask 3.0.0
- pytest 7.4.3
- flake8 6.1.0

## Utilisation

### Lancement de l'API
```bash
python app/main.py
```

L'API sera accessible sur `http://localhost:5000`

### Endpoints disponibles

#### Health Check
```
GET /api/v1/health
Réponse: {"status": "OK", "version": "1.0"}
```

#### Liste des serveurs
```
GET /api/v1/servers
Réponse: {"servers": [...], "count": 2}
```

#### Serveur spécifique
```
GET /api/v1/servers/{id}
Réponse: {"id": 1, "hostname": "web-prod-01", "ip": "10.0.0.1", "status": "up"}
```

#### Serveur inexistant
```
GET /api/v1/servers/999
Réponse: {"error": "Server not found"} (HTTP 404)
```

### Tests manuels avec curl
```bash
curl http://localhost:5000/api/v1/health
curl http://localhost:5000/api/v1/servers
curl http://localhost:5000/api/v1/servers/1
curl http://localhost:5000/api/v1/servers/999
```

## Tests

Le projet utilise PyTest pour les tests automatisés et Flake8 pour la qualité du code.

### Exécuter les tests
```bash
# Tests unitaires
pytest tests/ -v

# Vérification de la qualité du code
flake8 app/ --max-line-length=120 --exclude=__pycache__
```

### Couverture des tests

- Test du endpoint /health (code 200)
- Test de la liste des serveurs
- Test de récupération d'un serveur existant
- Test de gestion d'erreur 404 pour serveur inexistant

## Docker

### Construction de l'image
```bash
docker build -t inventory-api .
```

### Vérification de la taille
```bash
docker images inventory-api
```

L'image utilise une architecture multi-stage pour garantir une taille optimale inférieure à 100 MB.

### Exécution du container
```bash
docker run -p 5000:5000 inventory-api
```

### Architecture multi-stage

- **Stage 1 (builder)**: Installation des dépendances sur python:3.11-slim
- **Stage 2 (runtime)**: Copie sélective sur python:3.11-alpine avec utilisateur non-root

## Pipeline CI/CD

Le projet implémente un pipeline GitHub Actions automatisé avec 4 jobs principaux.

### Job 1: Tests et Qualité

- Installation de Python 3.11
- Installation des dépendances
- Analyse statique du code avec Flake8
- Exécution des tests PyTest

### Job 2: Build et Sécurité

- Construction de l'image Docker
- Vérification de la taille (< 100 MB)
- Tests fonctionnels du container
- Scan de sécurité avec Trivy

### Job 3: Pull Request Automatique

- Se déclenche uniquement sur la branche `dev`
- Crée automatiquement une PR vers `main`
- Inclut un résumé des validations effectuées

### Job 4: Déploiement Production

- Se déclenche uniquement sur la branche `main`
- Affiche les informations de déploiement (SHA, environnement, date)
- Simule un déploiement en production

### Déclencheurs

Le pipeline s'exécute automatiquement lors d'un push sur les branches:
- `main`: Jobs 1, 2 et 4
- `dev`: Jobs 1, 2 et 3

### Visualisation

Les exécutions du pipeline sont accessibles dans l'onglet Actions du repository GitHub.

## Git Flow

### Structure des branches

- `main`: Branche de production (protégée)
- `dev`: Branche d'intégration (protégée)
- `feature/*`: Branches de fonctionnalités

### Workflow de développement

1. Créer une branche feature depuis dev
2. Développer et tester localement
3. Créer une Pull Request vers dev
4. Code review par le Product Owner
5. Merge vers dev après validation
6. Le pipeline crée automatiquement une PR vers main
7. Validation et merge vers main pour le déploiement

## Équipe

### Organisation Agile

- **Product Owner**: Jean Daniel Krynen
- **Scrum Master**: Jean Charles Rousseau
- **Dev/Ops**: Konstantin Anđelkovic
- **Dev/Ops**: Ismail Alami

### Répartition des User Stories

- **US1 (API REST)**: Konstantin + JC
- **US2 (Dockerfile)**: JC + Ismail
- **US3 (Tests PyTest)**: Konstantin + JD
- **US4 (Pipeline CI/CD)**: JC + JD + Konstantin + Ismail

## Licence

Projet académique - EPSI 2026