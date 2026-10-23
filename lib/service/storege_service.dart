import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  /// Save token
  Future<void> saveToken(
    String key,
    String token,
  ) async {
    await _storage.write(
      key: key,
      value: token,
    );
  }

  /// Get token
  Future<String?> getToken(
    String key,
  ) async {
    return await _storage.read(key: key);
  }

  /// Clear single token
  Future<void> clearToken(
    String key,
  ) async {
    await _storage.delete(key: key);
  }

  /// Save object response
  Future<void> saveResponse(
    String key,
    Map<String, dynamic> object,
  ) async {
    await _storage.write(
      key: key,
      value: jsonEncode(object),
    );
  }

  /// Get saved object response
  Future<Map<String, dynamic>?>
  getResponse(String key) async {
    final response = await _storage.read(
      key: key,
    );

    if (response == null) {
      return null;
    }

    return jsonDecode(response)
        as Map<String, dynamic>;
  }

  /// Clear all storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}