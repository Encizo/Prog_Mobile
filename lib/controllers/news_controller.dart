import 'package:flutter/material.dart';
import '../services/acled_api_service.dart';
import '../models/news_article.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsController with ChangeNotifier {
  final AcledApiService _apiService = AcledApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<NewsArticle> _news = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchTerm = '';

  List<NewsArticle> get news => _news;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchTerm => _searchTerm;

  List<NewsArticle> get filteredNews => _filterNews(_news);

  List<String> _followedNewsIds = [];
  List<String> get followedNewsIds => _followedNewsIds;

  Future<void> fetchNews() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _news = await _apiService.fetchNews();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Erro ao carregar notícias: $e';
      _news = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  List<NewsArticle> _filterNews(List<NewsArticle> newsList) {
    if (_searchTerm.isEmpty) {
      return newsList;
    }

    final lowerCaseSearchTerm = _searchTerm.toLowerCase();

    return newsList.where((article) {
      return article.title.toLowerCase().contains(lowerCaseSearchTerm) ||
             article.country.toLowerCase().contains(lowerCaseSearchTerm) ||
             article.eventType.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList();
  }

  Future<void> fetchFollowedNewsIds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _followedNewsIds = [];
      notifyListeners();
      return;
    }

    try {
      final snapshot = await _firestore.collection('followedNews').where('userId', isEqualTo: user.uid).get();
      _followedNewsIds = snapshot.docs.map((doc) => doc.data()['newsId'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching followed news IDs: $e');
      _followedNewsIds = [];
    }
    notifyListeners();
  }
}