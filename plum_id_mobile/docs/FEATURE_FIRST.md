# Guide de Migration : Feature-First Architecture

## 📋 Récapitulatif des changements

Le projet a été réorganisé pour adopter une approche **Feature-First** dans la couche Presentation, tout en conservant l'organisation par couche (layer-first) pour Domain et Data.

### Avant

```
lib/presentation/
├── providers/
│   ├── providers.dart
│   ├── identification_provider.dart
│   └── history_provider.dart
├── identification/
│   ├── screens/
│   └── widgets/
└── history/
    ├── screens/
    └── widgets/
```

### Après

```
lib/presentation/
├── providers/
│   └── providers.dart              # Infrastructure uniquement
├── identification/
│   ├── providers/                  # State management de la feature
│   │   ├── identification_provider.dart
│   │   └── README.md
│   ├── screens/
│   └── widgets/
└── history/
    ├── providers/                  # State management de la feature
    │   ├── history_provider.dart
    │   └── README.md
    ├── screens/
    └── widgets/
```

## 🎯 Pourquoi ce changement ?

### Avantages de Feature-First

1. **Cohésion maximale** : Tout le code d'une feature au même endroit
2. **Scalabilité** : Facile d'ajouter de nouvelles features sans conflits
3. **Navigation intuitive** : Plus besoin de sauter entre dossiers
4. **Travail d'équipe** : Features isolées = moins de conflits Git
5. **Maintenabilité** : Modification d'une feature = un seul dossier

### Ce qui reste Layer-First (et pourquoi)

- **Domain** : Les entités et use cases sont réutilisés entre features
- **Data** : Les datasources et repositories sont partagés
- **Core** : Utilitaires, thème, constantes sont transversaux

## 🔧 Comment créer une nouvelle feature

### 1. Créer la structure

```bash
mkdir -p lib/presentation/ma_feature/providers
mkdir -p lib/presentation/ma_feature/screens
mkdir -p lib/presentation/ma_feature/widgets
```

### 2. Copier le template

Copiez le template depuis `species_detail/providers/README.md` et adaptez-le.

### 3. Créer le provider

```dart
// lib/presentation/ma_feature/providers/ma_feature_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/mon_entite.dart';
import '../../../domain/usecases/mon_usecase.dart';
import '../../providers/providers.dart';

part 'ma_feature_provider.g.dart';

class MaFeatureState {
  final bool isLoading;
  final String? error;
  // Vos propriétés

  const MaFeatureState({
    this.isLoading = false,
    this.error,
  });

  MaFeatureState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return MaFeatureState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class MaFeatureNotifier extends _$MaFeatureNotifier {
  @override
  MaFeatureState build() {
    return const MaFeatureState();
  }

  // Vos méthodes
}
```

### 4. Générer le code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Utiliser dans un widget

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ma_feature_provider.dart';

class MonWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maFeatureNotifierProvider);
    
    return /* ... */;
  }
}
```

## ⚠️ Règles importantes

### ✅ À faire

- Créer un provider par feature dans `presentation/{feature}/providers/`
- Importer `../../providers/providers.dart` pour accéder aux use cases
- Utiliser les use cases du Domain (jamais d'appels directs aux repositories)
- Gérer les états de chargement et d'erreur
- Utiliser `Either<Failure, Success>` pour la gestion d'erreurs

### ❌ À éviter

- Ne pas mettre de logique métier dans les providers
- Ne pas importer des classes de la couche Data dans les providers de feature
- Ne pas faire d'appels HTTP directement
- Ne pas créer de providers dans le dossier central `presentation/providers/` (sauf infrastructure)

## 📦 Que contient `providers.dart` central ?

Le fichier `lib/presentation/providers/providers.dart` contient **uniquement** :

1. **Dépendances externes** : Dio, SharedPreferences
2. **DataSources** : Remote et Local
3. **Repositories** : Implémentations concrètes
4. **Use Cases** : Instances des use cases

**Il ne contient PLUS de providers de state management** (ceux-ci sont dans chaque feature).

## 🧪 Tests

Créez vos tests dans :
```
test/presentation/ma_feature/providers/
```

## 🤝 Contribuer

Lors de l'ajout d'une nouvelle feature :

1. Suivez la structure existante
2. Créez un README.md dans le dossier `providers/` de votre feature
3. Documentez les actions et le state
4. Ajoutez des tests

## 🆘 FAQ

**Q: Puis-je partager un provider entre plusieurs features ?**  
R: Oui, créez-le dans `presentation/providers/` et ajoutez un commentaire expliquant qu'il est partagé.

**Q: Dois-je réorganiser Domain et Data en Feature-First aussi ?**  
R: Non, ils restent en Layer-First car ils sont réutilisés entre features.

**Q: Comment savoir si un provider doit être dans providers.dart central ?**  
R: S'il gère de l'infrastructure (Dio, DB, etc.) → central. S'il gère du state métier → dans la feature.

---

**Architecture** : Clean Architecture + Feature-First  
**Date de migration** : 14 janvier 2026  
**Version** : 1.0.0
