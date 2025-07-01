import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_article.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticle article;
  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
    _loadPersonalNote();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFollowing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('followedNews')
        .doc('${user.uid}_${widget.article.dataId}')
        .get();

    if (mounted) {
      setState(() {
        _isFollowing = doc.exists;
      });
    }
  }

  Future<void> _loadPersonalNote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    debugPrint('Loading note for document ID: ${user.uid}_${widget.article.dataId}');

    final doc = await FirebaseFirestore.instance
        .collection('followedNews')
        .doc('${user.uid}_${widget.article.dataId}')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['notes'] != null) {
        final notes = Map<String, String>.from(data['notes']);
        if (notes.containsKey(user.uid)) {
          _notesController.text = notes[user.uid]!;
        }
      }
    }
  }

  Future<void> _toggleFollow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('followedNews')
        .doc('${user.uid}_${widget.article.dataId}');

    if (_isFollowing) {
      await docRef.delete();
    } else {
      await docRef.set({
        'newsId': widget.article.dataId,
        'userId': user.uid,
        'notes': {user.uid: _notesController.text},
        'followedAt': FieldValue.serverTimestamp(),
        'title': widget.article.title,
        
        'eventType': widget.article.eventType,
        'subEventType': widget.article.subEventType,
        'actor1': widget.article.actor1,
        'location': widget.article.location,
        'country': widget.article.country,
        'eventDate': widget.article.eventDate,
      }, SetOptions(merge: true));
    }

    if (mounted) {
      setState(() {
        _isFollowing = !_isFollowing;
      });
    }
  }

  Future<void> _savePersonalNote() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    await FirebaseFirestore.instance
        .collection('followedNews')
        .doc('${user.uid}_${widget.article.dataId}')
        .set({
      'notes': {user.uid: _notesController.text},
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota salva!')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        actions: [
          IconButton(
            icon: Icon(_isFollowing ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleFollow,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.article.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Data', widget.article.formattedDate),
            _buildDetailRow('Tipo de Evento', widget.article.eventType),
            _buildDetailRow('Sub-tipo', widget.article.subEventType),
            _buildDetailRow('Ator Principal', widget.article.actor1),
            _buildDetailRow('Localização', '${widget.article.location}, ${widget.article.country}'),
            if (widget.article.notes != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Notas Pessoais:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _notesController,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Adicione suas notas aqui...',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _savePersonalNote,
              child: const Text('Adicionar Nota'),
            ),
          ],
          ],
      ),
    ),
    );
  }
}