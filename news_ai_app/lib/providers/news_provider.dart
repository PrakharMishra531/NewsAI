import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:news_ai_app/models/article.dart'; 

class NewsProvider with ChangeNotifier {
  // === Private State ===
  List<Article> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;

  // === Getters (for the UI to read the state) ===
  List<Article> get articles => _articles; // Returns the list of articles
  bool get isLoading => _isLoading;       // True if we're currently fetching
  String? get errorMessage => _errorMessage; // Holds any error message

  // === Public Methods (for the UI to trigger actions) ===

  // Call this to fetch the news feed from your backend
  Future<void> fetchFeed() async {
    // 1. Set state to "loading" and notify the UI
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // This tells all listening widgets to rebuild

    // IMPORTANT: 10.0.2.2 is the special IP to access your
    // computer's 'localhost' from the Android Emulator.
    final Uri url = Uri.parse('https://propylic-abdul-glaucous.ngrok-free.dev/feed');
    final headers = {
      'ngrok-skip-browser-warning': 'true' 
    };
    try {
      // 2. Make the API call
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // 3. Success
        final data = json.decode(response.body);
        final List<dynamic> feedData = data['feed'];

        // Use our Article.fromJson factory to parse the JSON list
        _articles = feedData.map((json) => Article.fromJson(json)).toList();
      } else {
        // 4. Handle server errors (e.g., 404, 500)
        _errorMessage = 'Failed to load feed. Status code: ${response.statusCode}';
      }
    } catch (e) {
      // 5. Handle device errors (e.g., no internet connection)
      _errorMessage = 'An error occurred. Check your connection: $e';
    }

    // 6. Set state to "done loading" and notify the UI again
    _isLoading = false;
    notifyListeners();
  }
}