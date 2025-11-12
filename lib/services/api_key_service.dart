import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage API keys stored locally on the device
///
/// IMPORTANT: API keys are stored ONLY on the user's device.
/// They are never sent to any server except the official APIs (TMDb and Gemini).
class ApiKeyService {
  static const String _tmdbApiKeyKey = 'tmdb_api_key';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _keysSetupCompleteKey = 'api_keys_setup_complete';

  /// Save TMDb API key locally
  Future<void> saveTmdbApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tmdbApiKeyKey, apiKey);
  }

  /// Save Gemini API key locally
  Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, apiKey);
  }

  /// Get TMDb API key
  Future<String?> getTmdbApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tmdbApiKeyKey);
  }

  /// Get Gemini API key
  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }

  /// Check if both API keys are set
  Future<bool> areKeysConfigured() async {
    final tmdbKey = await getTmdbApiKey();
    final geminiKey = await getGeminiApiKey();
    return tmdbKey != null &&
           tmdbKey.isNotEmpty &&
           geminiKey != null &&
           geminiKey.isNotEmpty;
  }

  /// Mark setup as complete
  Future<void> markSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keysSetupCompleteKey, true);
  }

  /// Check if setup was completed before
  Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keysSetupCompleteKey) ?? false;
  }

  /// Clear all API keys (for logout or reset)
  Future<void> clearAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tmdbApiKeyKey);
    await prefs.remove(_geminiApiKeyKey);
    await prefs.remove(_keysSetupCompleteKey);
  }

  /// Validate TMDb API key format (basic validation)
  bool isValidTmdbKey(String key) {
    // TMDb API keys are 32 characters long alphanumeric
    return key.length == 32 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(key);
  }

  /// Validate Gemini API key format (basic validation)
  bool isValidGeminiKey(String key) {
    // Gemini API keys typically start with "AIza" and are ~39 characters
    return key.startsWith('AIza') && key.length >= 39;
  }
}
