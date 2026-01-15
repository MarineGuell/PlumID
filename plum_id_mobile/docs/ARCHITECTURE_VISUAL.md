# Architecture Visuelle - PlumID Mobile

## 🏗️ Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION 🎨                          │
│                   (Feature-First)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │   Home   │  │  Import  │  │ Explorer │  │ History  │  │
│  │          │  │          │  │          │  │          │  │
│  │ notifiers│  │ notifiers│  │ notifiers│  │ notifiers│  │
│  │ screens  │  │ screens  │  │ screens  │  │ screens  │  │
│  │ widgets  │  │ widgets  │  │ widgets  │  │ widgets  │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │   providers.dart (Infrastructure centrale)          │  │
│  │   • Dio, SharedPreferences, DataSources             │  │
│  │   • Repositories, Use Cases                         │  │
│  └─────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    DOMAIN 🎯                                │
│                  (Layer-First)                              │
├─────────────────────────────────────────────────────────────┤
│  Entities  │  Repositories (Interfaces)  │  Use Cases      │
└──────────────────────────┬──────────────────────────────────┘
                           │ implements
┌──────────────────────────▼──────────────────────────────────┐
│                    DATA 💾                                  │
│                  (Layer-First)                              │
├─────────────────────────────────────────────────────────────┤
│  Models  │  DataSources  │  Repositories (Impl)            │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Flux de données (Exemple)

```
User Action (Screen)
    ↓
Notifier (State Management)
    ↓
Use Case (Domain Logic)
    ↓
Repository Interface (Domain)
    ↓
Repository Implementation (Data)
    ↓
DataSource (API/Local)
    ↓
Either<Failure, Success>
    ↓
State Update
    ↓
UI Rebuild
```

## 📦 Organisation

### Features (Presentation)
```
presentation/
├── providers/providers.dart    # Infrastructure centralisée
├── home/
│   ├── notifiers/             # State management
│   ├── screens/
│   └── widgets/
├── import/notifiers/
├── explorer/notifiers/
├── profile/notifiers/
├── history/notifiers/
├── species_detail/notifiers/
└── auth/notifiers/
```

## 🎯 Règles de dépendance

```
Presentation → Domain ← Data

• Presentation ne connaît PAS Data
• Domain indépendant (pas de dépendances)
• Data implémente les interfaces du Domain
```

## ✨ Points clés

**Distinction sémantique :**
- `providers/` (central) = Infrastructure (Dio, repos, use cases)
- `notifiers/` (par feature) = State management (Riverpod Notifiers)

**Architecture :**
- Clean Architecture (3 couches)
- Feature-First (Presentation)
- Layer-First (Domain + Data)
- State: Riverpod + code generation
- Error handling: Either<Failure, Success>

---

**Version** : 1.0.0  
**Dernière mise à jour** : 14 janvier 2026
