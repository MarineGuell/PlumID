# 📱 PlumID Mobile

Application mobile Flutter pour l'identification d'oiseaux à partir de photos de plumes.

## 🎯 Fonctionnalités

- 📷 **Capture de photo** : Prenez une photo ou sélectionnez depuis la galerie
- 🤖 **Identification IA** : Reconnaissance d'espèces via modèle d'IA
- 🗺️ **Géolocalisation** : Pondération des résultats selon la position GPS
- 📅 **Contexte temporel** : Prise en compte de la saison d'observation
- 📊 **Résultats classés** : Top prédictions avec scores de confiance
- 📚 **Fiches espèces** : Informations détaillées sur chaque oiseau
- 💾 **Historique** : Sauvegarde locale des identifications

## 🏗️ Architecture

Le projet utilise **Clean Architecture** avec **Riverpod** pour garantir :
- ✅ Code testable et maintenable
- ✅ Séparation des responsabilités
- ✅ Indépendance vis-à-vis des frameworks
- ✅ Scalabilité

Voir [ARCHITECTURE.md](./docs/ARCHITECTURE.md) pour plus de détails.

## 📁 Structure du projet

```
lib/
├── core/                 # Utilitaires transverses
│   ├── constants/        # Constantes (API URL, configs)
│   ├── theme/           # Thème de l'app
│   ├── utils/           # Helpers, extensions
│   └── errors/          # Failures & Exceptions
│
├── data/                # Couche données
│   ├── models/          # Modèles Freezed + JSON
│   ├── datasources/     # API, GPS, Cache local
│   └── repositories/    # Implémentations
│
├── domain/              # Couche métier (PURE DART)
│   ├── entities/        # BirdSpecies, Prediction, etc.
│   ├── repositories/    # Interfaces (contrats)
│   └── usecases/        # IdentifyBird, GetHistory, etc.
│
└── presentation/        # Couche UI
    ├── providers/       # Riverpod state management
    ├── widgets/         # Widgets communs
    ├── identification/  # Feature: Identification
    ├── history/         # Feature: Historique
    └── species_detail/  # Feature: Détails espèce
```

## 🚀 Installation

### Prérequis

- Flutter SDK ≥ 3.7.2
- Dart SDK ≥ 3.7.2
- Android Studio / Xcode (selon la plateforme cible)

### 1. Cloner le projet

```bash
git clone https://github.com/MarineGuell/PlumID.git
cd PlumID/plum_id_mobile
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Générer le code (Freezed, Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

> ⚠️ À exécuter après chaque modification de fichiers avec `@freezed` ou `@riverpod`

### 4. Configurer l'API

Modifiez `lib/core/constants/app_constants.dart` :

```dart
static const String apiBaseUrl = 'https://votre-api-backend.com/api';
```

### 5. Lancer l'application

```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome

# Device spécifique
flutter devices
flutter run -d <device_id>
```

## 📦 Dépendances principales

| Package | Usage |
|---------|-------|
| `flutter_riverpod` | State management |
| `riverpod_annotation` | Code generation Riverpod |
| `dartz` | Functional programming (Either) |
| `dio` | HTTP client |
| `freezed` | Immutable models |
| `json_serializable` | JSON serialization |
| `image_picker` | Capture photo/galerie |
| `geolocator` | Géolocalisation GPS |
| `geocoding` | Reverse geocoding |
| `shared_preferences` | Stockage local |
| `google_fonts` | Polices custom |
| `cached_network_image` | Cache d'images |

## 🧪 Tests

### Lancer tous les tests

```bash
flutter test
```

### Tests unitaires (Domain)

```bash
flutter test test/domain/
```

### Tests de widgets

```bash
flutter test test/presentation/
```

### Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🛠️ Développement

### Générer le code après modifications

```bash
# Watch mode (régénère automatiquement)
dart run build_runner watch --delete-conflicting-outputs

# One-time generation
dart run build_runner build --delete-conflicting-outputs
```

### Linter

```bash
flutter analyze
```

### Format du code

```bash
dart format .
```

## 📱 Build de production

### Android (APK)

```bash
flutter build apk --release
```

### Android (App Bundle)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🔧 Configuration des permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre appareil photo pour identifier les plumes.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour identifier les plumes.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous utilisons votre position pour améliorer l'identification des espèces.</string>
```

## 🐛 Debug

### Problèmes courants

**Erreur de génération de code :**
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**Erreur de dépendances :**
```bash
flutter pub cache clean
flutter pub get
```

**Erreur de build :**
```bash
flutter clean
flutter pub get
flutter run
```

## 👥 Équipe

Voir [README.md](../README.md) du projet principal pour la liste complète de l'équipe.

## 📄 License

Ce projet est privé et destiné à un usage académique (YNOV - YDAYS).

---

**Version** : 1.0.0  
**Dernière mise à jour** : 19 novembre 2025
