# Home Feature - State Management

Ce dossier contient les providers de gestion d'état pour la fonctionnalité **Page d'accueil et Identification**.

## Fichiers

### `identification_provider.dart`

Provider principal pour l'identification d'oiseaux depuis la page d'accueil :

- **State** : `IdentificationState` - Contient les prédictions, la localisation, l'image, le statut de chargement et les erreurs
- **Actions** :
  - `identifyBird(String imagePath)` - Identifie un oiseau à partir d'une photo
  - `clear()` - Réinitialise l'état

## Usage dans les widgets

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/identification_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identificationState = ref.watch(identificationNotifierProvider);
    
    // Accéder aux prédictions
    final predictions = identificationState.predictions;
    
    // Déclencher une identification
    ref.read(identificationNotifierProvider.notifier).identifyBird(imagePath);
    
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

Pour l'infrastructure (Dio, repositories, use cases), voir `presentation/providers/providers.dart`.
