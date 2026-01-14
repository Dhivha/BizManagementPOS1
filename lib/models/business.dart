class Business {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String ownerId;
  final BusinessType type;
  final BusinessStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Business({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    required this.ownerId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logo: json['logo'] as String?,
      ownerId: json['owner_id'] as String,
      type: BusinessType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BusinessType.other,
      ),
      status: BusinessStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BusinessStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'owner_id': ownerId,
      'type': type.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? ownerId,
    BusinessType? type,
    BusinessStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum BusinessType {
  retail,
  restaurant,
  service,
  technology,
  healthcare,
  education,
  finance,
  manufacturing,
  other,
}

enum BusinessStatus {
  active,
  inactive,
  suspended,
  pending,
}

extension BusinessTypeExtension on BusinessType {
  String get displayName {
    switch (this) {
      case BusinessType.retail:
        return 'Retail';
      case BusinessType.restaurant:
        return 'Restaurant';
      case BusinessType.service:
        return 'Service';
      case BusinessType.technology:
        return 'Technology';
      case BusinessType.healthcare:
        return 'Healthcare';
      case BusinessType.education:
        return 'Education';
      case BusinessType.finance:
        return 'Finance';
      case BusinessType.manufacturing:
        return 'Manufacturing';
      case BusinessType.other:
        return 'Other';
    }
  }
}