import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/identification_model.dart';
import '../../core/errors/exceptions.dart';

/// Local data source for storing identification history
abstract class IHistoryLocalDataSource {
  Future<void> saveIdentification(IdentificationModel identification);
  Future<List<IdentificationModel>> getHistory();
  Future<IdentificationModel> getIdentificationById(String id);
  Future<void> deleteIdentification(String id);
  Future<void> clearHistory();
}

class HistoryLocalDataSource implements IHistoryLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _historyKey = 'IDENTIFICATION_HISTORY';

  HistoryLocalDataSource(this.sharedPreferences);

  @override
  Future<void> saveIdentification(IdentificationModel identification) async {
    try {
      final history = await getHistory();
      history.insert(0, identification);

      // Keep only the latest 100 items
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }

      final jsonList = history.map((item) => item.toJson()).toList();
      await sharedPreferences.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException('Failed to save identification: $e');
    }
  }

  @override
  Future<List<IdentificationModel>> getHistory() async {
    try {
      final jsonString = sharedPreferences.getString(_historyKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => IdentificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get history: $e');
    }
  }

  @override
  Future<IdentificationModel> getIdentificationById(String id) async {
    try {
      final history = await getHistory();
      final identification = history.firstWhere(
        (item) => item.id == id,
        orElse: () => throw CacheException('Identification not found'),
      );
      return identification;
    } catch (e) {
      throw CacheException('Failed to get identification: $e');
    }
  }

  @override
  Future<void> deleteIdentification(String id) async {
    try {
      final history = await getHistory();
      history.removeWhere((item) => item.id == id);

      final jsonList = history.map((item) => item.toJson()).toList();
      await sharedPreferences.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException('Failed to delete identification: $e');
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await sharedPreferences.remove(_historyKey);
    } catch (e) {
      throw CacheException('Failed to clear history: $e');
    }
  }
}
