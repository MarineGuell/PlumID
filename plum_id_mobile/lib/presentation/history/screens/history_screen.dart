import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/identification.dart';
import '../notifiers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(historyNotifierProvider.notifier).loadHistory();
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
            historyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyState.error != null
                ? _buildErrorState(context, historyState.error!)
                : historyState.identifications.isEmpty
                ? _buildEmptyState(context)
                : _buildHistoryList(context, historyState.identifications),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppTheme.danger),
            const SizedBox(height: 24),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textOnPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 80, color: AppTheme.textOnPrimary),
            const SizedBox(height: 24),
            Text(
              'Historique',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vos identifications de plumes apparaîtront ici',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textOnPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<Identification> identifications,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      itemCount: identifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 5),
      itemBuilder: (context, index) {
        final identification = identifications[index];
        // TODO: Access properties from Identification entity
        // For now using placeholder data structure
        final dateText = 'Date placeholder'; // identification.timestamp
        final speciesName = 'Espèce ${index + 1}'; // identification.speciesName

        return Card(
          color: AppTheme.surfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.history,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            title: Text(
              dateText,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Voir les détails',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
              onPressed: () {
                // TODO: Implement delete functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Suppression non implémentée'),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                );
              },
            ),
            onTap: () {
              // TODO: Navigate to detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Détails pour $speciesName'),
                  backgroundColor: AppTheme.secondaryColor,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
