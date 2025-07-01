import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/followed_news.dart';
import '../models/news_article.dart';
import 'news_detail_screen.dart';

class FollowedNewsScreen extends StatefulWidget {
  const FollowedNewsScreen({super.key});

  @override
  State<FollowedNewsScreen> createState() => _FollowedNewsScreenState();
}

class _FollowedNewsScreenState extends State<FollowedNewsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  List<FollowedNews> _followedNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchFollowedNews();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFollowedNews() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('followedNews')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();

      _followedNews = querySnapshot.docs.map((doc) {
        return FollowedNews.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>,
          SnapshotOptions(),
        );
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching followed news: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias Seguidas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _followedNews.isEmpty
              ? const Center(child: Text('Você não segue nenhuma notícia ainda.'))
              : ListView.builder(
                  itemCount: _followedNews.length,
                  itemBuilder: (context, index) {
                    final followedArticle = _followedNews[index];
                    final notePreview = (_currentUser != null && followedArticle.notes.containsKey(_currentUser!.uid) && followedArticle.notes[_currentUser!.uid]!.isNotEmpty)
 ? followedArticle.notes[_currentUser!.uid]!
                        : 'Nenhuma nota pessoal';

                    return ListTile(
                      title: Text('Notícia ID: ${followedArticle.newsId}'),
                      subtitle: Text(notePreview),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailScreen(
                              article: NewsArticle(
                                dataId: followedArticle.newsId,
                                eventType: followedArticle.eventType,
                                subEventType: followedArticle.subEventType,
                                actor1: followedArticle.actor1,
                                location: followedArticle.location,
                                country: followedArticle.country,
                                eventDate: DateTime.now(), // Valor temporário
                                // Adicione outros campos obrigatórios do seu NewsArticle
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}