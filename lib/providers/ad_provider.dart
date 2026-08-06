import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdProvider with ChangeNotifier {
  int _availablePrompts = 3; // Default value
  bool _isAdLoading = false;
  int _messageCount = 0;
  bool _isInitialized = false;

  static const String _promptsKey = 'available_prompts';
  static const String _messageCountKey = 'message_count';

  int get availablePrompts => _availablePrompts;
  bool get isAdLoading => _isAdLoading;
  int get messageCount => _messageCount;
  bool get isInitialized => _isInitialized;

  // ---------------------------------------------------------------------------
  // 🔹 Initialize and Load Saved Data
  // ---------------------------------------------------------------------------
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved prompts (default to 3 if not found)
      _availablePrompts = prefs.getInt(_promptsKey) ?? 3;

      // Load saved message count (default to 0)
      _messageCount = prefs.getInt(_messageCountKey) ?? 0;

      _isInitialized = true;
      notifyListeners();

      debugPrint('✅ AdProvider initialized: $_availablePrompts prompts available');
    } catch (e) {
      debugPrint('❌ Error initializing AdProvider: $e');
      // If error, use default values
      _availablePrompts = 3;
      _messageCount = 0;
      _isInitialized = true;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Save Prompts to Storage
  // ---------------------------------------------------------------------------
  Future<void> _savePrompts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_promptsKey, _availablePrompts);
      debugPrint('💾 Prompts saved: $_availablePrompts');
    } catch (e) {
      debugPrint('❌ Error saving prompts: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Save Message Count to Storage
  // ---------------------------------------------------------------------------
  Future<void> _saveMessageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_messageCountKey, _messageCount);
    } catch (e) {
      debugPrint('❌ Error saving message count: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Add Prompts (After Watching Ad)
  // ---------------------------------------------------------------------------
  void addPrompts(int count) {
    _availablePrompts += count;
    _savePrompts(); // Save to storage
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🔹 Use One Prompt
  // ---------------------------------------------------------------------------
  void usePrompt() {
    if (_availablePrompts > 0) {
      _availablePrompts--;
      _messageCount++;
      _savePrompts(); // Save to storage
      _saveMessageCount(); // Save message count
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // 🔹 Set Ad Loading State
  // ---------------------------------------------------------------------------
  void setAdLoading(bool loading) {
    _isAdLoading = loading;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🔹 Increment Message Count
  // ---------------------------------------------------------------------------
  void incrementMessageCount() {
    _messageCount++;
    _saveMessageCount();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🔹 Reset Prompts (Optional - for testing or admin)
  // ---------------------------------------------------------------------------
  Future<void> resetPrompts() async {
    _availablePrompts = 3;
    _messageCount = 0;
    await _savePrompts();
    await _saveMessageCount();
    notifyListeners();
    debugPrint('🔄 Prompts reset to 3');
  }

  // ---------------------------------------------------------------------------
  // 🔹 Clear All Data (Optional - for logout or reset)
  // ---------------------------------------------------------------------------
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_promptsKey);
      await prefs.remove(_messageCountKey);
      _availablePrompts = 3;
      _messageCount = 0;
      notifyListeners();
      debugPrint('🗑️ All ad data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }
}