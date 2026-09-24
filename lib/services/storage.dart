import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Saves lists as JSON on the phone so they survive app restarts.
class Storage {
  Storage(this._prefs);

  final SharedPreferences _prefs;

  static Future<Storage> open() async =>
      Storage(await SharedPreferences.getInstance());

  List<Map<String, dynamic>> readList(String key) {
    try {
      final raw = _prefs.getString(key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return []; // Corrupted data: start fresh instead of crashing.
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> items) =>
      _prefs.setString(key, jsonEncode(items));
}
