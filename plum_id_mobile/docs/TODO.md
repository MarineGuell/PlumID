# 📋 TODO - Prochaines étapes PlumID Mobile

## ✅ Complété

- [x] Structure Clean Architecture créée
- [x] Configuration Riverpod avec DI
- [x] Entités du domaine (BirdSpecies, Prediction, Location, Identification)
- [x] Repositories interfaces et implémentations
- [x] Use cases principaux
- [x] Models Freezed + JSON serialization
- [x] Data sources (API, Local, GPS)
- [x] Providers Riverpod
- [x] Écran d'accueil basique
- [x] Theme custom avec Google Fonts
- [x] Configuration des dépendances

## 🔨 À faire immédiatement

### 1. Génération de code ⚠️ IMPORTANT

```bash
dart run build_runner build --delete-conflicting-outputs
```

Cette commande va générer tous les fichiers `.freezed.dart` et `.g.dart` nécessaires.

### 2. Configuration de l'API Backend

Modifiez `lib/core/constants/app_constants.dart` :

```dart
static const String apiBaseUrl = 'http://localhost:8000/api'; // ou votre URL
```

### 3. Permissions natives

#### Android (`android/app/src/main/AndroidManifest.xml`)

Ajoutez avant `<application>` :

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

#### iOS (`ios/Runner/Info.plist`)

Ajoutez dans le `<dict>` :

```xml
<key>NSCameraUsageDescription</key>
<string>Plum'ID a besoin d'accéder à votre appareil photo pour photographier les plumes.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Plum'ID a besoin d'accéder à vos photos pour sélectionner une image de plume.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Plum'ID utilise votre position pour améliorer l'identification des espèces selon la région.</string>
```

## 📱 Fonctionnalités à implémenter

### High Priority

- [ ] **Écran d'identification avec résultats**
  - Affichage de l'image capturée
  - Liste des prédictions triées par score
  - Indicateurs visuels de confiance
  - Intégration avec IdentificationNotifier

- [ ] **Écran de détails d'espèce**
  - Nom commun et scientifique
  - Images de référence
  - Description et habitat
  - Statut de conservation
  - Carte de répartition

- [ ] **Écran d'historique**
  - Liste des identifications passées
  - Tri par date
  - Filtrage par espèce
  - Suppression d'entrées

### Medium Priority

- [ ] **Navigation**
  - Router avec go_router ou Navigator 2.0
  - Animations de transition
  - Deep linking

- [ ] **Amélioration UI/UX**
  - Animations et transitions fluides
  - Feedback utilisateur (loading, erreurs)
  - Empty states
  - Splash screen

- [ ] **Gestion des erreurs**
  - Messages d'erreur contextuels
  - Retry logic
  - Fallback en cas d'échec API

### Low Priority

- [ ] **Mode hors-ligne**
  - Cache des espèces
  - Queue des identifications
  - Sync quand connexion disponible

- [ ] **Paramètres**
  - Préférences utilisateur
  - Langue
  - Unités de mesure

- [ ] **Onboarding**
  - Tutorial première utilisation
  - Demande de permissions

## 🧪 Tests à créer

- [ ] Tests unitaires des Use Cases
- [ ] Tests unitaires des Repositories
- [ ] Tests de widgets
- [ ] Tests d'intégration

## 📚 Documentation

- [ ] Documentation des widgets customs
- [ ] Guide de contribution
- [ ] Screenshots pour le README

## 🔧 Technique

- [ ] CI/CD avec GitHub Actions
- [ ] Configuration des flavors (dev, staging, prod)
- [ ] Analytics et crash reporting (Firebase?)
- [ ] Performance monitoring

---

## 🚀 Quick Start

1. **Générer le code** :

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Configurer l'API** dans `app_constants.dart`

3. **Ajouter les permissions** (voir ci-dessus)

4. **Lancer l'app** :

   ```bash
   flutter run
   ```

---

**Note** : Cette checklist sera mise à jour au fur et à mesure de l'avancement du projet.
