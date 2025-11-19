# Architecture PlumID Mobile

## 🎯 Vue d'ensemble

PlumID utilise une **Clean Architecture** combinée avec **Riverpod** pour la gestion d'état, garantissant une application scalable, testable et maintenable pour l'identification d'oiseaux à partir de photos de plumes.

## 📐 Principe des 3 couches

### 1️⃣ **Presentation** (Interface utilisateur)

```
presentation/
├── providers/              # State management (Riverpod)
│   ├── providers.dart      # Infrastructure & dependency injection
│   ├── identification_provider.dart
│   └── history_provider.dart
├── widgets/               # Widgets réutilisables communs
├── identification/        # Feature: Identification d'oiseaux
│   ├── screens/
│   │   └── home_screen.dart
│   └── widgets/
├── history/              # Feature: Historique
│   ├── screens/
│   └── widgets/
└── species_detail/       # Feature: Détails d'une espèce
    ├── screens/
    └── widgets/
```

**Responsabilités** :
- Afficher l'UI
- Gérer l'état via Riverpod
- Réagir aux interactions utilisateur
- Appeler les use cases via les providers

**Règles** :
- ❌ Pas de logique métier
- ❌ Pas d'appels directs aux repositories
- ✅ Widgets purs et réactifs

---

### 2️⃣ **Domain** (Logique métier)

```
domain/
├── entities/             # Objets métier purs
│   ├── bird_species.dart
│   ├── prediction.dart
│   ├── location.dart
│   └── identification.dart
├── repositories/         # Interfaces (contrats)
│   ├── i_identification_repository.dart
│   ├── i_history_repository.dart
│   └── i_location_repository.dart
└── usecases/            # Logique métier
    ├── usecase.dart
    ├── identify_bird.dart
    ├── get_species_details.dart
    ├── get_history.dart
    ├── save_identification.dart
    └── get_current_location.dart
```

**Responsabilités** :
- Définir les règles métier
- Définir les contrats (interfaces)
- Orchestrer la logique applicative

**Règles** :
- ❌ Aucune dépendance externe (Flutter, Dio, etc.)
- ❌ Pas d'implémentation concrète
- ✅ Code 100% testable unitairement

---

### 3️⃣ **Data** (Sources de données)

```
data/
├── models/              # Modèles de données (JSON ↔ Entities)
│   ├── bird_species_model.dart
│   ├── prediction_model.dart
│   ├── location_model.dart
│   └── identification_model.dart
├── datasources/         # Appels API, cache local
│   ├── identification_remote_datasource.dart
│   ├── history_local_datasource.dart
│   └── location_datasource.dart
└── repositories/        # Implémentation des interfaces
    ├── identification_repository_impl.dart
    ├── history_repository_impl.dart
    └── location_repository_impl.dart
```

**Responsabilités** :
- Communiquer avec l'API, GPS, cache local
- Mapper les modèles ↔ entités
- Gérer les erreurs techniques

**Règles** :
- ✅ Implémente les interfaces du domain
- ✅ Gère la serialization/deserialisation (Freezed + json_serializable)
- ✅ Transforme exceptions → failures (Either)

---

## 🔄 Flux de données - Exemple : Identification d'un oiseau

```
┌─────────────────────────────────────────────────────┐
│  HomeScreen                                         │
│  (Utilisateur prend une photo)                      │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  IdentificationNotifier (Riverpod)                  │
│  (Gère l'état : loading, predictions, error)        │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  IdentifyBird UseCase                  [DOMAIN]     │
│  (Valide les paramètres, orchestre)                 │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  IIdentificationRepository            [DOMAIN]      │
│  (Interface : contrat)                              │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  IdentificationRepositoryImpl         [DATA]        │
│  (Implémentation concrète)                          │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  IdentificationRemoteDataSource       [DATA]        │
│  (Appel API avec Dio, multipart/form-data)          │
└─────────────────────────────────────────────────────┘
                 │
                 ▼
         🌐 API PlumID Backend
```

---

## 🛠️ Technologies clés

| Couche | Techno | Usage |
|--------|--------|-------|
| **State** | Riverpod | Gestion d'état réactive + DI |
| **Network** | Dio | Requêtes HTTP |
| **Image** | image_picker | Capture photo/galerie |
| **Location** | geolocator, geocoding | GPS & reverse geocoding |
| **Storage** | shared_preferences | Cache local |
| **Errors** | Dartz | Either<Failure, Success> |
| **Codegen** | Freezed | Modèles immutables |
| **UI** | Google Fonts | Polices custom |

---

## 📦 Entités principales

### BirdSpecies
Représente une espèce d'oiseau avec toutes ses informations.

```dart
- id: String
- commonName: String (ex: "Mésange bleue")
- scientificName: String (ex: "Cyanistes caeruleus")
- description: String?
- habitat: String?
- conservationStatus: String? (ex: "LC - Préoccupation mineure")
- imageUrls: List<String>
- regions: List<String> (zones géographiques)
- observationMonths: List<int> (1-12, mois d'observation)
```

### Prediction
Résultat d'une prédiction avec pondération contextuelle.

```dart
- speciesId: String
- speciesName: String
- scientificName: String
- confidence: double (0.0 - 1.0, du modèle IA)
- geographicWeight: double? (pondération géographique)
- temporalWeight: double? (pondération temporelle)
- finalScore: double (score final combiné)
```

### Location
Coordonnées GPS de l'observation.

```dart
- latitude: double
- longitude: double
- accuracy: double?
- address: String? (ex: "Paris, Île-de-France, France")
```

### Identification
Historique d'une identification.

```dart
- id: String
- imageUrl: String
- localImagePath: String?
- timestamp: DateTime
- location: Location?
- predictions: List<Prediction>
- selectedPrediction: Prediction?
```

---

## 🔑 Règles d'or

1. **Les dépendances pointent vers le centre**
   - Presentation → Domain ← Data
   - Le domain ne dépend de RIEN

2. **Either<Failure, Success> partout**
   - Pas de `try/catch` dans l'UI
   - Gestion d'erreurs typée via Dartz

3. **Entities ≠ Models**
   - Entities : objets métier purs (domain)
   - Models : Freezed + JSON serialization (data)

4. **Un use case = une action**
   - `IdentifyBird`, `GetHistory`, `SaveIdentification`...
   - Chacun fait une seule chose bien

5. **Providers = pont UI ↔ Domain**
   - Pas de logique métier dans les providers
   - Juste orchestration et gestion d'état

---

## 🚀 Démarrage

### 1. Installer les dépendances

```bash
cd plum_id_mobile
flutter pub get
```

### 2. Générer le code (Freezed, Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Configurer l'API

Modifiez `lib/core/constants/app_constants.dart` :

```dart
static const String apiBaseUrl = 'https://votre-api.com/api';
```

### 4. Lancer l'app

```bash
flutter run
```

---

## 📚 Prochaines étapes

- [ ] Implémenter les écrans d'identification avec résultats
- [ ] Créer l'écran de détails d'espèce
- [ ] Implémenter l'historique avec persistance
- [ ] Ajouter les tests unitaires pour les use cases
- [ ] Ajouter les tests de widgets
- [ ] Implémenter le mode hors-ligne (optionnel)
- [ ] Ajouter l'authentification utilisateur (si nécessaire)

---

## 🧪 Tests

### Tests unitaires (Domain)

```bash
flutter test test/domain/
```

### Tests de widgets

```bash
flutter test test/presentation/
```

### Tests d'intégration

```bash
flutter test integration_test/
```

---

**Architecture** : Clean Architecture + Feature-First  
**State Management** : Riverpod (avec code generation)  
**Pattern** : Repository + Use Case  
**Version** : 1.0.0  
**Date** : 19 novembre 2025
