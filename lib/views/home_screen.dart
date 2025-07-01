import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/controllers/news_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:myapp/views/news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadNews();
      Provider.of<NewsController>(context, listen: false).fetchFollowedNewsIds();
    });
  }

  Future<void> _loadNews() async {
    await Provider.of<NewsController>(context, listen: false).fetchNews();
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      // Handle logout errors if necessary
      debugPrint('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                decoration: const InputDecoration(
                  hintText: 'Pesquisar...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  Provider.of<NewsController>(context, listen: false)
                      .updateSearchTerm(value);
                },
              )
            : const Text('Notícias Mundiais - ACLED'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  Provider.of<NewsController>(context, listen: false)
                      .updateSearchTerm('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.pushNamed(context, '/followed_news');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: Consumer<NewsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadNews,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (controller.filteredNews.isEmpty) {
            return const Center(
              child: Text('Nenhuma notícia encontrada.'),
            );
          }
          return ListView.builder(
            itemCount: controller.news.length,
            itemBuilder: (context, index) {
              final article = controller.news[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(controller.filteredNews[index].title),
                  subtitle: Text(
                    '${article.subEventType} - ${article.formattedDate}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(// Bookmark icon
                          controller.followedNewsIds.contains(article.dataId)
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                        ), // Bookmark icon
                        onPressed: () {
                        }, // Placeholder onPressed
                      ),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailScreen(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
       floatingActionButton: FloatingActionButton(onPressed: _logout, child: const Icon(Icons.logout)),
    );
  }
}