# Architecture Visuelle - PlumID Mobile

## 🏗️ Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION                             │
│                      (Feature-First) 🎨                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌─────────────────┐  │
│  │ Identification │  │    History     │  │    Explorer     │  │
│  │                │  │                │  │                 │  │
│  │  ┌──────────┐  │  │  ┌──────────┐ │  │  ┌──────────┐  │  │
│  │  │ Providers│  │  │  │ Providers│ │  │  │ Providers│  │  │
│  │  └────┬─────┘  │  │  └────┬─────┘ │  │  └────┬─────┘  │  │
│  │       │        │  │       │       │  │       │        │  │
│  │  ┌────▼─────┐  │  │  ┌────▼─────┐ │  │  ┌────▼─────┐  │  │
│  │  │ Screens  │  │  │  │ Screens  │ │  │  │ Screens  │  │  │
│  │  └──────────┘  │  │  └──────────┘ │  │  └──────────┘  │  │
│  │  ┌──────────┐  │  │  ┌──────────┐ │  │  ┌──────────┐  │  │
│  │  │ Widgets  │  │  │  │ Widgets  │ │  │  │ Widgets  │  │  │
│  │  └──────────┘  │  │  └──────────┘ │  │  └──────────┘  │  │
│  └────────────────┘  └────────────────┘  └─────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         providers.dart (Infrastructure)                   │  │
│  │  • Dio, SharedPreferences                                │  │
│  │  • DataSources                                           │  │
│  │  • Repositories                                          │  │
│  │  • Use Cases                                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              ▼                                   │
└─────────────────────────────────────────────────────────────────┘
                               │
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│                          DOMAIN                                  │
│                      (Layer-First) 🎯                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐     ┌──────────────┐     ┌─────────────┐     │
│  │  Entities   │     │ Repositories │     │  Use Cases  │     │
│  │             │     │ (Interfaces) │     │             │     │
│  │ • Bird      │     │              │     │ • Identify  │     │
│  │ • Predict   │     │ • iIdentify  │     │ • GetHist   │     │
│  │ • Location  │     │ • iHistory   │     │ • Save      │     │
│  │ • Identif   │     │ • iLocation  │     │ • GetLoc    │     │
│  └─────────────┘     └──────────────┘     └─────────────┘     │
│                              ▲                                   │
└──────────────────────────────┴──────────────────────────────────┘
                               │
                               │ implements
┌──────────────────────────────▼──────────────────────────────────┐
│                           DATA                                   │
│                      (Layer-First) 💾                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐     ┌──────────────┐     ┌─────────────┐     │
│  │   Models    │     │ DataSources  │     │ Repositories│     │
│  │  (Freezed)  │     │              │     │    (Impl)   │     │
│  │             │     │ • Remote API │     │             │     │
│  │ • Bird      │     │ • Local DB   │     │ • Identify  │     │
│  │ • Predict   │     │ • GPS        │     │ • History   │     │
│  │ • Location  │     │              │     │ • Location  │     │
│  │ • Identif   │     │              │     │             │     │
│  └─────────────┘     └──────────────┘     └─────────────┘     │
│         │                    │                     │            │
│         └────────────────────┴─────────────────────┘            │
│                              ▼                                   │
│                         External APIs                            │
│                    (Backend, GPS, Cache)                         │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Flux de données

### Exemple : Identification d'un oiseau

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER ACTION                                                   │
│    HomeScreen : Utilisateur prend une photo                      │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. PRESENTATION                                                  │
│    identification_provider.dart                                  │
│    → identifyBird(imagePath)                                     │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. USE CASE                                                      │
│    IdentifyBird.call(params)                                     │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. REPOSITORY (Interface)                                        │
│    IIdentificationRepository.identifyFromImage()                 │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. REPOSITORY (Implementation)                                   │
│    IdentificationRepositoryImpl.identifyFromImage()              │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. DATASOURCE                                                    │
│    IdentificationRemoteDataSource                                │
│    → POST /identify avec l'image                                 │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. API RESPONSE                                                  │
│    PredictionModel[] ← JSON                                      │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 8. MAPPING                                                       │
│    PredictionModel → Prediction (Entity)                         │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 9. EITHER<FAILURE, SUCCESS>                                      │
│    Right(List<Prediction>) ou Left(Failure)                      │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 10. STATE UPDATE                                                 │
│     identification_provider.dart                                 │
│     → state.copyWith(predictions: [...])                         │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│ 11. UI UPDATE                                                    │
│     Widget rebuild avec les nouvelles prédictions                │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 Organisation des providers

### providers.dart (Central - Infrastructure)

```
Infrastructure Providers
├── Dio (HTTP client)
├── SharedPreferences (Local storage)
├── DataSources
│   ├── IdentificationRemoteDataSource
│   ├── HistoryLocalDataSource
│   └── LocationDataSource
├── Repositories
│   ├── IIdentificationRepository → IdentificationRepositoryImpl
│   ├── IHistoryRepository → HistoryRepositoryImpl
│   └── ILocationRepository → LocationRepositoryImpl
└── Use Cases
    ├── IdentifyBird
    ├── GetSpeciesDetails
    ├── GetHistory
    ├── SaveIdentification
    └── GetCurrentLocation
```

### Feature Providers (Par fonctionnalité)

```
presentation/
├── identification/providers/
│   └── identification_provider.dart
│       ├── IdentificationState
│       └── IdentificationNotifier
│           ├── identifyBird()
│           └── clear()
│
├── history/providers/
│   └── history_provider.dart
│       ├── HistoryState
│       └── HistoryNotifier
│           ├── loadHistory()
│           └── saveIdentification()
│
└── [future_features]/providers/
    └── ...
```

## 🎯 Règles de dépendance

```
┌──────────────────────────────────────┐
│  Presentation (Feature-First)        │
│  • Dépend de Domain                  │
│  • Ne connaît PAS Data               │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Domain (Layer-First)                │
│  • Indépendant                       │
│  • Ne dépend de RIEN                 │
└──────────────▲───────────────────────┘
               │
               │ implements
┌──────────────┴───────────────────────┐
│  Data (Layer-First)                  │
│  • Dépend de Domain                  │
│  • Implémente les interfaces         │
└──────────────────────────────────────┘
```

## ✨ Points clés de l'architecture

### ✅ Avantages

1. **Séparation des préoccupations**
   - Domain : Logique métier pure
   - Data : Accès aux données
   - Presentation : UI et state management

2. **Testabilité**
   - Use cases testables unitairement
   - Repositories mockables
   - State management isolé

3. **Scalabilité**
   - Facile d'ajouter des features
   - Code organisé par fonctionnalité
   - Infrastructure centralisée

4. **Maintenabilité**
   - Code regroupé par feature
   - Dépendances claires
   - Documentation complète

### 🔒 Règles strictes

- ❌ Presentation ne peut PAS importer Data
- ❌ Domain ne peut dépendre de rien
- ❌ Pas de logique métier dans Presentation
- ✅ Toujours passer par les Use Cases
- ✅ Utiliser Either<Failure, Success>
- ✅ Models dans Data, Entities dans Domain

---

**Architecture** : Clean Architecture + Feature-First  
**Version** : 1.0.0  
**Dernière mise à jour** : 14 janvier 2026
