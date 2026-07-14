import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ladder_result.dart';

const _storageKey = 'ladder-results';

class LadderStorage {
  static Future<List<LadderResult>> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => LadderResult.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveResult(LadderResult result) async {
    final results = await loadResults();
    results.add(result);
    await _persist(results);
  }

  static Future<void> deleteResult(String id) async {
    final results = (await loadResults()).where((r) => r.id != id).toList();
    await _persist(results);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<void> _persist(List<LadderResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(results.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }
}

String generateId() {
  final now = DateTime.now().millisecondsSinceEpoch;
  return now.toRadixString(36) + (DateTime.now().microsecondsSinceEpoch % 100000).toRadixString(36);
}
