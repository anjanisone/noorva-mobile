import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File-backed key/value store (avoids shared_preferences pigeon mismatch on Flutter 3.47).
class NoorvaLocalStore {
  NoorvaLocalStore._();
  static final instance = NoorvaLocalStore._();

  static const _fileName = 'noorva_local_store.json';

  Map<String, dynamic>? _cache;
  File? _file;

  Future<File> _ensureFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    _file = File(p.join(dir.path, _fileName));
    return _file!;
  }

  Future<Map<String, dynamic>> _load() async {
    if (_cache != null) return _cache!;
    try {
      final file = await _ensureFile();
      if (!await file.exists()) {
        _cache = {};
        return _cache!;
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _cache = {};
        return _cache!;
      }
      final decoded = jsonDecode(raw);
      _cache = decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (e, st) {
      debugPrint('NoorvaLocalStore load: $e\n$st');
      _cache = {};
    }
    return _cache!;
  }

  Future<void> _save() async {
    final file = await _ensureFile();
    await file.writeAsString(jsonEncode(_cache ?? {}));
  }

  Future<String?> getString(String key) async {
    final map = await _load();
    final v = map[key];
    return v == null ? null : v.toString();
  }

  Future<void> setString(String key, String value) async {
    final map = await _load();
    map[key] = value;
    await _save();
  }

  Future<bool?> getBool(String key) async {
    final map = await _load();
    final v = map[key];
    if (v is bool) return v;
    if (v == 'true') return true;
    if (v == 'false') return false;
    return null;
  }

  Future<void> setBool(String key, bool value) async {
    final map = await _load();
    map[key] = value;
    await _save();
  }

  Future<void> remove(String key) async {
    final map = await _load();
    map.remove(key);
    await _save();
  }
}
