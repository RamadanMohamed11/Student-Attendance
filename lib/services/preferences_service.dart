// Simple in-memory preferences service
// In a real app, we would use SharedPreferences or another storage solution

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  
  factory PreferencesService() => _instance;
  
  PreferencesService._internal();
  
  // In-memory storage for preferences
  final Map<String, dynamic> _preferences = {};
  static const String _apiKeyKey = 'gemini_api_key';
  
  // Save API key to preferences
  Future<bool> saveApiKey(String apiKey) async {
    _preferences[_apiKeyKey] = apiKey;
    return true;
  }
  
  // Get API key from preferences
  Future<String?> getApiKey() async {
    return _preferences[_apiKeyKey] as String?;
  }
  
  // Clear API key from preferences
  Future<bool> clearApiKey() async {
    _preferences.remove(_apiKeyKey);
    return true;
  }
}
