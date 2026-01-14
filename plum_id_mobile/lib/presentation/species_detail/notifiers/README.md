# [Feature Name] - State Management

Ce dossier contient les providers de gestion d'état spécifiques à la fonctionnalité **[Feature Name]**.

## Structure recommandée

### `[feature]_provider.dart`

Provider principal pour la fonctionnalité :

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/[entity].dart';
import '../../../domain/usecases/[usecase].dart';
import '../../providers/providers.dart';

part '[feature]_provider.g.dart';

/// State for [feature] feature
class [Feature]State {
  final bool isLoading;
  final String? error;
  // Add your state properties here

  const [Feature]State({
    this.isLoading = false,
    this.error,
  });

  [Feature]State copyWith({
    bool? isLoading,
    String? error,
  }) {
    return [Feature]State(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class [Feature]Notifier extends _$[Feature]Notifier {
  @override
  [Feature]State build() {
    return const [Feature]State();
  }

  // Add your methods here
}
```

## Usage dans les widgets

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/[feature]_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch([feature]NotifierProvider);
    
    // Accéder à l'état
    final isLoading = state.isLoading;
    
    // Déclencher une action
    ref.read([feature]NotifierProvider.notifier).doSomething();
    
    return /* ... */;
  }
}
```

## Checklist après création

- [ ] Implémenter le State avec tous les champs nécessaires
- [ ] Implémenter le Notifier avec les actions nécessaires
- [ ] Utiliser les use cases via `ref.read(useCaseProvider)`
- [ ] Ajouter la gestion d'erreurs avec `Either<Failure, Success>`
- [ ] Générer le code : `dart run build_runner build --delete-conflicting-outputs`
- [ ] Créer les tests unitaires dans `test/presentation/[feature]/providers/`

## Règles à respecter

- ✅ Utiliser les use cases du Domain layer (pas d'appels directs aux repositories)
- ✅ Ne pas mettre de logique métier dans le provider
- ✅ Gérer les états de chargement et d'erreur
- ✅ Utiliser `copyWith` pour l'immutabilité
- ❌ Ne pas importer des classes de la couche Data
- ❌ Ne pas faire d'appels HTTP directement

Pour l'infrastructure (Dio, repositories, use cases), voir `presentation/providers/providers.dart`.
