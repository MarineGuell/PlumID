# History Feature - State Management

Ce dossier contient les providers de gestion d'état spécifiques à la fonctionnalité **Historique**.

## Fichiers

### `history_provider.dart`

Provider principal pour la fonctionnalité d'historique des identifications :

- **State** : `HistoryState` - Contient la liste des identifications, le statut de chargement et les erreurs
- **Actions** :
  - `loadHistory()` - Charge l'historique depuis le stockage local
  - `saveIdentification(Identification identification)` - Sauvegarde une nouvelle identification

## Usage dans les widgets

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/history_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider);
    
    // Accéder à l'historique
    final identifications = historyState.identifications;
    
    // Sauvegarder une identification
    ref.read(historyNotifierProvider.notifier).saveIdentification(identification);
    
    return /* ... */;
  }
}
```

## Architecture

Ce provider :
- ✅ Utilise les use cases du Domain layer
- ✅ Ne contient pas de logique métier
- ✅ Orchestre uniquement le flux de données
- ✅ Gère l'état local de la feature

Pour l'infrastructure (SharedPreferences, repositories, use cases), voir `presentation/providers/providers.dart`.
