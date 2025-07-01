class NewsArticle {
  final String dataId; // Adicionado o campo para o ID único da notícia
  final String eventType;
  final String subEventType; // Correção na capitalização
  final String actor1;
  final String location;
  final String country;
  final DateTime eventDate;
  final String? notes;

  NewsArticle({
    required this.dataId, // O ID agora é obrigatório
    required this.eventType,
    required this.subEventType,
    required this.actor1,
    required this.location,
    required this.country,
    required this.eventDate,
    this.notes,

  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      dataId: json['event_id_cnty'] ?? 'ID desconhecido', // Mapear o campo do ID da API para dataId (substitua 'data_id' pelo nome real)
      eventType: json['event_type'] ?? 'Evento desconhecido',
      subEventType: json['sub_event_type'] ?? 'Sub-tipo desconhecido',
      actor1: json['actor1'] ?? 'Ator desconhecido',
      location: json['location'] ?? 'Local desconhecido',
      country: json['country'] ?? 'País desconhecido',
      eventDate: DateTime.parse(json['event_date'] ?? DateTime.now().toString()),
      notes: json['notes'],
    );
  }

  // Getter para título formatado
  String get title {
    return '$eventType: $actor1 em $location, $country';
  }

  // Getter para data formatada
  String get formattedDate {
    
    return '${eventDate.day}/${eventDate.month}/${eventDate.year}';
  }
}