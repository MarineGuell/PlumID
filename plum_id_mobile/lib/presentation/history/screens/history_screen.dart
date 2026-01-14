import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Liste générique pour simuler l'historique
  List<Map<String, dynamic>> historyItems = List.generate(
    10,
    (index) => {
      'id': index,
      'date': DateTime.now().subtract(Duration(days: index)),
      'species': 'Espèce ${index + 1}',
    },
  );

  void _deleteItem(int index) {
    setState(() {
      historyItems.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identification supprimée'),
        backgroundColor: AppTheme.secondaryColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: historyItems.isEmpty
            ? _buildEmptyState(context)
            : _buildHistoryList(),
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
            Icon(
              Icons.history,
              size: 80,
              color: AppTheme.textOnPrimary,
            ),
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textOnPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      itemCount: historyItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 5),
      itemBuilder: (context, index) {
        final item = historyItems[index];
        final date = item['date'] as DateTime;
        final dateText = '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

        return Card(
          color: AppTheme.surfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16
            ),
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
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.danger,
              ),
              onPressed: () => _deleteItem(index),
            ),
            onTap: () {
              // TODO: Navigate to detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Détails pour ${item['species']}'),
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
