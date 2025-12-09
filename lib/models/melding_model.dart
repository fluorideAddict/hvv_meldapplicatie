import 'package:cloud_firestore/cloud_firestore.dart';

class Melding {
  final String id;
  final String userId;
  final String username;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> photoUrls;
  final DateTime createdAt;
  final String? status; // 'pending', 'reviewed', 'resolved'

  Melding({
    required this.id,
    required this.userId,
    required this.username,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.photoUrls,
    required this.createdAt,
    this.status = 'pending',
  });

  factory Melding.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Melding(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Onbekend',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'category': category,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'photoUrls': photoUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  Melding copyWith({
    String? id,
    String? userId,
    String? username,
    String? category,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? photoUrls,
    DateTime? createdAt,
    String? status,
  }) {
    return Melding(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      category: category ?? this.category,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  String getFormattedDate() {
    final months = [
      'januari', 'februari', 'maart', 'april', 'mei', 'juni',
      'juli', 'augustus', 'september', 'oktober', 'november', 'december'
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  String getCategoryDisplayName() {
    final categoryNames = {
      'slecht-verlicht': 'Slecht verlichte weg',
      'gevaarlijk-kruispunt': 'Gevaarlijk kruispunt',
      'beschadigd-fietspad': 'Beschadigd fietspad',
      'kapot-wegdek': 'Kapot wegdek',
      'gevaarlijke-situatie': 'Gevaarlijke situatie',
      'ontbrekende-signalisatie': 'Ontbrekende signalisatie',
      'snelheidsovertreding': 'Snelheidsovertreding',
      'overig': 'Overig',
    };
    return categoryNames[category] ?? category;
  }
}

/// Categorieën die beschikbaar zijn voor meldingen
class MeldingCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'slecht-verlicht',
      'name': 'Slecht verlichte weg',
      'icon': '💡',
      'description': 'Straten of paden met onvoldoende verlichting',
    },
    {
      'id': 'gevaarlijk-kruispunt',
      'name': 'Gevaarlijk kruispunt',
      'icon': '⚠️',
      'description': 'Onveilige kruispunten of verkeersknooppunten',
    },
    {
      'id': 'beschadigd-fietspad',
      'name': 'Beschadigd fietspad',
      'icon': '🚴',
      'description': 'Fietspaden met gaten, losliggende tegels of andere schade',
    },
    {
      'id': 'kapot-wegdek',
      'name': 'Kapot wegdek',
      'icon': '🛣️',
      'description': 'Wegen met gaten, scheuren of andere gebreken',
    },
    {
      'id': 'gevaarlijke-situatie',
      'name': 'Gevaarlijke situatie',
      'icon': '🚨',
      'description': 'Directe gevaarlijke situaties die aandacht vereisen',
    },
    {
      'id': 'ontbrekende-signalisatie',
      'name': 'Ontbrekende signalisatie',
      'icon': '🚦',
      'description': 'Missende of beschadigde verkeersborden',
    },
    {
      'id': 'snelheidsovertreding',
      'name': 'Snelheidsovertreding',
      'icon': '🏎️',
      'description': 'Locaties waar vaak te hard wordt gereden',
    },
    {
      'id': 'overig',
      'name': 'Overig',
      'icon': '📋',
      'description': 'Andere verkeersveiligheidsproblemen',
    },
  ];

  static Map<String, dynamic>? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat['id'] == id);
    } catch (e) {
      return null;
    }
  }
}