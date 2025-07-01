import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/utils/config.dart';
import '../models/news_article.dart';

class AcledApiService {
  final String _corsProxyUrl = 'https://cors-anywhere.herokuapp.com/'; // URL do proxy CORS
  final String _baseUrl = 'https://api.acleddata.com/acled/read';

  Future<List<NewsArticle>> fetchNews() async {
    try {
      final uri = Uri.parse('$_corsProxyUrl$_baseUrl').replace(queryParameters: {
        'email': ACLED_API_USER,
        'key': ACLED_API_KEY,
        'limit': '50', // Limite de resultados
      });
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data')) {
          final List<dynamic> newsData = data['data'];
          if (newsData.isNotEmpty) {
            return newsData.map((item) => NewsArticle.fromJson(item)).toList();
          }
          throw Exception('Nenhum dado encontrado na resposta');
        }
        throw Exception('Formato de resposta inválido');
      } else {
        throw Exception('Falha na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar notícias: $e');
    }
  }
}