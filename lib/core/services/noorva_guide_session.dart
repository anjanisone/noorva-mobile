import 'dart:math';

import 'noorva_local_store.dart';

class NoorvaGuideSession {
  NoorvaGuideSession._();
  static final instance = NoorvaGuideSession._();

  static const _userIdKey = 'noorva_api_user_id';
  static const _chatSessionKey = 'noorva_chat_session_id';
  static const _hiaiActiveKey = 'noorva_hiai_active';

  final _store = NoorvaLocalStore.instance;

  Future<String> userId() async {
    var id = await _store.getString(_userIdKey);
    if (id == null || id.isEmpty) {
      id = 'mobile-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';
      await _store.setString(_userIdKey, id);
    }
    return id;
  }

  Future<String?> chatSessionId() => _store.getString(_chatSessionKey);

  Future<void> setChatSessionId(String id) => _store.setString(_chatSessionKey, id);

  Future<void> clearChatSession() => _store.remove(_chatSessionKey);

  Future<bool> hiaiActive() async => await _store.getBool(_hiaiActiveKey) ?? false;

  Future<void> setHiaiActive(bool active) => _store.setBool(_hiaiActiveKey, active);

  Future<void> clearHiai() => setHiaiActive(false);

  /// Clear local Noorva identity (call after server wipe). Returns the new user id.
  Future<String> clearLocalIdentity() async {
    await _store.remove(_userIdKey);
    await _store.remove(_chatSessionKey);
    await _store.remove(_hiaiActiveKey);
    return userId();
  }
}
