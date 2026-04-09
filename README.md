# Plum'ID — Identification d’espèces d’oiseaux à partir d’une plume

- [Lien vers le projet API](https://github.com/MarineGuell/plumid-api)
- [Lien vers le projet modèle IA](https://github.com/MarineGuell/plumid-model)
- [Lien vers le projet de l'application mobile](https://github.com/MarineGuell/plumid-mobile)

## Présentation du projet

**Plum'ID** est une application de reconnaissance d’image permettant d’identifier une **espèce d’oiseau à partir d’une photo de plume**.

Le projet combine **vision par ordinateur** et **analyse contextuelle** (géographique et temporelle) pour améliorer la précision des prédictions.  
Grâce à l’intelligence artificielle, Plum’ID aide les utilisateurs — promeneurs, naturalistes, enseignants, écologues — à découvrir les oiseaux qui les entourent et à mieux comprendre la biodiversité.

## Objectifs

- Créer un **modèle d’intelligence artificielle** capable de reconnaître une espèce d’oiseau à partir d’une photo de plume.
- Développer une **interface mobile intuitive** adaptée à un large public.  
- Sensibiliser à la **préservation de la biodiversité** et faciliter les travaux des **chercheurs en ornithologie**.

## Équipe projet

| Nom | Rôle / spécialité |
| ------ | ------------------- |
| [**Marine Guell**](https://github.com/MarineGuell) | Coordination & expertise métier |
| [**Paul Berdier**](https://github.com/Paul-Berdier) | Backend / API - Infrastructure & DevOps |
| **Louis** | Base de données & structure - Collecte & annotation des données |
| **Théo** | IA / Entraînement du modèle - Collecte & annotation des données |
| **Yann** | Data science / IA / Entraînement du modèle |
| **Fabien** | Communication |
| [**Anass**](https://github.com/AnassHmadouch) | Base de données & structure - Collecte & annotation des données |
| [**Marc Ezechiel**](https://github.com/bakeze) | IA / Entraînement du modèle |
| [**Amdjad**](https://github.com/Maxiwere45) | Application Mobile & API |
| **Laura** | Application Mobile |
| **Loïc** | Application Mobile |
| **Mathis** | Application Mobile & API |

## Fonctionnalités principales (prévisionnelles)

| Fonctionnalité | Description |
| ---------------- | ------------- |
| **Reconnaissance d’image** | Identification d’espèces à partir d’une photo de plume |
| **Probabilités d’espèces** | Classement des résultats avec taux de confiance |
| **Fiches informatives** | Nom latin, habitat, statut, images comparatives |
| **Historique utilisateur** | Enregistrement des observations |

## Architecture générale

À terme, le projet Plum’ID sera composé de plusieurs briques :

- **API Plum’ID** (FastAPI, Python)  
- **Modèle IA de reconnaissance** (service dédié, HTTP/gRPC)  
- **Front Web / Application** (SPA ou mobile)  
- **Base de données** (MySQL)
- (Optionnel) **Storage objet** pour les images (S3 / MinIO)
